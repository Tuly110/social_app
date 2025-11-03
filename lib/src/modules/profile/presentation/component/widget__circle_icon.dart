import 'package:flutter/material.dart';

class WidgetCircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const WidgetCircleIcon({required this.icon, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.black87),
        ),
      ),
    );
  }
}
