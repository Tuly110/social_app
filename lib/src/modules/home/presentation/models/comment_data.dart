class CommentData {
  final String username;
  final String handle;
  final String time;
  final String content;
  final int likes;
  final bool isLiked;

  const CommentData({
    required this.username,
    required this.handle,
    required this.time,
    required this.content,
    required this.likes,
    required this.isLiked,
  });

  CommentData copyWith({
    String? username,
    String? handle,
    String? time,
    String? content,
    int? likes,
    bool? isLiked,
  }) {
    return CommentData(
      username: username ?? this.username,
      handle: handle ?? this.handle,
      time: time ?? this.time,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}