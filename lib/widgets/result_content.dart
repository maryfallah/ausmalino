import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Shown inside the modal once an image has been generated successfully.
class ResultContent extends StatelessWidget {
  final Uint8List imageBytes;
  final VoidCallback onShare;

  const ResultContent({
    super.key,
    required this.imageBytes,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.bronzeTan, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.memory(imageBytes, fit: BoxFit.contain),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onShare,
            icon: const Icon(Icons.ios_share_rounded),
            label: const Text(
              'Teilen & Drucken',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bronzeTan,
              foregroundColor: AppColors.creamBrown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
