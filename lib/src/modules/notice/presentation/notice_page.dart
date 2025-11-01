import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  static const _mint = Color(0xFFA7C7B7);
  static const _softBg = Color(0xFFF5F6F8);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Activity, All, Mention
      child: Scaffold(
        backgroundColor: _softBg,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: 0,
              toolbarHeight: 56,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: const Text(
                'Notification',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined,
                      color: Colors.black54),
                  onPressed: () {},
                ),
              ],
              bottom: const TabBar(
                isScrollable: true,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black54,
                indicatorColor: Colors.black,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.label,
                padding: EdgeInsets.symmetric(horizontal: 16),
                tabs: [
                  Tab(text: 'Activity'),
                  Tab(text: 'All'),
                  Tab(text: 'Mention'),
                ],
              ),
            ),
          ],
          body: const TabBarView(
            children: [
              _ActivityTab(),
              _PlaceHolder(text: 'All'),
              _PlaceHolder(text: 'Mention'),
            ],
          ),
        ),
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
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications), label: ''),
              // 6. Person/Profile (Vị trí cũ là 5)
              BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
            ],
          ),
        ),
      ),
    );
  }
}

///==================== WIDGET CHO TAB ACTIVITY ====================

class _ActivityTab extends StatelessWidget {
  const _ActivityTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        // TODAY
        _TimeHeader(title: 'Today'),
        _NotificationItem(
          imageUrl:
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
          username: 'Undred',
          action: 'like your post',
          time: '10m ago',
          rightContent: _RightImage(
              url:
                  'https://images.unsplash.com/photo-1595341888016-a392ef81b7de?w=200'),
          icon: Icons.reply,
        ),
        _NotificationItem(
          imageUrl:
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
          username: 'Diu Ly',
          action: 'started following you',
          time: '10m ago',
          rightContent: _RightButton(text: 'Follow back'),
          icon: Icons.chat_bubble_outline,
        ),

        // THIS WEEK
        _TimeHeader(title: 'This week'),
        _NotificationItem(
          imageUrl:
              'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
          username: 'Minh Man',
          action: 'Mention you in this posts',
          time: '3d ago',
          rightContent: _RightButton(text: 'Reply'),
          icon: Icons.reply,
        ),
        _NotificationItem(
          imageUrl:
              'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
          username: 'Minh Man',
          action: 'Like “Diu Ly dep qua”',
          time: '3d ago',
          rightContent: _RightButton(text: 'Follow'),
          icon: Icons.person_outline,
        ),
        _NotificationItem(
          imageUrl:
              'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?w=200',
          username: 'watched',
          action: 'Ho like your post',
          time: '5d ago',
          rightContent: _RightImage(
              url:
                  'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=200'),
          icon: Icons.reply,
        ),
        _NotificationItem(
          imageUrl:
              'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?w=200',
          username: 'watched',
          action: 'Diu Ly accept your follow',
          time: '5d ago',
          rightContent: _RightIcon(icon: Icons.handshake),
          icon: Icons.person_outline,
        ),
      ],
    );
  }
}

///==================== WIDGET PHỤ ====================

// Header phân loại thời gian (Today, This week)
class _TimeHeader extends StatelessWidget {
  final String title;
  static const _mint = Color(0xFFA7C7B7);
  static const _softBg = Color(0xFFF5F6F8);

  const _TimeHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _mint.withOpacity(0.4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Color(0xFF333333),
        ),
      ),
    );
  }
}

// Item thông báo
class _NotificationItem extends StatelessWidget {
  final String imageUrl;
  final String username;
  final String action;
  final String time;
  final Widget rightContent;
  final IconData icon;

  const _NotificationItem({
    required this.imageUrl,
    required this.username,
    required this.action,
    required this.time,
    required this.rightContent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon hành động
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Icon(icon, color: Colors.grey.shade600, size: 16),
          ),
          const SizedBox(width: 8),

          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 12),

          // Nội dung thông báo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade800, height: 1.4),
                    children: [
                      TextSpan(
                        text: username,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      TextSpan(
                        text: ' $action',
                      ),
                    ],
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),

          // Nội dung bên phải (Image/Button)
          const SizedBox(width: 8),
          rightContent,
        ],
      ),
    );
  }
}

// Nút bên phải
class _RightButton extends StatelessWidget {
  final String text;
  static const _mint = Color(0xFFA7C7B7);

  const _RightButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _mint,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

// Avatar nhỏ bên phải
class _RightImage extends StatelessWidget {
  final String url;
  const _RightImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundImage: NetworkImage(url),
    );
  }
}

// Icon bên phải
class _RightIcon extends StatelessWidget {
  final IconData icon;
  static const _mint = Color(0xFFA7C7B7);

  const _RightIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _mint.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: _mint, size: 20),
    );
  }
}

// Placeholder cho các Tab chưa có nội dung
class _PlaceHolder extends StatelessWidget {
  final String text;
  const _PlaceHolder({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$text tab — Coming soon',
          style: const TextStyle(fontSize: 16, color: Colors.black54)),
    );
  }
}
