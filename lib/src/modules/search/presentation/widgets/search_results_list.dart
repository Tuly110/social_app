import 'package:flutter/material.dart';
import '../../../home/presentation/models/post_data.dart';
import '../../../home/presentation/widgets/post_item.dart';

class SearchResultsList extends StatelessWidget {
  final String searchQuery;

  const SearchResultsList({
    super.key,
    required this.searchQuery,
  });

  // Mock search results - In real app, this would come from API
  List<PostData> get _searchResults => [
    PostData(
      username: 'tech_guru',
      time: '2h',
      content: 'Just built an amazing Flutter app with the new features! #Flutter #Dart',
      likes: 245,
      comments: 34,
      shares: 12,
      isLiked: false,
      isReposted: false,
      isPublic: true,

    ),
    PostData(
      username: 'flutter_dev',
      time: '4h',
      content: 'Anyone else excited about the Flutter 3.0 release? The performance improvements are incredible!',
      likes: 567,
      comments: 89,
      shares: 45,
      isLiked: true,
      isReposted: false,
      isPublic: true,
    ),
    PostData(
      username: 'coding_wizard',
      time: '6h',
      content: 'Working on a new social media app with Flutter. The hot reload feature is a game-changer!',
      likes: 123,
      comments: 23,
      shares: 8,
      isLiked: false,
      isReposted: true,
      isPublic: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (searchQuery.isEmpty) {
      return const Center(
        child: Text('Enter a search term to see results'),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final post = _searchResults[index];
        return PostItem(
          postData: post,
          onLikePressed: () {
            // Handle like
          },
          onRepostPressed: () {
            // Handle repost
          },
          onCommentPressed: () {
            // Handle comment
          },
        );
      },
    );
  }
}