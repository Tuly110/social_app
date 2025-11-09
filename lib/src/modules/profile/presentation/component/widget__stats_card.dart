import 'package:flutter/material.dart';

import '../../../../../generated/colors.gen.dart';


class WidgetStatsCard extends StatelessWidget {
  const WidgetStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    Widget item(String value, String label) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(color: ColorName.grey600, fontSize: 12)),
          ],
        );

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: ColorName.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            item('1K', 'Likes'),
            const WidgetDivider(),
            item('120', 'Following'),
            const WidgetDivider(),
            item('1.2K', 'Followers'),
          ],
        ),
      ),
    );
  }
}

// ✅ divider tách riêng cho dễ tái sử dụng
class WidgetDivider extends StatelessWidget {
  const WidgetDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Container(
        height: 1,
        color: ColorName.greyE5e7eb,
        margin: const EdgeInsets.symmetric(horizontal: 14),
      ),
    );
  }
}
