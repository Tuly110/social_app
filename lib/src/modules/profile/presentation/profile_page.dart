import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const _mint = Color(0xFFA7C7B7);
  static const _softBg = Color(0xFFF5F6F8);

  static const double _avatarRadius = 38;
  static const double _horizontalMargin = 24;
  static const double _tabBarHeight = 48;

  static final double _expandedHeight = 310 + _avatarRadius * 1.5;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: _softBg,
        body: NestedScrollView(
          headerSliverBuilder: (context, inner) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: _expandedHeight, // Dùng chiều cao đã tăng
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: inner ? Colors.black87 : Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.more_horiz,
                      color: inner ? Colors.black87 : Colors.white),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover
                    Image.network(
                      'https://images.unsplash.com/photo-1495562569060-2eec283d3391?q=80&w=1600&auto=format&fit=crop',
                      fit: BoxFit.cover,
                    ),
                    // gradient che dưới
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black26],
                        ),
                      ),
                    ),
                    // KHỐI CARD PROFILE (Nổi)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        // Dùng Padding để điều chỉnh vị trí Card
                        padding: EdgeInsets.only(
                          left: _horizontalMargin,
                          right: _horizontalMargin,
                          // !!! ĐIỀU CHỈNH: Kéo Card lên 1/2 bán kính Avatar + khoảng trống
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
                  color: Colors.white,
                  child: const TabBar(
                    isScrollable: true,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    indicatorColor: Colors.black,
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
          // TabBarView cuộn ở body
          body: const TabBarView(
            children: [
              _AllTab(),
              _PlaceHolder(text: 'Post'),
              _PlaceHolder(text: 'Replies'),
              _PlaceHolder(text: 'Media'),
              _PlaceHolder(text: 'About'),
            ],
          ),
        ),
        // Giữ nguyên Bottom Navigation Bar
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
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline), label: ''),
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

class _ProfileCard extends StatelessWidget {
  final double avatarRadius;

  static const _mint = Color(0xFFA7C7B7);

  const _ProfileCard({required this.avatarRadius});

  @override
  Widget build(BuildContext context) {
    final double nameBlockTopPadding = 18;
    final double nameBlockHeight =
        (2 * avatarRadius) + nameBlockTopPadding + 10;

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
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
                      const Text('SangHo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          )),
                      Text(
                        'sangho2049@mastodon', // Handle
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // AVATAR
                Positioned(
                  left: 0,
                  right: 0,
                  top: -avatarRadius,
                  child: Center(child: _Avatar(radius: avatarRadius)),
                ),
                // Icon Cluster/Setting
                const Positioned(
                  right: 16,
                  top: 16,
                  child: _RoundIcon(
                    icon: Icons.grid_view_rounded,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Bio Text (Căn giữa)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    'Trong bộ tộc Bodi Tribe (Ethiopia), những người đàn ông bụng to '
                    'được cho là rất đẹp trai và quyền lực. Nếu họ có cái bụng béo nhất '
                    'làng sẽ được các cô gái theo đuổi.',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Hàng nút Edit và Send
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nút Edit
                      Expanded(
                        child: SizedBox(
                          height: 42,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: _mint,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Edit',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Nút Send Icon
                      InkWell(
                        onTap: () {},
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _mint.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              Icon(Icons.send_rounded, color: _mint, size: 20),
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
  }
}

class _AllTab extends StatelessWidget {
  const _AllTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
      children: [
        // Hàng Friends
        _SectionTitle('Friends'),
        const SizedBox(height: 8),
        Row(
          children: const [
            _FriendAvatar(
                'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=200'),
            SizedBox(width: 10),
            _FriendAvatar(
                'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200'),
            SizedBox(width: 10),
            _FriendAvatar(
                'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200'),
            SizedBox(width: 10),
            _FriendAvatar(
                'https://images.unsplash.com/photo-1520813792240-56fc4a3765a7?w=200'),
          ],
        ),
        const SizedBox(height: 16),

        // layout 2 cột: Stats bên trái + Gallery bên phải
        LayoutBuilder(
          builder: (context, c) {
            final isNarrow = c.maxWidth < 360;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: isNarrow ? 96 : 110,
                  child: const _StatsCard(),
                ),
                const SizedBox(width: 16),
                Expanded(child: _GalleryGrid()),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final double radius;

  const _Avatar({required this.radius});

  @override
  Widget build(BuildContext context) {
    const _avatarUrl =
        'https://images.unsplash.com/photo-1660304755869-325c2ff6f02d?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1118';
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundImage: const NetworkImage(_avatarUrl),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black38,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1),
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  final String url;
  const _FriendAvatar(this.url);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundImage: NetworkImage(url),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    Widget item(String value, String label) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        );

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            item('1K', 'Likes'),
            _Divider(),
            item('120', 'Following'),
            _Divider(),
            item('1.2K', 'Followers'),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Container(
        height: 1,
        color: Colors.grey.shade200,
        margin: const EdgeInsets.symmetric(horizontal: 14),
      ),
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  final _images = const [
    'https://images.unsplash.com/photo-1595341888016-a392ef81b7de?w=800',
    'https://images.unsplash.com/photo-1495567720989-cebdbdd97913?w=800',
    'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?w=800',
    'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=800',
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=800',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Gallery'),
        const SizedBox(height: 8),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1,
          children: _images
              .map((u) => ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(u, fit: BoxFit.cover),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

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
