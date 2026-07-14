import 'age_group.dart';

// Builds the final prompt strings sent to the image-generation APIs.

class PromptBuilder {
  PromptBuilder._();

  static const Map<AgeGroup, String> _ageModifiers = {
    AgeGroup.toddler:
        'Designed for children aged 3-4 years. Very simple and bold shapes '
        'with minimal details. Extra thick outlines and large open areas '
        'for coloring. No small elements or complex patterns. Friendly and '
        'playful style for toddlers. ',
    AgeGroup.kid:
        'Designed for children aged 5-7 years. Simple but slightly detailed '
        'shapes. Clear outlines with medium-thick lines. Balanced white '
        'space with some basic details. Fun and engaging style suitable '
        'for early school-age kids. ',
    AgeGroup.teen:
        'Designed for children aged 8-10 years. More detailed line art '
        'while remaining clean and easy to color. Thinner but clear '
        'outlines. Includes moderate details without overcrowding the '
        'image. Still no shading or grayscale. ',
  };

  static const String _stylePositive =
      "Create a black and white children's coloring book illustration in "
      'clean line art style. The image should be flat and 2D, with simple '
      'shapes and clear outlines. Use smooth, continuous black lines. No '
      'shading, no gradients, no gray tones, no textures. Plenty of white '
      'space inside shapes for easy coloring. Cute, friendly, child-safe '
      'style. Centered composition on a white background. ';

  static const String _imagePositive =
      'black and white line art, coloring book page, outline only, high '
      'contrast, clean lines, white background, no shading, no gray, '
      'vector style, simple minimalist drawing, ';

  static const String _negative =
      'Do not use color, shadows, realism, background details, '
      'cross-hatching, sketch style, or 3D effects.';

  // Prompt used for the text-to-image (OpenAI) path.
  static String forText(String userPrompt, AgeGroup ageGroup) {
    final ageModifier = _ageModifiers[ageGroup]!;
    return '${userPrompt.trim()}. $ageModifier$_stylePositive$_negative';
  }

  // Prompt used for the photo-to-line-art (Stability) path.
  static String forImage(AgeGroup ageGroup) {
    final ageModifier = _ageModifiers[ageGroup]!;
    return '$ageModifier$_imagePositive';
  }
}
