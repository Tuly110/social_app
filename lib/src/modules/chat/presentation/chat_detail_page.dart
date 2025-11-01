import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class ChatDetailPage extends StatelessWidget {
  // Thay thế bằng dữ liệu thực tế (ví dụ: tên người dùng, avatar URL)
  final String userName;
  final String userAvatarUrl;

  const ChatDetailPage({
    super.key,
    this.userName = 'xyz',
    this.userAvatarUrl =
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
  });

  static const _mint = Color(0xFFA7C7B7); // Màu xanh mint
  static const _softBg = Color(0xFFF5F6F8); // Màu nền chat

  @override
  Widget build(BuildContext context) {
    // Dữ liệu tin nhắn giả định
    final messages = [
      Message(text: 'Hello', isMe: false),
      Message(text: 'Highfive', isMe: false),
      Message(text: 'hi!!!!!!!!!!', isMe: true),
      Message(text: 'Goodjob!', isMe: true, status: 'Sent'),
      // Thêm nhiều tin nhắn khác để kiểm tra cuộn
      Message(text: 'Are you free tomorrow?', isMe: false),
      Message(text: 'I think I am. What about you?', isMe: true),
      Message(text: 'Great! Let\'s meet at 7pm.', isMe: false),
      Message(text: 'See you then!', isMe: true, status: 'Sent'),
    ];

    return Scaffold(
      backgroundColor: _softBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          userName,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(userAvatarUrl),
            ),
          ),
        ],
      ),

      // Sử dụng Column để chứa danh sách tin nhắn và thanh nhập liệu cố định
      body: Column(
        children: [
          // Khu vực hiển thị tin nhắn (có thể cuộn)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              reverse: true, // Hiển thị tin nhắn mới nhất ở dưới cùng
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                return _MessageBubble(message: message);
              },
            ),
          ),

          // Thanh nhập liệu tin nhắn cố định ở dưới
          _ChatInputBar(),
        ],
      ),
    );
  }
}

///==================== WIDGET TIN NHẮN (MESSAGE BUBBLE) ====================

class Message {
  final String text;
  final bool isMe;
  final String? status; // Ví dụ: 'Sent', 'Delivered', 'Read'

  Message({required this.text, required this.isMe, this.status});
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  static const _mint = Color(0xFFA7C7B7);

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    // Căn tin nhắn sang trái (người khác) hoặc phải (tôi)
    final align = message.isMe ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isMe ? _mint : Colors.white;
    final textColor = message.isMe ? Colors.white : Colors.black87;
    final borderRadius = BorderRadius.circular(16);

    return Align(
      alignment: align,
      child: Column(
        crossAxisAlignment:
            message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Bong bóng tin nhắn
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: borderRadius.copyWith(
                // Loại bỏ bo góc ở phía gần người gửi
                topRight: message.isMe
                    ? const Radius.circular(4)
                    : borderRadius.topRight,
                topLeft: message.isMe
                    ? borderRadius.topLeft
                    : const Radius.circular(4),
              ),
              boxShadow: message.isMe
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),

          // Trạng thái tin nhắn (chỉ hiển thị cho tin nhắn của mình)
          if (message.isMe && message.status != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
              child: Text(
                message.status!,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

///==================== WIDGET THANH NHẬP LIỆU (INPUT BAR) ====================

class _ChatInputBar extends StatelessWidget {
  static const _mint = Color(0xFFA7C7B7);

  @override
  Widget build(BuildContext context) {
    // Media Query để lấy chiều cao an toàn dưới cùng (notch/home indicator)
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      color: Colors.white, // Nền trắng cho thanh input
      child: Row(
        children: [
          // Nút Add (+)
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _mint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 8),

          // Ô nhập liệu
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Typing...',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.only(bottom: 10), // Căn chỉnh chữ
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Nút Send (Icon mũi tên)
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _mint.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.send, color: _mint, size: 20),
          ),
        ],
      ),
    );
  }
}
