import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../generated/colors.gen.dart';
import 'widgets/search_app_bar.dart';
import 'widgets/trending_topics_list.dart';
import 'widgets/suggested_users_list.dart';
import 'widgets/search_results_list.dart';
import 'widgets/media_results.dart';
import 'models/trending_topic.dart';
import 'models/search_user.dart';

@RoutePage()
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';

  // Mock data
  final List<TrendingTopic> _trendingTopics = [
    TrendingTopic(
      category: 'Technology',
      title: 'Flutter',
      postsCount: '25.4K',
    ),
    TrendingTopic(
      category: 'Sports',
      title: 'Premier League',
      postsCount: '45.2K',
    ),
    TrendingTopic(
      category: 'Entertainment',
      title: '#NewMovie',
      postsCount: '12.7K',
    ),
    TrendingTopic(
      category: 'Politics',
      title: 'Election 2024',
      postsCount: '89.1K',
    ),
    TrendingTopic(
      category: 'Gaming',
      title: 'New Game Release',
      postsCount: '18.3K',
    ),
  ];

  final List<SearchUser> _suggestedUsers = [
    SearchUser(
      username: 'tech_guru',
      handle: '@techguru',
      isVerified: true,
      followers: '125K',
    ),
    SearchUser(
      username: 'flutter_dev',
      handle: '@flutterdev',
      isVerified: false,
      followers: '45.2K',
    ),
    SearchUser(
      username: 'design_master',
      handle: '@designmaster',
      isVerified: true,
      followers: '89.7K',
    ),
    SearchUser(
      username: 'coding_wizard',
      handle: '@codingwizard',
      isVerified: false,
      followers: '67.3K',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _performSearch() {
    print('Searching for: $_searchQuery');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorName.backgroundWhite,
      appBar: SearchAppBar(
        searchController: _searchController,
        searchQuery: _searchQuery,
        tabController: _tabController,
        onClearSearch: _clearSearch,
        onPerformSearch: _performSearch,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TrendingTopicsList(trendingTopics: _trendingTopics),
          SearchResultsList(searchQuery: _searchQuery),
          SuggestedUsersList(suggestedUsers: _suggestedUsers),
          const MediaResults(),
        ],
      ),
    );
  }
}