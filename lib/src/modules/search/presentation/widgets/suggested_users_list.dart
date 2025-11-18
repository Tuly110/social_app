import 'package:flutter/material.dart';
import '../models/search_user.dart';
import 'user_item.dart';

class SuggestedUsersList extends StatelessWidget {
  final List<SearchUser> suggestedUsers;

  const SuggestedUsersList({
    super.key,
    required this.suggestedUsers,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suggestedUsers.length,
      itemBuilder: (context, index) {
        final user = suggestedUsers[index];
        return UserItem(user: user);
      },
    );
  }
}