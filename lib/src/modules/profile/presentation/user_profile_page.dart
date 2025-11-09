import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// Import các widget tách riêng
import '../../../../generated/colors.gen.dart';
import '../../../common/widgets/bottom_navigation.dart';
import 'component/widget__avatar.dart';
import 'component/widget__circle_icon.dart';
import 'component/widget__panel_content.dart';
import 'component/widget__tab_and_content.dart';

@RoutePage()
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: ColorName.bgF4f7f7,
        body: ListView(
          padding: EdgeInsets.zero,
          children: const [
            _HeaderStack(),
            WidgetTabAndContent(),
          ],
        ),
        bottomNavigationBar: const WidgetBottomNav(currentIndex: 6),
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
                        colors: [Colors.transparent, ColorName.black26],
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
                color: ColorName.bgF4f7f7,
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
