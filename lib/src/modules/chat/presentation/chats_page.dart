import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

import 'component/widget__custom_app_bar.dart';
import 'component/widget__search_bar.dart';
import 'component/widget__chat_list_item.dart';

@RoutePage()
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  static const _mint = Color(0xFFA7C7B7);
  static const _softBg = Color(0xFFF5F6F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softBg,

      body: Column(
        children: [
          // 1. APP BAR TÙY CHỈNH
          const WidgetCustomAppBar(),

          // 2. SEARCH BAR
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: WidgetSearchBar(),
          ),

          // 3. DANH SÁCH CHAT (Phần cuộn chính)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: const [
                WidgetChatListItem(
                  imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200',
                  username: 'xyz',
                  handle: '@xyz123',
                  lastMessage: 'You: Goodjob!',
                  time: '19/10/25',
                ),
                WidgetChatListItem(
                  imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
                  username: 'abc',
                  handle: '@abcne',
                  lastMessage: 'E',
                  time: '2/10/25',
                ),
                WidgetChatListItem(
                  imageUrl: 'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?w=200',
                  username: 'Student',
                  handle: '@student1',
                  lastMessage: 'You accepted the request',
                  time: '1/10/25',
                  isRead: false,
                ),
                // ... có thể thêm các mục khác
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
          type: BottomNavigationBarType.fixed,
          backgroundColor: _mint,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.create), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
        ),
      ),
    );
  }
}
