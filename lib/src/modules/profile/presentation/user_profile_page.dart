import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

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
            _TabAndContent(),
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
          // 1️⃣ COVER (nằm dưới)
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

          // 2️⃣ NÚT BACK / ACTION
          Positioned(
            left: 16,
            top: top + 12,
            child: const _CircleIcon(icon: Icons.arrow_back),
          ),
          Positioned(
            right: 16,
            top: top + 12,
            child: const _CircleIcon(icon: Icons.mail_outline),
          ),

          // 3️⃣ PANEL TRẮNG (đè lên cover)
          Positioned(
            left: 0,
            right: 0,
            top: panelTop,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, avatarRadius + 18, 16, 16),
              decoration: BoxDecoration(
                color: UserProfilePage._bg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: const _PanelContent(),
            ),
          ),

          // 4️⃣ AVATAR (chồng mép panel)
          Positioned(
            top: panelTop - avatarRadius,
            left: 0,
            right: 0,
            child: _Avatar(radius: avatarRadius),
          ),
        ],
      ),
    );
  }
}

class _PanelContent extends StatelessWidget {
  const _PanelContent();

  @override
  Widget build(BuildContext context) {
    const mint = Color(0xFFA7C7B7);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _Stat(number: '1M', label: 'Followers'),
            _Stat(number: '1410', label: 'Following'),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          '@Sangho2049',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          'My name is Sangho. I like Smoking and travelling\nall around the world.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, height: 1.25),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _SoftButton(
              text: 'Follow',
              background: mint,
              textColor: Colors.white,
            ),
            SizedBox(width: 12),
            _SoftButton(
              text: 'Message',
              background: Colors.white,
              textColor: Colors.black87,
              hasBorder: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _TabAndContent extends StatelessWidget {
  const _TabAndContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9F9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black45,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 2, color: Colors.black),
              insets: EdgeInsets.symmetric(horizontal: 22),
            ),
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Photos'),
              Tab(text: 'Videos'),
            ],
          ),
        ),
        SizedBox(
          height: 700,
          child: const TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              _RoundedGallery(images: _demoImages),
              _RoundedGallery(images: _demoImagesPhotos),
              Center(child: Text('Videos — Coming soon')),
            ],
          ),
        ),
      ],
    );
  }
}

const _demoImages = [
  '',
  'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200',
  'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1200',
  'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=1200',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=1200',
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=1200',
];

const _demoImagesPhotos = [
  'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?w=1200',
  'https://images.unsplash.com/photo-1595341888016-a392ef81b7de?w=1200',
  'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?w=1200',
  'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=1200',
];

class _RoundedGallery extends StatelessWidget {
  final List<String> images;
  const _RoundedGallery({required this.images});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(images[i], fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircleIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 6,
      child: InkWell(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final double radius;
  const _Avatar({required this.radius});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.15),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const CircleAvatar(
          radius: 36,
          backgroundImage: NetworkImage(
            'https://images.unsplash.com/photo-1672087537910-3644f885e9bc?w=1200',
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String number, label;
  const _Stat({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
      ],
    );
  }
}

class _SoftButton extends StatelessWidget {
  final String text;
  final Color background;
  final Color textColor;
  final bool hasBorder;

  const _SoftButton({
    required this.text,
    required this.background,
    required this.textColor,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: hasBorder ? Border.all(color: const Color(0xFFE6EAEA)) : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: textColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
