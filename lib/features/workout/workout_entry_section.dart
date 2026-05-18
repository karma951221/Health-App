import 'package:flutter/material.dart';

class WorkoutEntrySection extends StatelessWidget {
  const WorkoutEntrySection({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextField(
      maxLines: 4,
      decoration: InputDecoration(hintText: '예: 상체 40분 / 푸시업 5세트'),
    );
  }
}
