// lib/src/modules/profile/presentation/following_page.dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../generated/colors.gen.dart';
import '../../app/app_router.dart';

class FollowingUserModel {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final String? bio;

  FollowingUserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.bio,
  });
}

@RoutePage()
class FollowingPage extends StatefulWidget {
  final String userId; // id của user đang xem profile (thường là current user)

  const FollowingPage({
    super.key,
    required this.userId,
  });

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  late Future<void> _future;
  final List<FollowingUserModel> _users = [];
  Set<String> _followingIds = {};
  bool _hasChanged = false; // dùng để báo về ProfilePage là có thay đổi

  @override
  void initState() {
    super.initState();
    _future = _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    final client = Supabase.instance.client;

    // 1. Lấy danh sách following_id: những người widget.userId đang follow
    final followsRes = await client
        .from('follows')
        .select('following_id')
        .eq('follower_id', widget.userId);

    final List data = (followsRes as List?) ?? [];
    if (data.isEmpty) {
      setState(() {
        _users.clear();
        _followingIds.clear();
      });
      return;
    }

    final followingIds = data
        .map((e) => e['following_id'] as String)
        .where((id) => id.isNotEmpty)
        .toList();

    // 2. Lấy profile cho từng id (song song)
    final futures = followingIds.map((id) async {
      final row = await client
          .from('profiles')
          .select('id, username, email, avatar_url, bio')
          .eq('id', id)
          .maybeSingle();

      if (row == null) return null;

      return FollowingUserModel(
        id: row['id'] as String,
        username: (row['username'] as String?) ?? '',
        email: (row['email'] as String?) ?? '',
        avatarUrl: row['avatar_url'] as String?,
        bio: row['bio'] as String?,
      );
    }).toList();

    final results = await Future.wait(futures);
    final users = results.whereType<FollowingUserModel>().toList();

    setState(() {
      _users
        ..clear()
        ..addAll(users);
      _followingIds = users.map((u) => u.id).toSet();
    });
  }

  /// 🔥 Unfollow / Follow lại (trên trang Following)
  Future<void> _toggleFollow(String targetUserId) async {
    final client = Supabase.instance.client;
    final currentUserId = client.auth.currentUser?.id;

    if (currentUserId == null || currentUserId == targetUserId) return;

    final isFollowing = _followingIds.contains(targetUserId);

    try {
      if (isFollowing) {
        // UNFOLLOW
        await client
            .from('follows')
            .delete()
            .eq('follower_id', currentUserId)
            .eq('following_id', targetUserId);

        if (!mounted) return;
        setState(() {
          _followingIds.remove(targetUserId);
          _users.removeWhere((u) => u.id == targetUserId);
          _hasChanged = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unfollowed')),
        );
      } else {
        // FOLLOW lại
        await client.from('follows').insert({
          'follower_id': currentUserId,
          'following_id': targetUserId,
        });

        if (!mounted) return;
        setState(() {
          _followingIds.add(targetUserId);
          _hasChanged = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Followed')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final currentUserId = client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
        backgroundColor: ColorName.mint,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.router.pop(_hasChanged);
          },
        ),
      ),
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              _users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Text(
                'Error: ${snap.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (_users.isEmpty) {
            return const Center(
              child: Text('You are not following anyone yet'),
            );
          }

          return ListView.separated(
            itemCount: _users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final u = _users[index];
              final isMe = (currentUserId == u.id);
              final isFollowing = _followingIds.contains(u.id);

              return ListTile(
                leading: GestureDetector(
                  onTap: () {
                    context.router.push(UserProfileRoute(userId: u.id));
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        (u.avatarUrl != null && u.avatarUrl!.isNotEmpty)
                            ? NetworkImage(u.avatarUrl!)
                            : null,
                    child: (u.avatarUrl == null || u.avatarUrl!.isEmpty)
                        ? Text(
                            u.username.isNotEmpty
                                ? u.username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                title: GestureDetector(
                  onTap: () {
                    context.router.push(UserProfileRoute(userId: u.id));
                  },
                  child: Text(u.username),
                ),
                subtitle: Text(
                  u.bio?.isNotEmpty == true ? u.bio! : u.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: (currentUserId == null || isMe)
                    ? null
                    : TextButton(
                        onPressed: () => _toggleFollow(u.id),
                        child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
  