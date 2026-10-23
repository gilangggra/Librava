import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../books/presentation/screens/my_book_page.dart';
import '../../../books/presentation/screens/search_page.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../profile/presentation/screens/profile_page.dart';
import '../../../profile/presentation/screens/profile_view_page.dart';
import '../../../../core/utils/image_upload_helper.dart';
import '../../../../core/utils/book_cover_helper.dart';
import '../../../books/data/services/book_api_service.dart';
import '../../../transactions/domain/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../../transactions/presentation/screens/transaction_detail_page.dart';
import '../../data/services/chat_api_service.dart';
import '../providers/chat_provider.dart';

class ChatBubbleMessage {
  final String id;
  final String text;
  final String time;
  final bool isOutgoing;
  final String? imageUrl;
  final Uint8List? imageBytes;

  const ChatBubbleMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.isOutgoing,
    this.imageUrl,
    this.imageBytes,
  });
}

class BubbleTailPainter extends CustomPainter {
  final Color color;
  final bool isOutgoing;

  BubbleTailPainter({
    required this.color,
    required this.isOutgoing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const double radius = 16.0;
    const double tailWidth = 8.0;

    if (!isOutgoing) {
      path.moveTo(tailWidth + radius, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(
          size.width, size.height, size.width - radius, size.height);
      path.lineTo(tailWidth + radius, size.height);
      path.quadraticBezierTo(
          tailWidth, size.height, tailWidth, size.height - radius);
      path.lineTo(tailWidth, 12);
      path.lineTo(0, 0);
      path.lineTo(tailWidth + radius, 0);
    } else {
      path.moveTo(radius, 0);
      path.lineTo(size.width - tailWidth - radius, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width - tailWidth, 12);
      path.lineTo(size.width - tailWidth, size.height - radius);
      path.quadraticBezierTo(size.width - tailWidth, size.height,
          size.width - tailWidth - radius, size.height);
      path.lineTo(radius, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - radius);
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
    }

    canvas.drawShadow(
        path, const Color(0xFF1E1A34).withValues(alpha: 0.04), 4, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BubbleTailPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isOutgoing != isOutgoing;
  }
}

class ChatRoomPage extends StatefulWidget {
  final String userName;
  final bool isOnline;
  final String? transactionId;

  const ChatRoomPage({
    super.key,
    this.userName = 'Librava Partner',
    this.isOnline = true,
    this.transactionId,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final int _selectedIndex = 3;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatApiService _apiService = ChatApiService();

  final List<ChatBubbleMessage> _messages = [];
  bool _isLoadingMessages = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final auth = context.read<AuthProvider>();
        if (auth.token != null) {
          context.read<TransactionProvider>().fetchTransaksi(auth.token!);
        }
      } catch (_) {}
    });
  }

  Future<void> _loadMessages() async {
    final txId = int.tryParse(widget.transactionId ?? '');
    if (txId == null) return;

    setState(() => _isLoadingMessages = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      if (token == null || token.isEmpty) return;

      final currentUserId = authProvider.currentUser?.id ?? '';
      final currentUserName = authProvider.currentUser?.nama ?? '';

      final apiMessages = await _apiService.getMessages(
        token: token,
        transactionId: txId,
      );

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(apiMessages.map((m) {
            final isOut = (currentUserId.isNotEmpty &&
                    m.senderId == currentUserId) ||
                (currentUserName.isNotEmpty &&
                    m.senderNama == currentUserName);
            final content = _parseMessageContent(m.pesan);
            return ChatBubbleMessage(
              id: m.id,
              text: content.text,
              time: _formatMessageTime(m.sentAt),
              isOutgoing: isOut,
              imageUrl: content.imageUrl,
            );
          }));
        });
        try {
          final chatProvider =
              Provider.of<ChatProvider>(context, listen: false);
          chatProvider.markAsRead(widget.transactionId ?? '');
        } catch (_) {}
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isLoadingMessages = false);
      }
    }
  }

  String _formatMessageTime(String sentAt) {
    if (sentAt.isEmpty) return '12.00';
    try {
      final dt = DateTime.parse(sentAt).toLocal();
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '$hour.$min';
    } catch (_) {
      return '12.00';
    }
  }

  ({String text, String? imageUrl}) _parseMessageContent(String raw) {
    if (raw.startsWith('[HANDOVER_LOCATION]:')) {
      final body = raw.replaceFirst('[HANDOVER_LOCATION]:', '').trim();
      String loc = body;
      String dt = '';
      if (body.contains('| DATE:')) {
        loc = body.split('| DATE:')[0].trim();
        final after = body.split('| DATE:')[1].trim();
        if (after.contains('| TIME:')) {
          final d = after.split('| TIME:')[0].trim();
          final t = after.split('| TIME:')[1].trim();
          dt = '$d, $t';
        } else {
          dt = after;
        }
      } else if (body.contains('| JADWAL:')) {
        loc = body.split('| JADWAL:').first.trim();
        dt = body.split('| JADWAL:').last.trim();
      }
      final text = dt.isNotEmpty
          ? '📍 Jadwal & Lokasi Serah Terima: $loc ($dt)'
          : '📍 Jadwal & Lokasi Serah Terima: $loc';
      return (text: text, imageUrl: null);
    }
    if (raw.startsWith('[FOTO:') && raw.contains(']')) {
      final closeIdx = raw.indexOf(']');
      final imgUrl = raw.substring(6, closeIdx).trim();
      var text = raw.substring(closeIdx + 1).trim();
      if (text.isEmpty) text = 'Foto kondisi buku';
      return (text: text, imageUrl: imgUrl);
    }
    return (text: raw, imageUrl: null);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _kirimPesan() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    setState(() {
      _messages.add(
        ChatBubbleMessage(
          id: 'm_${DateTime.now().millisecondsSinceEpoch}',
          text: text,
          time: '$hour.$minute',
          isOutgoing: true,
        ),
      );
    });

    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    final txId = int.tryParse(widget.transactionId ?? '');
    if (txId != null) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final token = authProvider.token;
        if (token != null && token.isNotEmpty) {
          _apiService.sendMessage(
            token: token,
            transactionId: txId,
            pesan: text,
          );
        }
      } catch (_) {}
    }
  }

  Widget _buildImageWidget(String path) {
    String? fullNetworkUrl;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      fullNetworkUrl = path;
    } else if (path.startsWith('/uploads/') || path.startsWith('uploads/')) {
      final clean = path.startsWith('/') ? path : '/$path';
      fullNetworkUrl = '${ApiConstants.baseUrl.replaceAll('/api', '')}$clean';
    }

    if (fullNetworkUrl != null) {
      return Image.network(
        fullNetworkUrl,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 140,
          color: const Color(0xFFE5E2F3),
          child: const Center(
            child: Icon(Icons.broken_image_rounded, color: Color(0xFF8A859E)),
          ),
        ),
      );
    }
    return Image.asset(
      path,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 140,
        color: const Color(0xFFE5E2F3),
        child: const Center(
          child: Icon(Icons.image_rounded, color: Color(0xFF8A859E)),
        ),
      ),
    );
  }

  void _previewFoto(String imagePath, [Uint8List? imageBytes]) {
    String? fullNetworkUrl;
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      fullNetworkUrl = imagePath;
    } else if (imagePath.startsWith('/uploads/') ||
        imagePath.startsWith('uploads/')) {
      final clean = imagePath.startsWith('/') ? imagePath : '/$imagePath';
      fullNetworkUrl = '${ApiConstants.baseUrl.replaceAll('/api', '')}$clean';
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: imageBytes != null
                  ? Image.memory(imageBytes, fit: BoxFit.contain)
                  : (fullNetworkUrl != null
                      ? Image.network(fullNetworkUrl, fit: BoxFit.contain)
                      : Image.asset(imagePath, fit: BoxFit.contain)),
            ),
          ],
        ),
      ),
    );
  }

  void _kirimFoto({
    String? imageAsset,
    Uint8List? localBytes,
    required String caption,
  }) {
    final text =
        caption.trim().isEmpty ? 'Foto kondisi buku' : caption.trim();
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    setState(() {
      _messages.add(
        ChatBubbleMessage(
          id: 'm_${DateTime.now().millisecondsSinceEpoch}',
          text: text,
          time: '$hour.$minute',
          isOutgoing: true,
          imageUrl: imageAsset,
          imageBytes: localBytes,
        ),
      );
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    final txId = int.tryParse(widget.transactionId ?? '');
    if (txId != null && imageAsset != null && imageAsset.isNotEmpty) {
      try {
        final authProvider =
            Provider.of<AuthProvider>(context, listen: false);
        final token = authProvider.token;
        if (token != null && token.isNotEmpty) {
          _apiService.sendMessage(
            token: token,
            transactionId: txId,
            pesan: '[FOTO:$imageAsset] $text',
          );
        }
      } catch (_) {}
    }
  }

  void _bukaModalLampiranFoto() {
    final captionController = TextEditingController();
    PickedImageData? pickedPhoto;
    String? selectedSampleAsset = 'assets/images/book_atomic_habits.jpg';
    bool isUploading = false;
    String? uploadError;

    final samplePhotos = [
      {
        'title': 'Front Cover',
        'subtitle': 'Front cover & title',
        'asset': 'assets/images/book_atomic_habits.jpg',
      },
      {
        'title': 'Inside Pages',
        'subtitle': 'Paper & text condition',
        'asset': 'assets/images/book_fruit_fly.jpg',
      },
      {
        'title': 'Book Spine',
        'subtitle': 'Binding & edge condition',
        'asset': 'assets/images/book_the_unknown.jpg',
      },
      {
        'title': 'Bookshelf & Collection',
        'subtitle': 'Book in shelf',
        'asset': 'assets/images/bookshelf.jpg',
      },
      {
        'title': 'Literature Collection',
        'subtitle': 'Physical novel condition',
        'asset': 'assets/images/book_midnight_lib.jpg',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 16,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E4E9),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kirim Foto Kondisi Buku',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF130F26),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Foto fisik buku untuk verifikasi sebelum serah terima.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7E7A92),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close_rounded,
                              size: 22, color: Color(0xFF8A859E)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: isUploading
                                ? null
                                : () async {
                                    try {
                                      final photo =
                                          await takePhotoFromCamera();
                                      if (photo != null) {
                                        setModalState(() {
                                          pickedPhoto = photo;
                                          selectedSampleAsset = null;
                                          uploadError = null;
                                        });
                                      }
                                    } catch (e) {
                                      setModalState(() {
                                        uploadError =
                                            'Gagal mengakses kamera: $e';
                                      });
                                    }
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 10),
                              decoration: BoxDecoration(
                                color: (pickedPhoto != null &&
                                        selectedSampleAsset == null)
                                    ? AppColors.primary
                                    : const Color(0xFFEDEAFE),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: (pickedPhoto != null &&
                                          selectedSampleAsset == null)
                                      ? AppColors.primary
                                      : const Color(0xFFD4CCF9),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    CupertinoIcons.camera_fill,
                                    size: 18,
                                    color: (pickedPhoto != null &&
                                            selectedSampleAsset == null)
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ambil Foto',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: (pickedPhoto != null &&
                                              selectedSampleAsset == null)
                                          ? Colors.white
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: isUploading
                                ? null
                                : () async {
                                    try {
                                      final picked =
                                          await pickImageFromDevice();
                                      if (picked != null) {
                                        setModalState(() {
                                          pickedPhoto = picked;
                                          selectedSampleAsset = null;
                                          uploadError = null;
                                        });
                                      }
                                    } catch (e) {
                                      setModalState(() {
                                        uploadError =
                                            'Gagal memilih foto: $e';
                                      });
                                    }
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F0FF),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFE2DCF8),
                                  width: 1.5,
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.photo_library_rounded,
                                    size: 18,
                                    color: Color(0xFF6B58E6),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Pilih dari Galeri',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF6B58E6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (pickedPhoto != null) ...[
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1A34),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.memory(
                                pickedPhoto!.bytes,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: 150,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF34C759),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      pickedPhoto!.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: InkWell(
                                onTap: isUploading
                                    ? null
                                    : () {
                                        setModalState(() {
                                          pickedPhoto = null;
                                          selectedSampleAsset =
                                              samplePhotos[0]['asset'];
                                        });
                                      },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFDC2626),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Atau pilih dari contoh foto fisik:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7E7A92),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 114,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: samplePhotos.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 10),
                          itemBuilder: (_, index) {
                            final item = samplePhotos[index];
                            final isSelected =
                                selectedSampleAsset == item['asset'];
                            final assetStr = item['asset']!;
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedSampleAsset = item['asset'];
                                  pickedPhoto = null;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 96,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : const Color(0xFFE8E5F4),
                                    width: isSelected ? 2.5 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        assetStr,
                                        fit: BoxFit.cover,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black
                                                  .withValues(alpha: 0.75),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 13,
                                            ),
                                          ),
                                        ),
                                      Positioned(
                                        bottom: 6,
                                        left: 6,
                                        right: 6,
                                        child: Text(
                                          item['title']!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    TextField(
                      controller: captionController,
                      decoration: InputDecoration(
                        hintText:
                            'Keterangan foto (misal: "Sampul mulus tanpa coretan")...',
                        hintStyle: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF9E9BAE),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F6FA),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.edit_note_rounded,
                            size: 20, color: Color(0xFF8A859E)),
                      ),
                    ),
                    if (uploadError != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: Color(0xFFDC2626), size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                uploadError!,
                                style: const TextStyle(
                                  color: Color(0xFFB91C1C),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        icon: isUploading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded,
                                size: 18, color: Colors.white),
                        label: Text(
                          isUploading
                              ? 'Mengunggah & Mengirim Foto...'
                              : (pickedPhoto != null
                                  ? 'Unggah & Kirim Foto'
                                  : 'Kirim Foto'),
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: isUploading
                            ? null
                            : () async {
                                final caption = captionController.text.trim();
                                if (pickedPhoto != null) {
                                  setModalState(() {
                                    isUploading = true;
                                    uploadError = null;
                                  });
                                  try {
                                    final auth =
                                        context.read<AuthProvider>();
                                    String finalUrl;
                                    if (auth.token != null &&
                                        auth.token!.isNotEmpty) {
                                      finalUrl = await BookApiService()
                                          .uploadBookCover(
                                        token: auth.token!,
                                        bytes: pickedPhoto!.bytes,
                                        filename: pickedPhoto!.name,
                                      );
                                    } else {
                                      finalUrl =
                                          'local_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                    }

                                    if (!ctx.mounted || !mounted) return;
                                    Navigator.pop(ctx);
                                    _kirimFoto(
                                      imageAsset: finalUrl,
                                      localBytes: pickedPhoto!.bytes,
                                      caption: caption,
                                    );
                                  } catch (e) {
                                    setModalState(() {
                                      isUploading = false;
                                      uploadError =
                                          'Gagal mengunggah foto ke server: $e';
                                    });
                                  }
                                } else if (selectedSampleAsset != null) {
                                  Navigator.pop(ctx);
                                  _kirimFoto(
                                    imageAsset: selectedSampleAsset!,
                                    caption: caption,
                                  );
                                }
                              },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChatBubble(ChatBubbleMessage message) {
    final isOutgoing = message.isOutgoing;
    final bubbleColor = isOutgoing ? const Color(0xFFE5E0FD) : Colors.white;
    final hasImage = message.imageBytes != null ||
        (message.imageUrl != null && message.imageUrl!.isNotEmpty);

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: CustomPaint(
        painter: BubbleTailPainter(
          color: bubbleColor,
          isOutgoing: isOutgoing,
        ),
        child: Padding(
          padding: isOutgoing
              ? const EdgeInsets.fromLTRB(16, 12, 22, 12)
              : const EdgeInsets.fromLTRB(22, 12, 16, 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 140, maxWidth: 260),
            child: Column(
              crossAxisAlignment: isOutgoing
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasImage) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GestureDetector(
                      onTap: () => _previewFoto(
                        message.imageUrl ?? '',
                        message.imageBytes,
                      ),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          message.imageBytes != null
                              ? Image.memory(
                                  message.imageBytes!,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : _buildImageWidget(message.imageUrl!),
                          Container(
                            margin: const EdgeInsets.all(6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.zoom_in_rounded,
                                    color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Perbesar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        message.text,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF130F26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      message.time,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isOutgoing
                            ? const Color(0xFF7E7A92)
                            : const Color(0xFF8E8B9F),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
    int badgeCount = 0,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  const HomePage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  const MyBookPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  const SearchPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 3) {
          Navigator.pop(context);
        } else if (index == 4) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  const ProfilePage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 64,
        height: 54,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBE7FD) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? AppColors.primary : const Color(0xFF52518D),
                size: 28,
              ),
              if (badgeCount > 0)
                Positioned(
                  top: -2,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionHeaderCard() {
    if (widget.transactionId == null) return const SizedBox.shrink();

    TransactionModel? tx;
    try {
      final trxProvider = context.watch<TransactionProvider>();
      tx = trxProvider.semuaTransaksi
          .where((t) => t.id == widget.transactionId)
          .firstOrNull;
    } catch (_) {}

    if (tx == null) return const SizedBox.shrink();

    AuthProvider? auth;
    try {
      auth = context.watch<AuthProvider>();
    } catch (_) {}

    final currentUserId = auth?.currentUser?.id ?? '';
    final currentUserName = auth?.currentUser?.nama.trim().toLowerCase() ?? '';

    final bool isOwner = (currentUserId.isNotEmpty && tx.pemilikId.isNotEmpty && tx.pemilikId == currentUserId) ||
        (currentUserName.isNotEmpty && tx.pemilikNama.trim().toLowerCase() == currentUserName);

    final status = tx.status.toLowerCase();
    final isBarter = tx.jenisTransaksi.toLowerCase() == 'barter';
    final isDepositPaid = status == 'dalam_proses' ||
        status == 'lokasi_ditentukan' ||
        status == 'sedang_dipinjam' ||
        status == 'selesai';

    Color statusColor = const Color(0xFFFFD027);
    String statusLabel = 'Menunggu Persetujuan';
    if (status == 'selesai') {
      statusColor = const Color(0xFF2FD677);
      statusLabel = 'Selesai';
    } else if (status == 'sedang_dipinjam') {
      statusColor = const Color(0xFF388AF6);
      statusLabel = 'Aktif Dipinjam';
    } else if (status == 'disetujui') {
      statusColor = const Color(0xFF10B981);
      statusLabel = 'Disetujui';
    } else if (status == 'dalam_proses' || status == 'lokasi_ditentukan') {
      statusColor = const Color(0xFF6356FF);
      statusLabel = 'Dalam Proses';
    } else if (status == 'ditolak' || status == 'dibatalkan') {
      statusColor = const Color(0xFFDC2626);
      statusLabel = status == 'ditolak' ? 'Ditolak' : 'Dibatalkan';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailPage(
                transactionId: tx!.id,
                bookTitle: tx.judulBuku,
                bookAuthor: tx.penulisBuku.isNotEmpty && tx.penulisBuku != 'Penulis'
                    ? tx.penulisBuku
                    : tx.pemilikNama,
                coverPath: BookCoverHelper.getCover(
                  fotoBuku: tx.coverBuku,
                  judul: tx.judulBuku,
                ),
                status: tx.status,
                depositAmount: '${tx.depositSimulasi.toInt()} Rupiah',
                isDepositPaid: isDepositPaid,
                handoverLocation: tx.lokasiPertemuan.isNotEmpty ? tx.lokasiPertemuan : 'Set handover',
                ownerName: tx.pemilikNama,
                ownerId: tx.pemilikId,
                requesterName: tx.pemohonNama,
                requesterId: tx.pemohonId,
                isOwner: isOwner,
                type: isBarter ? 'Barter' : 'Borrow',
                dueDate: tx.dueDate ?? tx.effectiveDueDate,
                isOverdue: tx.isOverdue,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOwner
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : const Color(0xFF388AF6).withValues(alpha: 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E1A34).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BookCoverHelper.buildCoverImage(
                  BookCoverHelper.getCover(fotoBuku: tx.coverBuku, judul: tx.judulBuku),
                  width: 38,
                  height: 52,
                  fallbackJudul: tx.judulBuku,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tx.judulBuku,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF130F26),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOwner ? const Color(0xFFF0EEFF) : const Color(0xFFE8F1FD),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            isBarter
                                ? (isOwner ? 'Pemilik Buku' : 'Pengaju Barter')
                                : (isOwner ? 'Pemilik (Meminjamkan)' : 'Peminjam'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isOwner ? AppColors.primary : const Color(0xFF388AF6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: Color(0xFF8A88A5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E1A34).withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Color(0xFF130F26),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          TransactionModel? currentTx;
                          try {
                            final trxProvider =
                                context.read<TransactionProvider>();
                            currentTx = trxProvider.semuaTransaksi
                                .where((t) => t.id == widget.transactionId)
                                .firstOrNull;
                          } catch (_) {}
                          final auth = context.read<AuthProvider>();
                          final myId = auth.currentUser?.id ?? '';
                          final myName = auth.currentUser?.nama.trim().toLowerCase() ?? '';
                          final bool isMeOwner = (myId.isNotEmpty &&
                                  currentTx?.pemilikId.isNotEmpty == true &&
                                  currentTx?.pemilikId == myId) ||
                              (myName.isNotEmpty &&
                                  currentTx?.pemilikNama.trim().toLowerCase() == myName);
                          final partnerId = isMeOwner
                              ? currentTx?.pemohonId
                              : currentTx?.pemilikId;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileViewPage(
                                userId: partnerId,
                                name: widget.userName,
                                transactionId: widget.transactionId,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFF0EEF8),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Color(0xFF130F26),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF130F26),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: widget.isOnline
                                              ? const Color(0xFF34C759)
                                              : const Color(0xFFA09DB2),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        widget.isOnline ? 'Online' : 'Offline',
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF7E7A92),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            _buildTransactionHeaderCard(),
            Expanded(
              child: _isLoadingMessages
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    )
                  : _messages.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 36.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF3F0FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.forum_outlined,
                                      color: AppColors.primary,
                                      size: 36,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'Start Conversation',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E1A34),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Send a message or photo of the physical book to coordinate with your partner.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF7E7A92),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 8.0),
                          itemCount: _messages.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildChatBubble(_messages[index]);
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF1E1A34).withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        CupertinoIcons.camera_fill,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      tooltip: 'Send Book Condition Photo',
                      onPressed: _bukaModalLampiranFoto,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF1E1A34).withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _messageController,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _kirimPesan(),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: Color(0xFFA5A2B8),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _messageController.text.trim().isNotEmpty
                          ? AppColors.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _messageController.text.trim().isNotEmpty
                              ? AppColors.primary.withValues(alpha: 0.35)
                              : const Color(0xFF1E1A34).withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        color: _messageController.text.trim().isNotEmpty
                            ? Colors.white
                            : const Color(0xFFBBB7CC),
                        size: 24,
                      ),
                      onPressed: _messageController.text.trim().isNotEmpty
                          ? _kirimPesan
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Color(0xFFEBE8F6),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              activeIcon: CupertinoIcons.house_fill,
              inactiveIcon: CupertinoIcons.house,
            ),
            _buildNavItem(
              index: 1,
              activeIcon: CupertinoIcons.book_fill,
              inactiveIcon: CupertinoIcons.book,
            ),
            _buildNavItem(
              index: 2,
              activeIcon: CupertinoIcons.search,
              inactiveIcon: CupertinoIcons.search,
            ),
            _buildNavItem(
              index: 3,
              activeIcon: CupertinoIcons.chat_bubble_fill,
              inactiveIcon: CupertinoIcons.chat_bubble,
              badgeCount: () {
                try {
                  return context.watch<ChatProvider>().totalUnread;
                } catch (_) {
                  return 0;
                }
              }(),
            ),
            _buildNavItem(
              index: 4,
              activeIcon: CupertinoIcons.person_fill,
              inactiveIcon: CupertinoIcons.person,
            ),
          ],
        ),
      ),
    );
  }
}
