import 'package:flutter/material.dart';

class WidgetSoftButton extends StatelessWidget {
  final String text;
  final Color background;
  final Color textColor;
  final bool hasBorder;

  const WidgetSoftButton({
    super.key,
    required this.text,
    required this.background,
    required this.textColor,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: hasBorder ? Border.all(color: const Color(0xFFE6EAEA)) : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: textColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
