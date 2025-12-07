import '../../../../modules/auth/domain/entities/user_entity.dart'; 
import '../../domain/entities/notice_entity.dart';

class NoticeModel extends NoticeEntity {
  NoticeModel({
    required String id,
    required String userId,
    String? fromUserId,
    required String type,
    String? postId,
    String? commentId,
    String? shareId,
    required bool isRead,
    required DateTime createdAt,
    UserEntity? fromUser, 
  }) : super(
          id: id,
          userId: userId,
          fromUserId: fromUserId,
          type: type,
          postId: postId,
          commentId: commentId,
          shareId: shareId,
          isRead: isRead,
          createdAt: createdAt,
          fromUser: fromUser,
        );

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      fromUserId: json['from_user_id'],
      type: json['type'] ?? 'system',
      postId: json['post_id'],
      commentId: json['comment_id'],
      shareId: json['share_id'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      
      // Map JSON to UserEntity instead of UserModel
      fromUser: json['from_user'] != null 
          ? _mapUserEntity(json['from_user']) 
          : null,
    );
  }


  static UserEntity _mapUserEntity(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] ?? '',
      username: json['username'] ?? json['full_name'] ?? 'User',
      avatarUrl: json['avatar'] ?? json['avatar_url'],
      email: json['email'] ?? '', 
    );
  }
}