import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class TagChip extends StatelessWidget {
  final String label;
  final bool highlighted;

  const TagChip({
    super.key,
    required this.label,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primary : AppColors.chipGray,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: highlighted ? Colors.white : AppColors.text,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}