import 'package:flutter/material.dart';

class MealThumb extends StatelessWidget {
  const MealThumb({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final icons = [
      Icons.breakfast_dining_outlined,
      Icons.lunch_dining_outlined,
      Icons.dinner_dining_outlined,
    ];

    return Icon(icons[index % icons.length], color: colors.primary);
  }
}
