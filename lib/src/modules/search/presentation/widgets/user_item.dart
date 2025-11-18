import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../generated/colors.gen.dart';
import '../models/search_user.dart';

class UserItem extends StatelessWidget {
  final SearchUser user;

  const UserItem({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorName.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorName.borderLight),
      ),
      child: Row(
        children: [
          _buildUserAvatar(),
          const SizedBox(width: 12),
          _buildUserInfo(),
          _buildFollowButton(),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: ColorName.navBackground,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          user.username[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                user.username,
                style: TextStyle(
                  color: ColorName.textBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 6),
              if (user.isVerified)
                const FaIcon(
                  FontAwesomeIcons.solidCircleCheck,
                  color: ColorName.primaryBlue,
                  size: 14,
                ),
            ],
          ),
          Text(
            user.handle,
            style: TextStyle(
              color: ColorName.textGray,
              fontSize: 14,
            ),
          ),
          Text(
            '${user.followers} followers',
            style: TextStyle(
              color: ColorName.textGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ColorName.navBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Follow',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}