import 'package:flutter/material.dart';
import 'widget__soft_button.dart';
import 'widget__stat.dart';

class WidgetPanelContent extends StatelessWidget {
  const WidgetPanelContent({super.key});

  @override
  Widget build(BuildContext context) {
    const mint = Color(0xFFA7C7B7);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            WidgetStat(number: '1M', label: 'Followers'),
            WidgetStat(number: '1410', label: 'Following'),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          '@Sangho2049',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          'My name is Sangho. I like Smoking and travelling\nall around the world.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, height: 1.25),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            WidgetSoftButton(
              text: 'Follow',
              background: mint,
              textColor: Colors.white,
            ),
            SizedBox(width: 12),
            WidgetSoftButton(
              text: 'Message',
              background: Colors.white,
              textColor: Colors.black87,
              hasBorder: true,
            ),
          ],
        ),
      ],
    );
  }
}
