import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';
import '../../../app/app_router.dart';
import '../../../../core/data/api/profile_api_models.dart';

class WidgetStatsCard extends StatelessWidget {
  final ProfileModel? profile;

  const WidgetStatsCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final p = profile;

    if (p == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: ColorName.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ColorName.black15,
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _StatBlock(
            count: "${p.postCount}",
            label: "Likes",
            onTap: () {},
          ),
          const Divider(height: 28),
          _StatBlock(
            count: "${p.followingCount}",
            label: "Following",
            onTap: () {
              context.router.push(
                FollowingRoute(
                  userId: p.id,
                  username: p.username,
                ),
              );
            },
          ),
          const Divider(height: 28),
          _StatBlock(
            count: "${p.followerCount}",
            label: "Followers",
            onTap: () {
              context.router.push(
                FollowersRoute(
                  userId: p.id,
                  username: p.username,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String count;
  final String label;
  final VoidCallback onTap;

  const _StatBlock({
    super.key,
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColorName.black87,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: ColorName.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
