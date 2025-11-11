

// 🔹 Import các component tái sử dụng
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../generated/colors.gen.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import 'component/widget__avatar.dart';
import 'component/widget__friend_avatar.dart';
import 'component/widget__gallery_grid.dart';
import 'component/widget__placeholder.dart';
import 'component/widget__round_icon.dart';
import 'component/widget__section_title.dart';
import 'component/widget__stats_card.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const double _avatarRadius = 38;
  static const double _horizontalMargin = 24;
  static const double _tabBarHeight = 48;
  static final double _expandedHeight = 310 + _avatarRadius * 1.5;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: ColorName.softBg,
        body: NestedScrollView(
          headerSliverBuilder: (context, inner) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: _expandedHeight,
              backgroundColor: ColorName.white,
              surfaceTintColor: ColorName.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: inner ? ColorName.black87 : ColorName.white,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: inner ? ColorName.black87 : ColorName.white,
                  ),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1495562569060-2eec283d3391?q=80&w=1600&auto=format&fit=crop',
                      fit: BoxFit.cover,
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
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: _horizontalMargin,
                          right: _horizontalMargin,
                          bottom: _avatarRadius - 6,
                        ),
                        child: _ProfileCard(avatarRadius: _avatarRadius),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(_tabBarHeight),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: ColorName.white,
                  child: const TabBar(
                    isScrollable: true,
                    labelColor: ColorName.black,
                    unselectedLabelColor: ColorName.black54,
                    indicatorColor: ColorName.black,
                    indicatorWeight: 2,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelPadding: EdgeInsets.symmetric(horizontal: 12),
                    tabs: [
                      Tab(text: 'All'),
                      Tab(text: 'Post'),
                      Tab(text: 'Replies'),
                      Tab(text: 'Media'),
                      Tab(text: 'About'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: const TabBarView(
            children: [
              _AllTab(),
              WidgetPlaceholder(text: 'Post'),
              WidgetPlaceholder(text: 'Replies'),
              WidgetPlaceholder(text: 'Media'),
              WidgetPlaceholder(text: 'About'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final double avatarRadius;
  const _ProfileCard({required this.avatarRadius});

  @override
  Widget build(BuildContext context) {
    final double nameBlockTopPadding = 18;
    final double nameBlockHeight =
        (2 * avatarRadius) + nameBlockTopPadding + 10;

    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state){
      print('state current in profile page: $state');
      final user = state.maybeWhen(
        userInfoLoaded: (user) => user, orElse: () => null);
      // if (user == null) {
      //     final supabaseUser = Supabase.instance.client.auth.currentUser;
      //     if (supabaseUser != null) {
      //       user = UserEntity(
      //         id: supabaseUser.id,
      //         email: supabaseUser.email ?? '',
      //         username: supabaseUser.userMetadata?['username'] ?? 
      //                  supabaseUser.userMetadata?['name'] ?? 
      //                  (supabaseUser.email?.split('@').first ?? 'User'),
      //       );
      //     }
      //   }
      return Container(
        margin: const EdgeInsets.only(bottom: 0),
        padding: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: ColorName.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: ColorName.black15,
              blurRadius: 25,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: nameBlockHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: avatarRadius + 5,
                    child: Column(
                      children: [
                        Text(
                          user?.username ?? 'User Name',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: ColorName.black87,
                          ),
                        ),
                        Text(
                          user?.email ?? 'email@example.com',
                          style: TextStyle(
                            color: ColorName.grey600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: -avatarRadius,
                    child: Center(child: WidgetAvatar(radius: avatarRadius)),
                  ),
                  const Positioned(
                    right: 16,
                    top: 16,
                    child: WidgetRoundIcon(icon: Icons.grid_view_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      'Trong bộ tộc Bodi Tribe (Ethiopia)...',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorName.grey800,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: ColorName.mint,
                                foregroundColor: ColorName.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Edit',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: ColorName.mint.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: ColorName.mint,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _AllTab extends StatelessWidget {
  const _AllTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
      children: const [
        WidgetSectionTitle('Friends'),
        SizedBox(height: 8),
        Row(
          children: [
            WidgetFriendAvatar(
              'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=200',
            ),
            SizedBox(width: 10),
            WidgetFriendAvatar(
              'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
            ),
            SizedBox(width: 10),
            WidgetFriendAvatar(
              'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
            ),
            SizedBox(width: 10),
            WidgetFriendAvatar(
              'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?w=200',
            ),
          ],
        ),
        SizedBox(height: 16),
        _TwoColumnStatsAndGallery(),
      ],
    );
  }
}

/// Tách khối layout 2 cột ra để gọn hơn phần trên
class _TwoColumnStatsAndGallery extends StatelessWidget {
  const _TwoColumnStatsAndGallery();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 360;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: isNarrow ? 96 : 110,
              child: const WidgetStatsCard(),
            ),
            const SizedBox(width: 16),
            const Expanded(child: WidgetGalleryGrid()),
          ],
        );
      },
    );
  }
}
