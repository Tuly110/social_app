import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
        backgroundColor: Colors.white,
        elevation: 1,
        title: GestureDetector(
          onTap: () {
            // Placeholder for profile navigation
            print('Profile icon tapped - would navigate to profile');
          },
          child: const Icon(
            Iconsax.profile_circle,
            color: Colors.black,
            size: 32,
          ),
        ),
        
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF1D9BF0),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
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
          _PostList(),
          _PostList(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFFA4C3B4), // Light green background
        selectedItemColor: Colors.grey, // Selected item color
        unselectedItemColor: Colors.white, // Unselected item color
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
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

class _PostList extends StatefulWidget {
  const _PostList();

  @override
  State<_PostList> createState() => _PostListState();
}

class _PostListState extends State<_PostList> {
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
          _PostItem(
            postData: _posts[i],
            onLikePressed: () => _toggleLike(i),
            onRepostPressed: () => _toggleRepost(i),
            onCommentPressed: () => _openComments(i, context),
          ),
      ],
    );
  }
}

class PostData {
  final String username;
  final String handle;
  final String time;
  final String content;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final bool isReposted;
  final bool showThread;

  const PostData({
    required this.username,
    required this.handle,
    required this.time,
    required this.content,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isLiked,
    required this.isReposted,
    this.showThread = false,
  });

  PostData copyWith({
    String? username,
    String? handle,
    String? time,
    String? content,
    int? likes,
    int? comments,
    int? shares,
    bool? isLiked,
    bool? isReposted,
    bool? showThread,
  }) {
    return PostData(
      username: username ?? this.username,
      handle: handle ?? this.handle,
      time: time ?? this.time,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
      showThread: showThread ?? this.showThread,
    );
  }
}

class _PostItem extends StatelessWidget {
  final PostData postData;
  final VoidCallback onLikePressed;
  final VoidCallback onRepostPressed;
  final VoidCallback onCommentPressed;

  const _PostItem({
    required this.postData,
    required this.onLikePressed,
    required this.onRepostPressed,
    required this.onCommentPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1D9BF0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                postData.username[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with username, handle, time
                Row(
                  children: [
                    Text(
                      postData.username,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${postData.handle} · ${postData.time}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Content text
                Text(
                  postData.content,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                // Show thread button (if applicable)
                if (postData.showThread)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: const Text(
                      'Show this thread',
                      style: TextStyle(
                        color: Color(0xFF1D9BF0),
                        fontSize: 14,
                      ),
                    ),
                  ),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CommentButton(
                      commentCount: postData.comments,
                      onPressed: onCommentPressed,
                    ),
                    _RepostButton(
                      isReposted: postData.isReposted,
                      repostCount: postData.shares,
                      onPressed: onRepostPressed,
                    ),
                    _LikeButton(
                      isLiked: postData.isLiked,
                      likeCount: postData.likes,
                      onPressed: onLikePressed,
                    ),
                    _ActionButton(
                      icon: Iconsax.share,
                      onPressed: () {},
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
}

class _CommentButton extends StatelessWidget {
  final int commentCount;
  final VoidCallback onPressed;

  const _CommentButton({
    required this.commentCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(
            Iconsax.message,
            color: Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            _formatCount(commentCount),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}

class _RepostButton extends StatefulWidget {
  final bool isReposted;
  final int repostCount;
  final VoidCallback onPressed;

  const _RepostButton({
    required this.isReposted,
    required this.repostCount,
    required this.onPressed,
  });

  @override
  State<_RepostButton> createState() => _RepostButtonState();
}

class _RepostButtonState extends State<_RepostButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: Color(0xFF00FF00), // Green color for repost
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Set initial state
    if (widget.isReposted) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_RepostButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReposted != oldWidget.isReposted) {
      if (widget.isReposted) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isReposted) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Row(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return Icon(
                  widget.isReposted ? Iconsax.repeat5 : Iconsax.repeat,
                  color: _colorAnimation.value,
                  size: 18,
                );
              },
            ),
          ),
          const SizedBox(width: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: widget.isReposted ? Color(0xFF00FF00) : Colors.grey, // Green color
              fontSize: 13,
            ),
            child: Text(
              _formatCount(widget.repostCount),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}

class _LikeButton extends StatefulWidget {
  final bool isLiked;
  final int likeCount;
  final VoidCallback onPressed;

  const _LikeButton({
    required this.isLiked,
    required this.likeCount,
    required this.onPressed,
  });

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.red, // Red color for heart
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Set initial state
    if (widget.isLiked) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked != oldWidget.isLiked) {
      if (widget.isLiked) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isLiked) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Row(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return Icon(
                  widget.isLiked ? Iconsax.heart5 : Iconsax.heart,
                  color: _colorAnimation.value,
                  size: 18,
                );
              },
            ),
          ),
          const SizedBox(width: 6),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: widget.isLiked ? Colors.red : Colors.grey, // Red color
              fontSize: 13,
            ),
            child: Text(
              _formatCount(widget.likeCount),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final int? count;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    this.count,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey,
            size: 18,
          ),
          if (count != null) ...[
            const SizedBox(width: 6),
            Text(
              _formatCount(count!),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}

// Comments Page with Light Mode
class CommentsPage extends StatefulWidget {
  final PostData post;
  final VoidCallback onLikePressed;

  const CommentsPage({
    required this.post,
    required this.onLikePressed,
  });

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final List<CommentData> _comments = [
    CommentData(
      username: 'user1',
      handle: '@user1',
      time: '2h',
      content: 'Great post! I totally agree with this.',
      likes: 5,
      isLiked: false,
    ),
    CommentData(
      username: 'user2',
      handle: '@user2',
      time: '1h',
      content: 'Thanks for sharing this information!',
      likes: 3,
      isLiked: true,
    ),
    CommentData(
      username: 'user3',
      handle: '@user3',
      time: '30m',
      content: 'This is very helpful, thank you!',
      likes: 1,
      isLiked: false,
    ),
  ];

  void _toggleCommentLike(int index) {
    setState(() {
      _comments[index] = _comments[index].copyWith(
        isLiked: !_comments[index].isLiked,
        likes: _comments[index].isLiked 
            ? _comments[index].likes - 1 
            : _comments[index].likes + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Comments',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Original Post
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D9BF0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      widget.post.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.post.username,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.post.handle} · ${widget.post.time}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.post.content,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _CommentButton(
                            commentCount: widget.post.comments,
                            onPressed: () {},
                          ),
                          _RepostButton(
                            isReposted: widget.post.isReposted,
                            repostCount: widget.post.shares,
                            onPressed: () {},
                          ),
                          _LikeButton(
                            isLiked: widget.post.isLiked,
                            likeCount: widget.post.likes,
                            onPressed: widget.onLikePressed,
                          ),
                          _ActionButton(
                            icon: Iconsax.share,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Comments List
          Expanded(
            child: ListView(
              children: [
                for (int i = 0; i < _comments.length; i++)
                  _CommentItem(
                    comment: _comments[i],
                    onLikePressed: () => _toggleCommentLike(i),
                  ),
              ],
            ),
          ),
          // Add Comment Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFF1D9BF0)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Iconsax.send1, color: Color(0xFF1D9BF0)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentData {
  final String username;
  final String handle;
  final String time;
  final String content;
  final int likes;
  final bool isLiked;

  const CommentData({
    required this.username,
    required this.handle,
    required this.time,
    required this.content,
    required this.likes,
    required this.isLiked,
  });

  CommentData copyWith({
    String? username,
    String? handle,
    String? time,
    String? content,
    int? likes,
    bool? isLiked,
  }) {
    return CommentData(
      username: username ?? this.username,
      handle: handle ?? this.handle,
      time: time ?? this.time,
      content: content ?? this.content,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class _CommentItem extends StatelessWidget {
  final CommentData comment;
  final VoidCallback onLikePressed;

  const _CommentItem({
    required this.comment,
    required this.onLikePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E5E5), width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1D9BF0), // Blue color for comments
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                comment.username[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${comment.handle} · ${comment.time}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _LikeButton(
                      isLiked: comment.isLiked,
                      likeCount: comment.likes,
                      onPressed: onLikePressed,
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
}