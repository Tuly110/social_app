import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../generated/colors.gen.dart';
import '../../../core/data/api/profile_api.dart';
import '../../../core/data/api/profile_api_models.dart';
import '../../app/app_router.dart';

@RoutePage()
class FollowersPage extends StatefulWidget {
  final String userId;
  final String username;

  const FollowersPage({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  late final ProfileApi _api;
  late Future<List<ProfileModel>> _future;

  @override
  void initState() {
    super.initState();
    _api = ProfileApi(baseUrl: 'http://10.0.2.2:8001');
    _future = _api.getFollowers(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text('Followers of ${widget.username}'),
        backgroundColor: ColorName.backgroundWhite,
      ),
      body: FutureBuilder<List<ProfileModel>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Text('Lỗi tải followers:\n${snap.error}'),
            );
          }

          final users = snap.data ?? [];

          if (users.isEmpty) {
            return const Center(child: Text('Chưa có ai theo dõi.'));
          }

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, i) {
              final u = users[i];
              final isMe = currentUserId == u.id;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: ColorName.mint.withOpacity(0.2),
                  backgroundImage: u.avatarUrl != null && u.avatarUrl!.isNotEmpty
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
                title: Text(
                  u.username,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: (u.bio != null && u.bio!.isNotEmpty)
                    ? Text(
                        u.bio!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                onTap: () {
                  if (isMe) {
                    context.router.navigate(const ProfileRoute());
                  } else {
                    context.router.push(UserProfileRoute(userId: u.id));
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
