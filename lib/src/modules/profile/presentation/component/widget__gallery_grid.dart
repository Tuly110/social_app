import 'package:flutter/material.dart';
import 'widget__section_title.dart';

class WidgetGalleryGrid extends StatelessWidget {
  final List<String> imageUrls;

  const WidgetGalleryGrid({
    super.key,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WidgetSectionTitle('Gallery'),
        const SizedBox(height: 8),
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1,
          children: imageUrls
              .map((url) => ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(url, fit: BoxFit.cover),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
