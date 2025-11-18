import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../generated/colors.gen.dart';
import 'models/post_data.dart';
import 'widgets/create_post_app_bar.dart';
import 'widgets/post_action_bar.dart';
import 'widgets/post_content_field.dart';

@RoutePage()
class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _postController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _characterCount = 0;
  final int _maxCharacters = 280;
  bool _isPublic = true;

  // Mock user data
  final String _currentUsername = 'abcde';
  final String _currentHandle = '@abcde';

  @override
  void initState() {
    super.initState();
    _postController.addListener(_updateCharacterCount);
  }

  @override
  void dispose() {
    _postController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _postController.text.length;
    });
  }

  void _createPost() {
    final String content = _postController.text.trim();
    
    if (content.isEmpty) {
      _showErrorDialog('Please write something before posting.');
      return;
    }

    if (content.length > _maxCharacters) {
      _showErrorDialog('Post exceeds the character limit of $_maxCharacters.');
      return;
    }

    // Create new post
    final newPost = PostData(
      username: _currentUsername,
      handle: _currentHandle,
      time: 'Now',
      content: content,
      likes: 0,
      comments: 0,
      shares: 0,
      isLiked: false,
      isReposted: false,
      isPublic: _isPublic,
    );

    _postController.clear();

    // Show success message
    _showSuccessDialog();
    
    AutoTabsRouter.of(context).setActiveIndex(0);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cannot Post'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => AutoTabsRouter.of(context).setActiveIndex(0),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post created successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: 100,
          left: 20,
          right: 20,
        ),
      ),
    );
  }

  void _clearPost() {
    _postController.clear();
  }

  void _togglePrivacy() {
    setState(() {
      _isPublic = !_isPublic;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canPost = _postController.text.trim().isNotEmpty &&
        _postController.text.length <= _maxCharacters;

    return Scaffold(
      backgroundColor: ColorName.backgroundWhite,
      appBar: CreatePostAppBar(
        canPost: canPost,
        onPostPressed: _createPost,
        onBackPressed: () => AutoTabsRouter.of(context).setActiveIndex(0),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: PostContentField(
                postController: _postController,
                focusNode: _focusNode,
                currentUsername: _currentUsername,
                currentHandle: _currentHandle,
                isPublic: _isPublic,
                onPrivacyChanged: _togglePrivacy,
                characterCount: _characterCount,
                maxCharacters: _maxCharacters,
              ),
            ),
          ),
          PostActionBar(
            postController: _postController,
            onClearPost: _clearPost,
            onAddPhoto: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Photo picker coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            onAddMention: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mention coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            onAddEmoji: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emoji picker coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}