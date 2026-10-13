// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
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

/// Helper pemilih gambar langsung menggunakan file dialog browser di Flutter Web
Future<PickedImageData?> pickImageFromDevice() async {
  final completer = Completer<PickedImageData?>();

  final uploadInput = html.FileUploadInputElement()
    ..accept = 'image/png,image/jpeg,image/jpg,image/webp';
  uploadInput.click();

  uploadInput.onChange.listen((event) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((e) {
        final result = reader.result;
        if (result is Uint8List) {
          completer.complete(PickedImageData(
            name: file.name,
            bytes: result,
            mimeType: file.type,
          ));
        } else if (result is List<int>) {
          completer.complete(PickedImageData(
            name: file.name,
            bytes: Uint8List.fromList(result),
            mimeType: file.type,
          ));
        } else {
          completer.complete(null);
        }
      });
    } else {
      completer.complete(null);
    }
  });

  return completer.future;
}
