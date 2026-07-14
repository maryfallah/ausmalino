import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';

// Shown inside the modal while an image is being generated.
class LoadingContent extends StatelessWidget {
  const LoadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 260,
          height: 260,
          child: Lottie.asset('assets/animations/loading.json'),
        ),
        const SizedBox(height: 12),
        const Text(
          'Dein Bild wird gemalt...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.darkBrown,
          ),
        ),
      ],
    );
  }
}
