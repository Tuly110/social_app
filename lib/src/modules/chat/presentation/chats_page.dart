import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  static const _mint = Color(0xFFA7C7B7); // Màu xanh mint cho nút/bottom bar
  static const _softBg = Color(0xFFF5F6F8); // Màu nền nhẹ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softBg,
      // **********************************************
      // Dùng Column vì không có nội dung cuộn bên dưới AppBar
      // **********************************************
      body: Column(
        children: [
          // 1. APP BAR TÙY CHỈNH (không dùng SliverAppBar)
          _CustomAppBar(),

          // 2. SEARCH BAR
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _SearchBar(),
          ),

          // 3. DANH SÁCH CHAT (Phần cuộn chính)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: const [
                _ChatListItem(
                  imageUrl:
                      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
                  username: 'xyz',
                  handle: '@xyz123',
                  lastMessage: 'You: Goodjob!',
                  time: '19/10/25',
                ),
                _ChatListItem(
                  imageUrl:
                      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
                  username: 'abc',
                  handle: '@abcne',
                  lastMessage: 'E',
                  time: '2/10/25',
                ),
                _ChatListItem(
                  imageUrl:
                      'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?w=200',
                  username: 'Student',
                  handle: '@student1',
                  lastMessage: 'You accepted the request',
                  time: '1/10/25',
                  isRead: false,
                ),
                // Thêm các mục khác tại đây...
              ],
            ),
          ),
        ],
      ),

      // FLOATING ACTION BUTTON (Nút +)
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _mint,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          // Bắt buộc phải là fixed khi có > 3 mục. Giữ nguyên fixed là đúng.
          type: BottomNavigationBarType.fixed,
          backgroundColor: _mint,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          items: const [
            // 1. Home
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
            // 2. Search
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            // 3. Create
            BottomNavigationBarItem(icon: Icon(Icons.create), label: ''),
            // **********************************************
            // THÊM: 4. Chat (Icon mới)
            // **********************************************
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline), label: ''),
            // 5. Notifications (Vị trí cũ là 4)
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
            // 6. Person/Profile (Vị trí cũ là 5)
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
        ),
      ),
    );
  }
}

///==================== WIDGETS TÙY CHỈNH ====================

class _CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Dùng Padding để có không gian cho Status Bar
      padding:
          EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar (Bên trái)
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: CircleAvatar(
              radius: 16,
              // Thay thế bằng avatar thật của người dùng
              backgroundImage:
                  NetworkImage('https://i.ibb.co/bF0bS0v/black-avatar.png'),
            ),
          ),

          // Tiêu đề
          const Text(
            'Messages',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          // Nút Settings
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB), // Màu nền nhẹ của thanh tìm kiếm
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for people and groups',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                border: InputBorder.none,
                isDense: true, // Giúp TextField vừa khít với container
                contentPadding: EdgeInsets.only(bottom: 2),
              ),
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final String imageUrl;
  final String username;
  final String handle;
  final String lastMessage;
  final String time;
  final bool isRead;

  const _ChatListItem({
    required this.imageUrl,
    required this.username,
    required this.handle,
    required this.lastMessage,
    required this.time,
    this.isRead = true,
  });

  @override
  Widget build(BuildContext context) {
    // Nếu chưa đọc thì nền Item sẽ khác
    final itemColor = isRead ? Colors.white : const Color(0xFFF0F0F0);

    // Màu của tin nhắn cuối cùng (chưa đọc đậm hơn)
    final messageColor = isRead ? Colors.grey.shade600 : Colors.black87;

    return Container(
      color: itemColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 12),

          // Tên và Tin nhắn
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      handle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: messageColor,
                    fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // Thời gian
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
