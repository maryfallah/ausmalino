import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/age_group.dart';
import '../models/prompt_generator.dart';
import '../services/ai_services.dart';
import '../services/image_generation_exception.dart';
import '../theme/app_colors.dart';
import '../widgets/age_selector.dart';
import '../widgets/app_modal.dart';
import '../widgets/error_content.dart';
import '../widgets/loading_content.dart';
import '../widgets/result_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _promptController = TextEditingController();
  final _aiService = AiService();
  final _imagePicker = ImagePicker();

  AgeGroup _selectedAge = AgeGroup.kid;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Generation flows
  // ---------------------------------------------------------------------

  Future<void> _generateFromText() async {
    final text = _promptController.text.trim();
    FocusScope.of(context).unfocus();

    if (text.isEmpty) {
      _showError('Bitte schreibe etwas!');
      return;
    }

    _showLoading();
    try {
      final prompt = PromptBuilder.forText(text, _selectedAge);
      final imageBytes = await _aiService.generateFromText(prompt);
      if (!mounted) return;
      _showResult(imageBytes);
    } on ImageGenerationException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    }
  }

  Future<void> _generateFromImage(ImageSource source) async {
    final XFile? picked;
    try {
      picked = await _imagePicker.pickImage(source: source, imageQuality: 90);
    } catch (_) {
      _showError('Zugriff verweigert.');
      return;
    }

    if (picked == null) return; // user cancelled the picker

    final originalBytes = await picked.readAsBytes();

    _showLoading();
    try {
      final prompt = PromptBuilder.forImage(_selectedAge);
      final imageBytes = await _aiService.generateFromImage(
        originalImageBytes: originalBytes,
        prompt: prompt,
      );
      if (!mounted) return;
      _showResult(imageBytes);
    } on ImageGenerationException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    }
  }

  Future<void> _shareImage(Uint8List imageBytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/ausmalino_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(imageBytes);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Schau dir mein Ausmalbild an!');
    } catch (e) {
      debugPrint('Share failed or was cancelled: $e');
    }
  }

  // ---------------------------------------------------------------------
  // Modal helpers
  // ---------------------------------------------------------------------

  void _showLoading() {
    showAppModal(
      context: context,
      contentBuilder: (_) => const LoadingContent(),
    );
  }

  void _showError(String message) {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    showAppModal(
      context: context,
      contentBuilder: (_) => ErrorContent(message: message),
    );
  }

  void _showResult(Uint8List imageBytes) {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    showAppModal(
      context: context,
      contentBuilder: (_) => ResultContent(
        imageBytes: imageBytes,
        onShare: () => _shareImage(imageBytes),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'Ausmalino',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: AppColors.bronzeTan,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPromptField(),
                            const SizedBox(height: 24),
                            AgeSelector(
                              selected: _selectedAge,
                              onChanged: (group) =>
                                  setState(() => _selectedAge = group),
                            ),
                            const SizedBox(height: 24),
                            _buildGenerateButton(),
                            const Spacer(),
                            const SizedBox(height: 16),
                            _buildSourceButtons(),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromptField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.peachBeige,
        border: Border.all(color: AppColors.sageGreen, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _promptController,
        minLines: 5,
        maxLines: 8,
        style: const TextStyle(fontSize: 16, color: AppColors.darkBrown),
        cursorColor: AppColors.darkGreen,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          hintText: 'Was möchtest du malen? Z.B. einen süßen Welpen...',
          hintStyle: TextStyle(color: AppColors.darkBrown),
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _generateFromText,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bronzeTan,
          foregroundColor: AppColors.creamBrown,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Los geht's!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildSourceButtons() {
    return Row(
      children: [
        Expanded(
          child: _SourceButton(
            label: 'Kamera',
            icon: Icons.photo_camera_outlined,
            backgroundColor: AppColors.paleGreen,
            borderColor: AppColors.darkGreen,
            onTap: () => _generateFromImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _SourceButton(
            label: 'Galerie',
            icon: Icons.photo_library_outlined,
            backgroundColor: AppColors.peachBeige,
            borderColor: AppColors.bronzeTan,
            onTap: () => _generateFromImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }
}

class _SourceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _SourceButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: AppColors.darkBrown),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
