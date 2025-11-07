import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';
import 'widgets/post_list.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorName.backgroundWhite,
        elevation: 1,
        title: GestureDetector(
          onTap: () {
            print('Profile icon tapped - would navigate to profile');
          },
          child: const Icon(
            Iconsax.profile_circle,
            color: Colors.black,
            size: 32,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Iconsax.notification, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ColorName.borderLight, width: 0.5),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: ColorName.primaryBlue,
              labelColor: ColorName.textBlack,
              unselectedLabelColor: ColorName.textGray,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: 'For You'),
                Tab(text: 'Following'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PostList(),
          PostList(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: ColorName.borderLight, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: ColorName.navBackground,
        selectedItemColor: ColorName.textGray,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          color: ColorName.textGray,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            activeIcon: Icon(Iconsax.home_15),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.search_normal),
            activeIcon: Icon(Iconsax.search_normal_1),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.add_square),
            activeIcon: Icon(Iconsax.add_square5),
            label: 'New Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.message),
            activeIcon: Icon(Iconsax.message5),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.notification),
            activeIcon: Icon(Iconsax.notification5),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.profile_circle),
            activeIcon: Icon(Iconsax.profile_circle5),
            label: 'Profile',
          ),
        ],
      ),
    );

  }
}