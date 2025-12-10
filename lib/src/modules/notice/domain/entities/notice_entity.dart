import '../../../auth/domain/entities/user_entity.dart';

class NoticeEntity {
  final String id;
  final String userId;
  final String? fromUserId;
  final String type; // 'like', 'comment', 'follow', 'share'
  final String? postId;
  final String? commentId;
  final String? shareId;
  final bool isRead;
  final DateTime createdAt;
  final UserEntity? fromUser;

  NoticeEntity({
    required this.id,
    required this.userId,
    this.fromUserId,
    required this.type,
    this.postId,
    this.commentId,
    this.shareId,
    required this.isRead,
    required this.createdAt,
    this.fromUser,
  });

  // Thêm hàm copyWith để hỗ trợ update state trong Cubit an toàn hơn
  NoticeEntity copyWith({
    String? id,
    String? userId,
    String? fromUserId,
    String? type,
    String? postId,
    String? commentId,
    String? shareId,
    bool? isRead,
    DateTime? createdAt,
    UserEntity? fromUser,
  }) {
    return NoticeEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fromUserId: fromUserId ?? this.fromUserId,
      type: type ?? this.type,
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      shareId: shareId ?? this.shareId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      fromUser: fromUser ?? this.fromUser,
    );
  }
}