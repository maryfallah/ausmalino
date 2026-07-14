import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// A reusable modal dialog (rounded card + close button) that
// can display different content such as Loading, Error, or Result.
Future<void> showAppModal({
  required BuildContext context,
  required WidgetBuilder contentBuilder,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => _AppModalCard(contentBuilder: contentBuilder),
  );
}

class _AppModalCard extends StatelessWidget {
  final WidgetBuilder contentBuilder;

  const _AppModalCard({required this.contentBuilder});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.creamBrown,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.darkBrown),
                ),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Builder(builder: contentBuilder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
