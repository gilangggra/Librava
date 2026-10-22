import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/utils/image_upload_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/screens/chat_page.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../profile/presentation/screens/profile_page.dart';
import '../../domain/models/book_model.dart';
import '../providers/book_provider.dart';
import 'my_book_page.dart';
import 'search_page.dart';

/// Halaman untuk mengedit buku yang sudah ada di koleksi Librava.
/// Tampilannya sama persis dengan AddBookPage, hanya saja datanya terisi otomatis
/// dan tombol aksinya bertuliskan "Edit book".
class EditBookPage extends StatefulWidget {
  final BookModel book;

  const EditBookPage({super.key, required this.book});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final int _selectedIndex = 1; // Tab My Book aktif di Bottom Navigation

  // Controller untuk input form teks
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _descriptionController;

  // State pilihan Genre dan Bahasa
  late String _selectedGenre;
  String _selectedLanguage = 'English';

  // Daftar genre yang konsisten dengan pilihan di search_page.dart
  final List<String> _genreOptions = [
    'Drama',
    'Romance',
    'Horror',
    'Thriller',
    'Fantasy',
    'Sci-Fi',
    'Historical',
    'Self-Help',
    'Sains',
    'Fiksi',
    'Komik',
    'Teknologi',
  ];

  // Daftar bahasa yang tersedia
  final List<String> _languageOptions = [
    'English',
    'Indonesian',
    'Japanese',
    'Chinese',
    'Spanish',
    'French',
    'German',
  ];

  // State gambar cover
  Uint8List? _coverBytes; // Data byte gambar lokal baru jika diupload
  String? _coverFileName;
  String? _uploadedCoverUrl;
  String? _selectedAssetCover;
  bool _isUploadingCover = false;
  bool _isSubmitting = false; // Status loading saat klik tombol 'Edit book'

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.judul);
    _authorController = TextEditingController(text: widget.book.penulis);
    _descriptionController = TextEditingController(text: widget.book.deskripsi);
    _selectedGenre = widget.book.kategori.isNotEmpty ? widget.book.kategori : 'Drama';

    // Inisialisasi cover yang ada saat ini
    final existingFoto = widget.book.fotoBuku ?? '';
    if (existingFoto.isNotEmpty) {
      if (existingFoto.startsWith('assets/')) {
        _selectedAssetCover = existingFoto;
      } else {
        _uploadedCoverUrl = existingFoto;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Membuka file dialog dari browser/komputer/perangkat untuk upload cover buku
  Future<void> _pilihDanUploadCover() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final picked = await pickImageFromDevice();

      // Jika user membatalkan pemilihan file
      if (picked == null) return;

      final bytes = picked.bytes;

      if (!mounted) return;

      setState(() {
        _coverBytes = bytes;
        _coverFileName = picked.name;
        _selectedAssetCover = null;
        _isUploadingCover = true;
      });

      // Segera unggah gambar cover ke backend API jika user sudah login
      final auth = context.read<AuthProvider>();
      final bookProvider = context.read<BookProvider>();

      if (auth.token != null && auth.token!.isNotEmpty) {
        try {
          final url = await bookProvider.uploadBookCover(
            token: auth.token!,
            bytes: bytes,
            filename: picked.name,
          );

          if (mounted) {
            setState(() {
              _uploadedCoverUrl = url;
              _isUploadingCover = false;
            });
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Book cover successfully uploaded to server!'),
                backgroundColor: Color(0xFF16A34A),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isUploadingCover = false;
            });
            debugPrint('Catatan upload cover background: $e');
          }
        }
      } else {
        setState(() {
          _isUploadingCover = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingCover = false;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to select image: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Widget dialog dropdown berdesain persis seperti floating overlay filter pencarian buku (SearchPage)
  Widget _buildFilterStyleDropdownDialog({
    required BuildContext ctx,
    required String label,
    required String selectedValue,
    required List<String> options,
    required Function(String) onSelect,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: const Color(0xFFEBE8F4),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header dropdown persis seperti pada dropdown overlay filter pencarian buku
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  color: const Color(0xFFEBE8F4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF130F26),
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.chevron_down,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 1.2,
                color: const Color(0xFFDED8F6),
              ),
              // List opsi dropdown bernuansa sama persis dengan filter buku
              Container(
                color: Colors.white,
                constraints: const BoxConstraints(
                  maxHeight: 330,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((option) {
                      final isSelected =
                          selectedValue.toLowerCase() == option.toLowerCase();
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              onSelect(option);
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              alignment: Alignment.centerLeft,
                              color: isSelected
                                  ? const Color(0xFFF7F6FD)
                                  : Colors.white,
                              child: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : const Color(0xFF757489),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 1.2,
                            color: const Color(0xFFDED8F6),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Membuka dialog dropdown pemilih Genre sesuai gaya filter search_page
  void _pilihGenreDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) {
        return _buildFilterStyleDropdownDialog(
          ctx: ctx,
          label: 'Genre',
          selectedValue: _selectedGenre,
          options: _genreOptions,
          onSelect: (val) {
            setState(() {
              _selectedGenre = val;
            });
          },
        );
      },
    );
  }

  /// Membuka dialog dropdown pemilih Bahasa sesuai gaya filter search_page
  void _pilihLanguageDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) {
        return _buildFilterStyleDropdownDialog(
          ctx: ctx,
          label: 'Language',
          selectedValue: _selectedLanguage,
          options: _languageOptions,
          onSelect: (val) {
            setState(() {
              _selectedLanguage = val;
            });
          },
        );
      },
    );
  }

  /// Helper untuk merender gambar cover buku yang ada
  Widget _buildExistingCoverWidget(String foto) {
    if (foto.startsWith('http://') || foto.startsWith('https://')) {
      return Image.network(
        foto,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Image.asset(
          'assets/images/book_the_unknown.jpg',
          fit: BoxFit.cover,
        ),
      );
    } else if (foto.startsWith('/uploads/') || foto.startsWith('uploads/')) {
      final cleanPath = foto.startsWith('/') ? foto : '/$foto';
      final rootServer = ApiConstants.baseUrl.replaceAll('/api', '');
      return Image.network(
        '$rootServer$cleanPath',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Image.asset(
          'assets/images/book_the_unknown.jpg',
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Image.asset(
        foto.isNotEmpty ? foto : 'assets/images/book_the_unknown.jpg',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Image.asset(
          'assets/images/book_the_unknown.jpg',
          fit: BoxFit.cover,
        ),
      );
    }
  }

  /// Kotak upload cover bergaris putus-putus ungu (Dashed Box) sesuai mockup
  Widget _buildCoverBox() {
    final hasImage = _coverBytes != null ||
        _selectedAssetCover != null ||
        (_uploadedCoverUrl != null && _uploadedCoverUrl!.isNotEmpty);

    return GestureDetector(
      onTap: _pilihDanUploadCover,
      child: CustomPaint(
        painter: _BookDashedBorderPainter(
          color: const Color(0xFF9086F4),
          strokeWidth: 1.5,
          radius: 16,
          dashWidth: 5,
          dashSpace: 3,
        ),
        child: Container(
          width: double.infinity,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFEDEAFE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gambar cover lokal baru, template asset, atau cover dari URL backend
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _coverBytes != null
                          ? Image.memory(
                              _coverBytes!,
                              fit: BoxFit.cover,
                            )
                          : (_selectedAssetCover != null
                              ? Image.asset(
                                  _selectedAssetCover!,
                                  fit: BoxFit.cover,
                                )
                              : _buildExistingCoverWidget(_uploadedCoverUrl ?? '')),
                    ),

                    // Efek overlay loading saat upload berlangsung
                    if (_isUploadingCover)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Uploading cover...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Tombol ganti cover di pojok kanan atas
                    if (!_isUploadingCover)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 13,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Ganti',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.image_outlined,
                      size: 46,
                      color: Color(0xFF584CF4),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Upload book cover',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF584CF4),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Memperbarui buku ke server backend (Tombol Edit book)
  Future<void> _submitEditBook() async {
    final titleText = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : widget.book.judul;
    final authorText = _authorController.text.trim().isNotEmpty
        ? _authorController.text.trim()
        : widget.book.penulis;
    final descText = _descriptionController.text.trim().isNotEmpty
        ? _descriptionController.text.trim()
        : widget.book.deskripsi;

    final auth = context.read<AuthProvider>();
    if (auth.token == null || auth.token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in first to edit the book.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final bookProvider = context.read<BookProvider>();

    try {
      String? finalFotoBuku = _uploadedCoverUrl ?? _selectedAssetCover;

      // Jika user memilih gambar cover lokal baru tapi belum terunggah ke backend
      if (_coverBytes != null) {
        final uploaded = await bookProvider.uploadBookCover(
          token: auth.token!,
          bytes: _coverBytes!,
          filename: _coverFileName ?? 'cover.jpg',
        );
        finalFotoBuku = uploaded;
        _uploadedCoverUrl = uploaded;
      }

      finalFotoBuku ??= widget.book.fotoBuku ?? 'assets/images/book_the_unknown.jpg';

      await bookProvider.updateBukuApi(
        token: auth.token!,
        bookId: widget.book.id,
        judul: titleText,
        penulis: authorText,
        kategori: _selectedGenre,
        deskripsi: descText,
        fotoBuku: finalFotoBuku,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Book "$titleText" successfully updated!'),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      final pesan = e.toString().replaceFirst('Exception: ', '');
      messenger.showSnackBar(
        SnackBar(
          content: Text(pesan),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Dialog konfirmasi penghapusan buku dari koleksi
  Future<void> _konfirmasiHapusBuku() async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null || auth.token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in first to delete the book.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final judulBuku = widget.book.judul;
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                CupertinoIcons.trash,
                color: Color(0xFFDC2626),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Delete Book?',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF130F26),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$judulBuku" from your collection? This action cannot be undone.',
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF555268),
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Color(0xFFDCD9EB)),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF7E7A92),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    'Yes, Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (setuju == true && mounted) {
      setState(() {
        _isSubmitting = true;
      });

      final messenger = ScaffoldMessenger.of(context);
      final bookProvider = context.read<BookProvider>();

      try {
        await bookProvider.hapusBukuApi(
          token: auth.token!,
          bookId: widget.book.id,
        );

        if (!mounted) return;

        messenger.showSnackBar(
          SnackBar(
            content: Text('Book "$judulBuku" has been deleted.'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete book: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Tombol bar navigasi bawah seragam Librava
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
              pageBuilder: (_, _, _) => const HomePage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, _, _) => const MyBookPage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, _, _) => const SearchPage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, _, _) => const ChatPage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 4) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, _, _) => const ProfilePage(),
              transitionDuration: Duration.zero,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Tombol Kembali "<" di pojok kiri atas sesuai mockup
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      CupertinoIcons.chevron_left,
                      size: 24,
                      color: Color(0xFF2E2A47),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Kartu Putih Pembungkus Seluruh Form Input (Sesuai Mockup)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Book cover (Upload Cover Buku)
                      const Text(
                        'Book cover',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B6882),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCoverBox(),

                      const SizedBox(height: 18),

                      // 2. Book title
                      const Text(
                        'Book title',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B6882),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'The Unknown',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E9AAF),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFD6D3E3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFD6D3E3)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // 3. Author
                      const Text(
                        'Author',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B6882),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _authorController,
                        decoration: InputDecoration(
                          hintText: 'Riley Sager',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E9AAF),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFD6D3E3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFD6D3E3)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // 4. Ganre & Language Row (Side by side tanpa overflow)
                      Row(
                        children: [
                          // Kolom Ganre (Genre)
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ganre',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B6882),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pilihGenreDialog,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFFD6D3E3)),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              _selectedGenre,
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                color: Color(0xFF555268),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Color(0xFF75728A),
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Kolom Language
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Language',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B6882),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pilihLanguageDialog,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFFD6D3E3)),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              _selectedLanguage,
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                color: Color(0xFF555268),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Color(0xFF75728A),
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // 5. Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B6882),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Tell student about your book',
                          hintStyle: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E9AAF),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFD6D3E3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFD6D3E3)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Tombol aksi Hapus Buku & Edit book (berdampingan di samping edit buku)
                Row(
                  children: [
                    // Tombol Hapus Buku (di samping Edit book)
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC2626).withValues(alpha: 0.10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFFEE2E2),
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(CupertinoIcons.trash, size: 18),
                          label: const Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          onPressed: _isSubmitting ? null : _konfirmasiHapusBuku,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Tombol Edit book
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _isSubmitting ? null : _submitEditBook,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Edit book',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),
              ],
            ),
          ),
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
              activeIcon: CupertinoIcons.ellipses_bubble_fill,
              inactiveIcon: CupertinoIcons.ellipses_bubble,
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

/// CustomPainter untuk membuat garis putus-putus ungu (Dashed Border)
/// pada kotak upload cover buku.
class _BookDashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  _BookDashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.radius = 16,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(
            distance,
            next > metric.length ? metric.length : next,
          ),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
