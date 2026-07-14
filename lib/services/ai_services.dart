import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import 'image_generation_exception.dart';
import 'api_keys.dart';

// Handle calls to the image-generation APIs.
// Text to Image prompts go through OpenAI DALL-E 3
// Image to Image go through Stability AI
class AiService {
  static const _openAiImageUrl = 'https://api.openai.com/v1/images/generations';
  static const _stabilityStructureUrl =
      'https://api.stability.ai/v2beta/stable-image/control/structure';

  Future<Uint8List> generateFromText(String prompt) async {
    if (ApiKeys.openAi.isEmpty || ApiKeys.openAi == 'YOUR_OPENAI_API_KEY') {
      throw const ImageGenerationException('API Key ist ungültig.');
    }

    late final http.Response response;
    try {
      response = await http.post(
        Uri.parse(_openAiImageUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiKeys.openAi}',
        },
        body: jsonEncode({
          'model': 'dall-e-3',
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
          'response_format': 'b64_json',
        }),
      );
    } catch (_) {
      throw const ImageGenerationException('Verbindung fehlgeschlagen.');
    }

    if (response.statusCode == 401) {
      throw const ImageGenerationException('API Key ist ungültig.');
    }
    if (response.statusCode == 429) {
      throw const ImageGenerationException('Guthaben aufgebraucht.');
    }
    if (response.statusCode != 200) {
      throw ImageGenerationException('Fehler: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final base64Image = data['data'][0]['b64_json'] as String;
    return base64Decode(base64Image);
  }

  Future<Uint8List> generateFromImage({
    required Uint8List originalImageBytes,
    required String prompt,
  }) async {
    if (ApiKeys.stability.isEmpty ||
        ApiKeys.stability == 'YOUR_STABILITY_API_KEY') {
      throw const ImageGenerationException('API Key ist ungültig.');
    }

    try {
      final resizedBytes = _resize(originalImageBytes, maxWidth: 1024);

      final request =
          http.MultipartRequest('POST', Uri.parse(_stabilityStructureUrl))
            ..headers['Authorization'] = 'Bearer ${ApiKeys.stability}'
            ..headers['Accept'] = 'image/*'
            ..fields['prompt'] = prompt
            ..fields['control_strength'] = '0.7'
            ..fields['output_format'] = 'png'
            ..files.add(
              http.MultipartFile.fromBytes(
                'image',
                resizedBytes,
                filename: 'upload.jpg',
              ),
            );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        throw ImageGenerationException('Server Error: ${response.statusCode}');
      }

      return response.bodyBytes;
    } on ImageGenerationException {
      rethrow;
    } catch (_) {
      throw const ImageGenerationException(
        'Das Bild konnte nicht verarbeitet werden.',
      );
    }
  }

  Uint8List _resize(Uint8List bytes, {required int maxWidth}) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const ImageGenerationException(
        'Das Bild konnte nicht verarbeitet werden.',
      );
    }

    final resized = decoded.width > maxWidth
        ? img.copyResize(decoded, width: maxWidth)
        : decoded;

    return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
  }
}
