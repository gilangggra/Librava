import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../books/presentation/screens/my_book_page.dart';
import '../../../books/presentation/screens/search_page.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../profile/presentation/screens/profile_page.dart';
import '../../data/services/chat_api_service.dart';

class ChatBubbleMessage {
  final String id;
  final String text;
  final String time;
  final bool isOutgoing;
  final String? imageUrl;

  const ChatBubbleMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.isOutgoing,
    this.imageUrl,
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
    this.userName = 'User Test',
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

  final List<ChatBubbleMessage> _messages = [
    const ChatBubbleMessage(
      id: 'm1',
      text: 'Halo bang',
      time: '13.30',
      isOutgoing: false,
    ),
    const ChatBubbleMessage(
      id: 'm2',
      text: 'Mau nanya',
      time: '13.31',
      isOutgoing: false,
    ),
    const ChatBubbleMessage(
      id: 'm3',
      text: 'Iya kenapa?',
      time: '13.39',
      isOutgoing: true,
    ),
    const ChatBubbleMessage(
      id: 'm4',
      text: 'Ini foto kondisi fisik bukunya ya, mulus tanpa lipatan.',
      time: '13.40',
      isOutgoing: false,
      imageUrl: 'assets/images/book_atomic_habits.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final txId = int.tryParse(widget.transactionId ?? '');
    if (txId == null) return;

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

      if (apiMessages.isNotEmpty && mounted) {
        setState(() {
          _messages.clear();
          for (final m in apiMessages) {
            final isOut = (currentUserId.isNotEmpty &&
                    m.senderId == currentUserId) ||
                (currentUserName.isNotEmpty &&
                    m.senderNama == currentUserName);
            String formattedTime = '12.00';
            if (m.sentAt.isNotEmpty) {
              try {
                final dt = DateTime.parse(m.sentAt).toLocal();
                final hour = dt.hour.toString().padLeft(2, '0');
                final min = dt.minute.toString().padLeft(2, '0');
                formattedTime = '$hour.$min';
              } catch (_) {}
            }

            String text = m.pesan;
            String? imgUrl;
            if (m.pesan.startsWith('[FOTO:') && m.pesan.contains(']')) {
              final closeIdx = m.pesan.indexOf(']');
              imgUrl = m.pesan.substring(6, closeIdx).trim();
              text = m.pesan.substring(closeIdx + 1).trim();
              if (text.isEmpty) text = 'Foto kondisi buku';
            }

            _messages.add(
              ChatBubbleMessage(
                id: m.id,
                text: text,
                time: formattedTime,
                isOutgoing: isOut,
                imageUrl: imgUrl,
              ),
            );
          }
        });
      }
    } catch (_) {}
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
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
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

  void _previewFoto(String imagePath) {
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
              child: imagePath.startsWith('http')
                  ? Image.network(imagePath, fit: BoxFit.contain)
                  : Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ],
        ),
      ),
    );
  }

  void _kirimFoto(String imageAsset, String caption) {
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
    if (txId != null) {
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
    String selectedAsset = 'assets/images/book_atomic_habits.jpg';
    final samplePhotos = [
      {
        'title': 'Cover Depan',
        'subtitle': 'Sampul depan & judul',
        'asset': 'assets/images/book_atomic_habits.jpg',
      },
      {
        'title': 'Halaman Dalam',
        'subtitle': 'Kondisi kertas & teks',
        'asset': 'assets/images/book_fruit_fly.jpg',
      },
      {
        'title': 'Punggung Buku',
        'subtitle': 'Jilid & tepi lembaran',
        'asset': 'assets/images/book_the_unknown.jpg',
      },
      {
        'title': 'Rak & Koleksi',
        'subtitle': 'Buku di perpustakaan',
        'asset': 'assets/images/bookshelf.jpg',
      },
      {
        'title': 'Koleksi Sastra',
        'subtitle': 'Fisik buku novel',
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kirim Foto Kondisi Buku',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF130F26),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEAFE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.camera_fill,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Kamera / Foto',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pilih angle foto fisik buku untuk verifikasi sebelum serah terima.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7E7A92),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 124,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: samplePhotos.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (_, index) {
                          final item = samplePhotos[index];
                          final isSelected = selectedAsset == item['asset'];
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selectedAsset = item['asset']!;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 104,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : const Color(0xFFE8E5F4),
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(
                                      item['asset']!,
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
                                          padding:
                                              const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 14,
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
                                          fontSize: 11,
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: captionController,
                      decoration: InputDecoration(
                        hintText:
                            'Keterangan foto (contoh: "Cover mulus tanpa coretan")...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9E9BAE),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F6FA),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
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
                        icon: const Icon(Icons.send_rounded,
                            size: 18, color: Colors.white),
                        label: const Text(
                          'Kirim Foto Kondisi Buku',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _kirimFoto(
                              selectedAsset, captionController.text);
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
                if (message.imageUrl != null &&
                    message.imageUrl!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GestureDetector(
                      onTap: () => _previewFoto(message.imageUrl!),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          _buildImageWidget(message.imageUrl!),
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
          child: Icon(
            isSelected ? activeIcon : inactiveIcon,
            color: isSelected ? AppColors.primary : const Color(0xFF52518D),
            size: 28,
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
                    const SizedBox(width: 10),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF0EEF8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 34,
                          color: Color(0xFF130F26),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF130F26),
                          ),
                        ),
                        const SizedBox(height: 3),
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
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7E7A92),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2DEFD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '08/21',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF38335A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
                      tooltip: 'Kirim Foto Kondisi Buku',
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
                          hintText: 'Tulis pesan...',
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
                  Container(
                    width: 52,
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
                      icon: Icon(
                        _messageController.text.trim().isNotEmpty
                            ? Icons.send_rounded
                            : Icons.mic_none_rounded,
                        color: const Color(0xFF4A4468),
                        size: 26,
                      ),
                      onPressed: () {
                        if (_messageController.text.trim().isNotEmpty) {
                          _kirimPesan();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'Fitur pesan suara sedang disiapkan'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
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
