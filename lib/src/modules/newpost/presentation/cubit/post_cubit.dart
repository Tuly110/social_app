// lib/src/modules/newpost/presentation/cubit/post_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:social_app/src/modules/newpost/domain/usecase/get_recommended_feed_usecase.dart';
import 'package:social_app/src/modules/newpost/domain/usecase/share_post_usecase.dart';

import '../../domain/entities/post_entity.dart';
import '../../domain/usecase/create_post_usecase.dart';
import '../../domain/usecase/delete_post_usecase.dart';
import '../../domain/usecase/get_daily_limits_usecase.dart';
import '../../domain/usecase/get_feed_usecase.dart';
import '../../domain/usecase/get_like_count_usecase.dart';
import '../../domain/usecase/get_like_status_usecase.dart';
import '../../domain/usecase/get_post_by_id_usecase.dart';
import '../../domain/usecase/get_post_likes_usecase.dart';
import '../../domain/usecase/get_user_likes_usecase.dart';
import '../../domain/usecase/toggle_like_usecase.dart';
import '../../domain/usecase/update_post_usecase.dart';

part 'post_state.dart';


enum FeedMode {
  latest,       // mới nhất
  following,    // following
  recommended,  // For You)
}

@injectable
class PostCubit extends Cubit<PostState> {
  final GetFeedUseCase _getFeedUseCase;
  final GetRecommendedFeedUseCase _getRecommendedFeedUseCase;
  final CreatePostUseCase _createPostUseCase;
  final ToggleLikeUseCase _toggleLikeUseCase;
  final UpdatePostUseCase _updatePostUseCase;
  final DeletePostUseCase _deletePostUseCase;
  final GetLikeStatusUseCase _getLikeStatusUseCase;
  final GetDailyLimitsUseCase _getDailyLimitsUseCase;
  final GetLikeCountUseCase _getLikeCountUseCase;
  final GetPostLikesUseCase _getPostLikesUseCase;
  final SharePostUseCase _sharePostUseCase;
  final GetUserLikesUseCase _getUserLikesUseCase;
  final GetPostByIdUseCase _getPostByIdUseCase;
  FeedMode _currentFeedMode = FeedMode.latest; // Mặc định
  bool _onlyFollowing = false; // Following

  PostCubit(
    this._getFeedUseCase,
    this._getRecommendedFeedUseCase,
    this._createPostUseCase,
    this._toggleLikeUseCase,
    this._updatePostUseCase,
    this._deletePostUseCase,
    this._getLikeStatusUseCase,
    this._getDailyLimitsUseCase,
    this._getLikeCountUseCase,
    this._getPostLikesUseCase,
    this._getUserLikesUseCase,
    this._sharePostUseCase,
    this._getPostByIdUseCase,
  ) : super(const PostStateInitial());

  /// load danh sách bài viết
  Future<void> loadFeed({
    int page = 0,
    int limit = 20,
    bool append = false,
    FeedMode mode = FeedMode.latest,
    bool onlyFollowing = false,
  }) async {
    if (isClosed) {
      print('⚠️ PostCubit is closed, cannot load feed');
      return;
    }

     _currentFeedMode = mode;
    _onlyFollowing = onlyFollowing;

    if (!append) {
      emit(const PostStateLoading());
    }

     try {
      List<PostEntity> posts;
      
      switch (mode) {
        case FeedMode.recommended:
          posts = await _getRecommendedFeedUseCase(limit: limit);
          break;
          
        case FeedMode.following:
          posts = await _getFeedUseCase(page: page, limit: limit);
          break;
          
        case FeedMode.latest:
        default:
          posts = await _getFeedUseCase(page: page, limit: limit);
          break;
      }

      if (isClosed) return;

      if (append && state is PostStateLoaded) {
        final current = (state as PostStateLoaded).posts;
        emit(PostStateLoaded(posts: [...current, ...posts]));
      } else {
        emit(PostStateLoaded(posts: posts));
      }
    } catch (e) {
      if (isClosed) return;
      emit(PostStateError(message: e.toString()));
    }
  }

  /// tạo post mới (có thể kèm imageUrl)
  Future<bool> createPost(String content, {String? imageUrl}) async {
    final current = state;
    try {
      final PostEntity newPost = await _createPostUseCase(
        content,
        imageUrl: imageUrl,
      );

      if (isClosed) return false;

      if (current is PostStateLoaded) {
        emit(PostStateLoaded(posts: [newPost, ...current.posts]));
      } else {
        emit(PostStateLoaded(posts: [newPost]));
      }
      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(PostStateError(message: e.toString()));
      return false;
    }
  }

  /// cập nhật post (text + image)
  Future<bool> editPost(
    String postId, {
    required String content,
    String? imageUrl,
  }) async {
    final current = state;
    try {
      final PostEntity updated = await _updatePostUseCase(
        postId,
        content: content,
        imageUrl: imageUrl,
      );

      if (isClosed) return false;

      if (current is PostStateLoaded) {
        final updatedList = current.posts
            .map((p) => p.id == updated.id ? updated : p)
            .toList();
        emit(PostStateLoaded(posts: updatedList));
      } else {
        emit(PostStateLoaded(posts: [updated]));
      }
      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(PostStateError(message: e.toString()));
      return false;
    }
  }

  /// helper: chỉ chỉnh text (nếu chỗ nào cũ còn gọi)
  Future<bool> editPostContent(String postId, String content) {
    return editPost(postId, content: content);
  }

  /// xoá post
  Future<bool> deletePost(String postId) async {
    final current = state;
    try {
      await _deletePostUseCase(postId);

      if (current is PostStateLoaded) {
        final updatedList = current.posts.where((p) => p.id != postId).toList();
        emit(PostStateLoaded(posts: updatedList));
      }
      return true;
    } catch (e) {
      emit(PostStateError(message: e.toString()));
      return false;
    }
  }

  /// toggle like 1 post
  Future<void> toggleLike(String postId) async {
    if (state is! PostStateLoaded) return;

    final loaded = state as PostStateLoaded;
    final posts = [...loaded.posts];

    final index = posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    // lấy post hiện tại
    final oldPost = posts[index];

    final newPost = oldPost.copyWith(
      isLiked: !oldPost.isLiked,
      likeCount: oldPost.isLiked
          ? oldPost.likeCount - 1
          : oldPost.likeCount + 1,
    );
    posts[index] = newPost;
    emit(PostStateLoaded(posts: posts));

    try {
      await _toggleLikeUseCase(postId);
    } catch (e) {
      // rollback nếu fail
      posts[index] = oldPost;
      emit(PostStateLoaded(posts: posts));
    }
  }

  /// share 1 post với visibility (public/private) + content kèm theo
  Future<bool> sharePost(
    String postId, {
    required String visibility,
    String? content,
  }) async {
    final current = state;
    try {
      final PostEntity sharedPost = await _sharePostUseCase(
        postId,
        visibility: visibility,
        content: content,
      );

      if (isClosed) return false;

      if (current is PostStateLoaded) {
        emit(PostStateLoaded(posts: [sharedPost, ...current.posts]));
      } else {
        emit(PostStateLoaded(posts: [sharedPost]));
      }

      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(PostStateError(message: e.toString()));
      return false;
    }
  }

  Future<bool> canLike() async {
    try {
      final limits = await _getDailyLimitsUseCase();
      final used = limits['likes_used'];
      // final limit = limits['likeLimit'] ?? 5;

      return used == 5;
    } catch (e) {
      print('Error checking like limit $e');
      return true; // an toàn: vẫn cho like nếu backend gặp lỗi
    }
  }

  Future<Map<String, dynamic>> getDailyLimits() async {
    try {
      return await _getDailyLimitsUseCase();
    } catch (e) {
      print('>>> [Cubit] getDailyLimits error: $e');
      rethrow;
    }
  }

  /// Lấy 1 post theo postId (dùng khi mở từ notification)
  Future<PostEntity?> getPostById(String postId) async {
    try {
      final post = await _getPostByIdUseCase(postId);
      return post;
    } catch (e) {
      print("❌ getPostById error: $e");
      return null;
    }
  }

  Future<int> getLikeCount(String postId) async {
    try {
      return await _getLikeCountUseCase(postId);
    } catch (e) {
      print('>>> [Cubit] getLikeCount error: $e');
      rethrow;
    }
  }

  Future<List<String>> getPostLikes(String postId) async {
    try {
      return await _getPostLikesUseCase(postId);
    } catch (e) {
      print('>>> [Cubit] getPostLikes error: $e');
      rethrow;
    }
  }

  Future<List<String>> getUserLikes() async {
    try {
      return await _getUserLikesUseCase();
    } catch (e) {
      print('>>> [Cubit] getUserLikes error: $e');
      rethrow;
    }
  }

  void addPostOnTop(PostEntity post) {
    final current = state;
    if (current is PostStateLoaded) {
      emit(PostStateLoaded(posts: [post, ...current.posts]));
    } else {
      emit(PostStateLoaded(posts: [post]));
    }
  }
}
