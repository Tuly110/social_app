import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../generated/colors.gen.dart';
import 'models/post_data.dart';

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
          bottom: 100, // Điều chỉnh vị trí
          left: 20,
          right: 20,
        ),
      ),
    );
  }

  void _clearPost() {
    _postController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bool canPost = _postController.text.trim().isNotEmpty &&
        _postController.text.length <= _maxCharacters;

    return Scaffold(
      backgroundColor: ColorName.backgroundWhite,
      appBar: AppBar(
        backgroundColor: ColorName.backgroundWhite,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => AutoTabsRouter.of(context).setActiveIndex(0),
        ),
        title: Text(
          'Create Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorName.textBlack,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: canPost ? _createPost : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canPost ? ColorName.navBackground : Colors.grey,
                foregroundColor: ColorName.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: const Text(
                'Post',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info and avatar
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Avatar
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: ColorName.primaryBlue,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            _currentUsername[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // User info and text field
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User name and handle
                            Row(
                              children: [
                                Text(
                                  _currentUsername,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorName.textBlack,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _currentHandle,
                                  style: TextStyle(
                                    color: ColorName.textGray,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Text field
                            TextField(
                              controller: _postController,
                              focusNode: _focusNode,
                              maxLines: null,
                              style: TextStyle(
                                color: ColorName.textBlack,
                                fontSize: 18,
                              ),
                              decoration: const InputDecoration(
                                hintText: "What's happening?",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Character count
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$_characterCount/$_maxCharacters',
                      style: TextStyle(
                        color: _characterCount > _maxCharacters
                            ? Colors.red
                            : ColorName.textGray,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom action bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.blueGrey, width: 0.5),
              ),
            ),
            child: Column(
              children: [
                // Action buttons row
                Row(
                  children: [
                    // Add photo
                    _buildActionButton(
                      icon: FontAwesomeIcons.image,
                      color: ColorName.navBackground,
                      onPressed: () {
                        // TODO: Implement photo picker
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Photo picker coming soon!'), duration: Duration(seconds: 2),),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                                                                                             
                    // Add mention
                    _buildActionButton(
                      icon: FontAwesomeIcons.at,
                      color: ColorName.navBackground,
                      onPressed: () {
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mention coming soon!'),duration: Duration(seconds: 2),),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    
                    // Add emoji
                    _buildActionButton(
                      icon: FontAwesomeIcons.faceSmile,
                      color: ColorName.navBackground,
                      onPressed: () {
                        // TODO: Implement emoji picker
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Emoji picker coming soon!'),duration: Duration(seconds: 2),),
                        );
                      },
                    ),
                    
                    const Spacer(),
                    
                    // Clear button
                    if (_postController.text.isNotEmpty)
                      _buildActionButton(
                        icon: FontAwesomeIcons.trash,
                        onPressed: _clearPost,
                        color: Colors.red,
                      ),
                  ],
                ),
                
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: FaIcon(
        icon,
        color: color ?? ColorName.primaryBlue,
        size: 20,
      ),
      splashRadius: 20,
    );
  }
}