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

/// Helper pemilih gambar dari galeri / berkas perangkat di Flutter Web
Future<PickedImageData?> pickImageFromDevice() async {
  return _pickFileWithInput(accept: 'image/png,image/jpeg,image/jpg,image/webp');
}

/// Helper pengambilan foto langsung dari kamera di Flutter Web
Future<PickedImageData?> takePhotoFromCamera() async {
  final mediaDevices = html.window.navigator.mediaDevices;

  // Jika browser mendukung mediaDevices (webcam / kamera live)
  if (mediaDevices != null) {
    try {
      final completer = Completer<PickedImageData?>();
      html.MediaStream stream;

      try {
        stream = await mediaDevices.getUserMedia({
          'video': {
            'facingMode': {'ideal': 'environment'},
            'width': {'ideal': 1280},
            'height': {'ideal': 720},
          },
          'audio': false,
        });
      } catch (_) {
        // Fallback jika ideal environment tidak tersedia (misal webcam laptop)
        stream = await mediaDevices.getUserMedia({
          'video': true,
          'audio': false,
        });
      }

      // Buat UI overlay kamera di atas web
      final overlay = html.DivElement()
        ..id = 'librava-camera-overlay'
        ..style.position = 'fixed'
        ..style.top = '0'
        ..style.left = '0'
        ..style.width = '100vw'
        ..style.height = '100vh'
        ..style.backgroundColor = 'rgba(15, 12, 35, 0.92)'
        ..style.zIndex = '999999'
        ..style.display = 'flex'
        ..style.flexDirection = 'column'
        ..style.alignItems = 'center'
        ..style.justifyContent = 'center'
        ..style.padding = '16px'
        ..style.boxSizing = 'border-box'
        ..style.fontFamily = 'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';

      final modalBox = html.DivElement()
        ..style.backgroundColor = '#1E1A34'
        ..style.borderRadius = '24px'
        ..style.padding = '20px'
        ..style.maxWidth = '540px'
        ..style.width = '100%'
        ..style.display = 'flex'
        ..style.flexDirection = 'column'
        ..style.alignItems = 'center'
        ..style.boxShadow = '0 20px 48px rgba(0, 0, 0, 0.55)'
        ..style.border = '1px solid rgba(255, 255, 255, 0.1)';

      final header = html.DivElement()
        ..style.width = '100%'
        ..style.display = 'flex'
        ..style.justifyContent = 'space-between'
        ..style.alignItems = 'center'
        ..style.marginBottom = '16px';

      final title = html.HeadingElement.h3()
        ..innerText = '📸 Kamera Buku'
        ..style.color = '#FFFFFF'
        ..style.margin = '0'
        ..style.fontSize = '18px'
        ..style.fontWeight = '700';

      final closeBtn = html.ButtonElement()
        ..innerText = '✕'
        ..style.background = 'rgba(255, 255, 255, 0.15)'
        ..style.color = '#FFFFFF'
        ..style.border = 'none'
        ..style.borderRadius = '50%'
        ..style.width = '36px'
        ..style.height = '36px'
        ..style.fontSize = '16px'
        ..style.cursor = 'pointer'
        ..style.display = 'flex'
        ..style.alignItems = 'center'
        ..style.justifyContent = 'center';

      header.append(title);
      header.append(closeBtn);

      final video = html.VideoElement()
        ..autoplay = true
        ..setAttribute('playsinline', 'true')
        ..setAttribute('webkit-playsinline', 'true')
        ..style.width = '100%'
        ..style.maxHeight = '55vh'
        ..style.borderRadius = '16px'
        ..style.objectFit = 'cover'
        ..style.backgroundColor = '#000000';
      video.srcObject = stream;

      final footer = html.DivElement()
        ..style.display = 'flex'
        ..style.gap = '12px'
        ..style.marginTop = '18px'
        ..style.width = '100%'
        ..style.justifyContent = 'center';

      final snapBtn = html.ButtonElement()
        ..innerText = '📸 Ambil Foto'
        ..style.background = '#5F4BDB'
        ..style.color = '#FFFFFF'
        ..style.border = 'none'
        ..style.borderRadius = '16px'
        ..style.padding = '12px 32px'
        ..style.fontSize = '15px'
        ..style.fontWeight = '700'
        ..style.cursor = 'pointer'
        ..style.boxShadow = '0 6px 20px rgba(95, 75, 219, 0.45)';

      footer.append(snapBtn);

      modalBox.append(header);
      modalBox.append(video);
      modalBox.append(footer);
      overlay.append(modalBox);
      html.document.body?.append(overlay);

      void cleanup() {
        for (final track in stream.getTracks()) {
          track.stop();
        }
        overlay.remove();
      }

      closeBtn.onClick.listen((_) {
        cleanup();
        if (!completer.isCompleted) completer.complete(null);
      });

      snapBtn.onClick.listen((_) {
        try {
          final width = video.videoWidth > 0 ? video.videoWidth : 1280;
          final height = video.videoHeight > 0 ? video.videoHeight : 720;
          final canvas = html.CanvasElement(width: width, height: height);
          canvas.context2D.drawImage(video, 0, 0);

          final dataUrl = canvas.toDataUrl('image/jpeg', 0.92);
          final uriData = UriData.parse(dataUrl);
          final bytes = uriData.contentAsBytes();

          cleanup();
          if (!completer.isCompleted) {
            completer.complete(PickedImageData(
              name: 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg',
              bytes: bytes,
              mimeType: 'image/jpeg',
            ));
          }
        } catch (_) {
          cleanup();
          if (!completer.isCompleted) completer.complete(null);
        }
      });

      return await completer.future;
    } catch (_) {
      // Jika kamera live gagal atau ditolak izinnya, fallback ke capture input
      return _pickFileWithInput(accept: 'image/*', capture: 'environment');
    }
  }

  // Jika mediaDevices tidak tersedia
  return _pickFileWithInput(accept: 'image/*', capture: 'environment');
}

/// Helper internal pemilih berkas menggunakan HTML FileUploadInputElement
Future<PickedImageData?> _pickFileWithInput({
  required String accept,
  String? capture,
}) async {
  final completer = Completer<PickedImageData?>();

  final uploadInput = html.FileUploadInputElement()..accept = accept;
  if (capture != null) {
    uploadInput.setAttribute('capture', capture);
  }
  uploadInput.click();

  uploadInput.onChange.listen((event) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((e) {
        final result = reader.result;
        final finalName = file.name.isNotEmpty
            ? file.name
            : 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final finalType = file.type.isNotEmpty ? file.type : 'image/jpeg';

        if (result is Uint8List) {
          completer.complete(PickedImageData(
            name: finalName,
            bytes: result,
            mimeType: finalType,
          ));
        } else if (result is List<int>) {
          completer.complete(PickedImageData(
            name: finalName,
            bytes: Uint8List.fromList(result),
            mimeType: finalType,
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
