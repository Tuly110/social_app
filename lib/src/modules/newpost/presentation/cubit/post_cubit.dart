// lib/src/modules/newpost/presentation/cubit/post_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/post_entity.dart';
import '../../domain/usecase/create_post_usecase.dart';
import '../../domain/usecase/get_feed_usecase.dart';
import '../../domain/usecase/toggle_like_usecase.dart';
import '../../domain/usecase/update_post_usecase.dart';
import '../../domain/usecase/delete_post_usecase.dart';

part 'post_state.dart';

@injectable
class PostCubit extends Cubit<PostState> {
  final GetFeedUseCase _getFeedUseCase;
  final CreatePostUseCase _createPostUseCase;
  final ToggleLikeUseCase _toggleLikeUseCase;
  final UpdatePostUseCase _updatePostUseCase;
  final DeletePostUseCase _deletePostUseCase;

  PostCubit(
    this._getFeedUseCase,
    this._createPostUseCase,
    this._toggleLikeUseCase,
    this._updatePostUseCase,
    this._deletePostUseCase,
  ) : super(const PostStateInitial());

  /// load danh sách bài viết
  Future<void> loadFeed() async {
    emit(const PostStateLoading());
    try {
      final posts = await _getFeedUseCase();
      emit(PostStateLoaded(posts: posts));
    } catch (e) {
      emit(PostStateError(message: e.toString()));
    }
  }

  /// tạo post mới (có thể kèm imageUrl)
  Future<bool> createPost(String content, {String? imageUrl}) async {
    final current = state;
    try {
      final PostEntity newPost =
          await _createPostUseCase(content, imageUrl: imageUrl);

      if (current is PostStateLoaded) {
        emit(PostStateLoaded(posts: [newPost, ...current.posts]));
      } else {
        emit(PostStateLoaded(posts: [newPost]));
      }
      return true;
    } catch (e) {
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

      if (current is PostStateLoaded) {
        final updatedList =
            current.posts.map((p) => p.id == updated.id ? updated : p).toList();
        emit(PostStateLoaded(posts: updatedList));
      } else {
        emit(PostStateLoaded(posts: [updated]));
      }
      return true;
    } catch (e) {
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
    final current = state;
    if (current is! PostStateLoaded) return;

    try {
      final updatedPost = await _toggleLikeUseCase(postId);

      final updatedList = current.posts
          .map((p) => p.id == updatedPost.id ? updatedPost : p)
          .toList();

      emit(PostStateLoaded(posts: updatedList));
    } catch (e) {
      emit(PostStateError(message: e.toString()));
    }
  }
}
