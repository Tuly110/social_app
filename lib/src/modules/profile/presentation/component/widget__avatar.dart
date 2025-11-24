import 'package:flutter/material.dart';

class WidgetAvatar extends StatelessWidget {
  final double radius;
  final String? imageUrl;

  const WidgetAvatar({
    super.key,
    required this.radius,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;

    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(url),
      );
    }

    // fallback nếu chưa có avatar
    return CircleAvatar(
      radius: radius,
      child: const Icon(Icons.person, size: 30),
    );
  }
}
