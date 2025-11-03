import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// Import các widget tách riêng
import 'component/widget__avatar.dart';
import 'component/widget__circle_icon.dart';
import 'component/widget__panel_content.dart';
import 'component/widget__tab_and_content.dart';

@RoutePage()
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  static const _mint = Color(0xFFA7C7B7);
  static const _bg = Color(0xFFF4F7F7);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _bg,
        body: ListView(
          padding: EdgeInsets.zero,
          children: const [
            _HeaderStack(),
            WidgetTabAndContent(),
          ],
        ),
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
              BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: ''),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderStack extends StatelessWidget {
  const _HeaderStack();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    const double coverHeight = 220;
    const double panelTop = 160;
    const double avatarRadius = 36;

    return SizedBox(
      height: panelTop + 280,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover ảnh nền
          Positioned.fill(
            top: 0,
            bottom: null,
            child: SizedBox(
              height: coverHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1761901175711-b6e3dd720a66?w=1600&auto=format&fit=crop',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black26],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nút Back và Mail
          Positioned(
            left: 16,
            top: top + 12,
            child: const WidgetCircleIcon(icon: Icons.arrow_back),
          ),
          Positioned(
            right: 16,
            top: top + 12,
            child: const WidgetCircleIcon(icon: Icons.mail_outline),
          ),

          // Panel trắng
          Positioned(
            left: 0,
            right: 0,
            top: panelTop,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, avatarRadius + 18, 16, 16),
              decoration: const BoxDecoration(
                color: UserProfilePage._bg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: const WidgetPanelContent(),
            ),
          ),

          // Avatar
          Positioned(
            top: panelTop - avatarRadius,
            left: 0,
            right: 0,
            child: WidgetAvatar(radius: avatarRadius),
          ),
        ],
      ),
    );
  }
}
