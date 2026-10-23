import 'dart:typed_data';

/// Model sederhana data gambar yang diunggah
class PickedImageData {
  final String name;
  final Uint8List bytes;
  final String? mimeType;

  PickedImageData({
    required this.name,
    required this.bytes,
    this.mimeType,
  });
}

/// Helper pemilih gambar untuk platform non-web
Future<PickedImageData?> pickImageFromDevice() async {
  // Pada platform IO/Desktop/Mobile tanpa plugin native
  return null;
}

/// Helper pengambilan foto dari kamera untuk platform non-web
Future<PickedImageData?> takePhotoFromCamera() async {
  // Pada platform IO/Desktop/Mobile tanpa plugin native
  return null;
}
