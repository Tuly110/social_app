import 'package:flutter/material.dart';
import 'package:jupyternotebook/generated/colors.gen.dart'; // đổi lại đúng package của bạn
import 'widget__soft_button.dart';
import 'widget__stat.dart';

class WidgetPanelContent extends StatelessWidget {
  const WidgetPanelContent({super.key});

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: ColorName.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'My name is Sangho. I like Smoking and travelling\nall around the world.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ColorName.grey700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            WidgetSoftButton(
              text: 'Follow',
              background: ColorName.mintA7c7b7,
              textColor: ColorName.white,
            ),
            SizedBox(width: 12),
            WidgetSoftButton(
              text: 'Message',
              background: ColorName.white,
              textColor: ColorName.black87,
              hasBorder: true,
            ),
          ],
        ),
      ],
    );
  }
}
