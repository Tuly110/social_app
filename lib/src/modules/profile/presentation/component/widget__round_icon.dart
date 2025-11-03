import 'package:flutter/material.dart';

class WidgetRoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const WidgetRoundIcon({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black38,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }
}
