import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../generated/colors.gen.dart';
import 'widgets/post_list.dart';

import '../../newpost/presentation/models/post_api_models.dart';
import '../../../modules/app/app_router.dart';

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

  /// Token dùng để force rebuild PostList (đổi key)
  int _reloadToken = 0;

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

  Future<void> _openCreatePost() async {
    // Mở màn tạo post và CHỜ kết quả trả về (PostResponse)
    final newPost = await context.router.push<PostResponse>(
      const CreatePostRoute(),
    );

    // Nếu user bấm back không đăng gì thì newPost = null
    if (newPost == null) return;

    // Tăng token để PostList rebuild lại (gọi API lại bên trong PostList)
    setState(() {
      _reloadToken++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorName.backgroundWhite,
        elevation: 1,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'City',
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                text: ' Life',
                style: TextStyle(color: ColorName.mint),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.bell,
                    color: Colors.black,
                    size: 20,
                  ),
                  onPressed: () {
                    // TODO: route notification
                  },
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    // TODO: route profile
                  },
                  child: const Icon(
                    FontAwesomeIcons.userCircle,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: ColorName.borderLight,
                  width: 0.5,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: ColorName.mint,
              labelColor: ColorName.textBlack,
              unselectedLabelColor: ColorName.textGray,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
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
        children: [
          // dùng key để khi _reloadToken đổi thì PostList được recreate, initState chạy lại
          PostList(key: ValueKey('forYou_$_reloadToken')),
          PostList(key: ValueKey('following_$_reloadToken')),
        ],
      ),

      // Bạn có thể thay FAB này bằng nút + ở bottom bar nếu muốn
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePost,
        backgroundColor: ColorName.mint,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
