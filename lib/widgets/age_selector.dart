import 'package:flutter/material.dart';
import '../models/age_group.dart';
import '../theme/app_colors.dart';

// A row of three buttons for choosing the target age group.
class AgeSelector extends StatelessWidget {
  final AgeGroup selected;
  final ValueChanged<AgeGroup> onChanged;

  const AgeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Altersgruppe',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.darkBrown,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          // AgeGroup.values is a list of all its values, in declaration order.
          // values => todller - kid - teen
          children: AgeGroup.values
              .map((group) => Expanded(child: _buildCapsule(group)))
              .toList(growable: false),
        ),
      ],
    );
  }

  Widget _buildCapsule(AgeGroup group) {
    final isSelected = group == selected;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => onChanged(group),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.paleGreen : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColors.darkGreen : AppColors.sageGreen,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            group.label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.darkBrown,
            ),
          ),
        ),
      ),
    );
  }
}
