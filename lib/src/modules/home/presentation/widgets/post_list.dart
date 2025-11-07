import 'package:flutter/material.dart';
import '../models/post_data.dart';
import 'post_item.dart';
import '../pages/comments_page.dart';

class PostList extends StatefulWidget {
  const PostList({super.key});

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final List<PostData> _posts = [
    PostData(
      username: 'abc',
      handle: '@abcne',
      time: '12h',
      content: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard? #TellMeAboutYou',
      likes: 28,
      comments: 5,
      shares: 21,
      isLiked: true,
      isReposted: false,
      showThread: true,
    ),
    PostData(
      username: 'xyz',
      handle: '@xyz123',
      time: '3h',
      content: 'Hello là xin chào. #Hello',
      likes: 46,
      comments: 18,
      shares: 363,
      isLiked: true,
      isReposted: true,
    ),
    PostData(
      username: 'student',
      handle: '@student1',
      time: '14h',
      content: 'Kobe\'s passing is really sticking w/ me in a way I didn\'t expect.\n\nHe was an icon, the kind of person who wouldn\'t die this way. My wife compared it to Princess Di\'s accident.\n\nBut the end can happen for anyone at any time, & I can\'t help but think of anything else lately.',
      likes: 7,
      comments: 1,
      shares: 11,
      isLiked: false,
      isReposted: false,
    ),
    PostData(
      username: 'karennne',
      handle: '@karennne',
      time: '10h',
      content: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text over since the 1500s.',
      likes: 0,
      comments: 0,
      shares: 0,
      isLiked: false,
      isReposted: false,
    ),
  ];

  void _toggleLike(int index) {
    setState(() {
      _posts[index] = _posts[index].copyWith(
        isLiked: !_posts[index].isLiked,
        likes: _posts[index].isLiked 
            ? _posts[index].likes - 1 
            : _posts[index].likes + 1,
      );
    });
  }

  void _toggleRepost(int index) {
    setState(() {
      _posts[index] = _posts[index].copyWith(
        isReposted: !_posts[index].isReposted,
        shares: _posts[index].isReposted 
            ? _posts[index].shares - 1 
            : _posts[index].shares + 1,
      );
    });
  }

  void _openComments(int index, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsPage(
          post: _posts[index],
          onLikePressed: () => _toggleLike(index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        for (int i = 0; i < _posts.length; i++)
          PostItem(
            postData: _posts[i],
            onLikePressed: () => _toggleLike(i),
            onRepostPressed: () => _toggleRepost(i),
            onCommentPressed: () => _openComments(i, context),
          ),
      ],
    );
  }
}