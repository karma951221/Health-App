import 'package:flutter/material.dart';

class MealEntrySection extends StatelessWidget {
  const MealEntrySection({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.add_photo_alternate_outlined,
            size: 36,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('카메라'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('갤러리'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const TextField(
          maxLines: 3,
          decoration: InputDecoration(hintText: '예: 점심: 닭가슴살 샐러드'),
        ),
      ],
    );
  }
}
