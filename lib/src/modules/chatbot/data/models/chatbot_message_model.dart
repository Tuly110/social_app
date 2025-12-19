class ChatbotMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime createdAt;
  final String? imageUrl;

  ChatbotMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
    this.imageUrl,
  });

  factory ChatbotMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatbotMessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}
