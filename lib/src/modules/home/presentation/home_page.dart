import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../generated/colors.gen.dart';
import 'widgets/post_list.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
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
            FontAwesomeIcons.userCircle,
            color: Colors.black,
            size: 32,
          ),
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.magnifyingGlass,
                color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bell, color: Colors.black),
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
    );
  }
}
