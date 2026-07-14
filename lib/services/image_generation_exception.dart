// Throws execption when image generation request fails and shows a message to users
class ImageGenerationException implements Exception {
  final String message;

  const ImageGenerationException(this.message);

  @override
  String toString() => message;
}
