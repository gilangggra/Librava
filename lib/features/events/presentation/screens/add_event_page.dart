import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/image_upload_helper.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../admin/presentation/screens/admin_dashboard_page.dart';
import '../../../admin/presentation/widgets/admin_bottom_nav.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../books/presentation/screens/my_book_page.dart';
import '../../../books/presentation/screens/search_page.dart';
import '../../../chat/presentation/screens/chat_page.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../profile/presentation/screens/profile_page.dart';
import '../providers/event_provider.dart';

/// Halaman untuk menambahkan event kampus baru.
/// Didesain rapi, bersih, beginner-friendly, dan 100% konsisten dengan mockup UI.
class AddEventPage extends StatefulWidget {
  final bool? isAdmin;
  final String? initialBanner;
  const AddEventPage({super.key, this.isAdmin, this.initialBanner});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final int _selectedIndex = 0; // Tab Home aktif di Bottom Navigation

  // Controller untuk input teks form
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // State nilai tanggal dan waktu (default tanggal hari ini/besok)
  late DateTime _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 16, minute: 0);

  // State untuk banner yang diunggah langsung oleh pengguna
  Uint8List? _bannerBytes; // Data byte gambar lokal
  String? _bannerFileName; // Nama file banner
  String? _uploadedBannerUrl; // URL hasil upload dari backend server
  String? _selectedAssetBanner; // Template asset jika pengguna ingin memilih template
  bool _isUploadingBanner = false; // Status loading saat mengunggah banner
  bool _isPublishing = false; // Status loading saat mempublikasikan event

  bool get _isAdmin {
    if (widget.isAdmin != null) return widget.isAdmin!;
    final auth = context.read<AuthProvider>();
    return auth.currentUser?.role.toLowerCase() == 'admin';
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day + 1);
    if (widget.initialBanner != null && widget.initialBanner!.isNotEmpty) {
      _selectedAssetBanner = widget.initialBanner;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Format tampilan tanggal: "Oct 12, 2026"
  String _formatDateDisplay(DateTime dt) {
    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${bulan[dt.month]} ${dt.day}, ${dt.year}';
  }

  /// Format rentang waktu: "10:00 AM - 4:00 PM"
  String _formatTimeDisplay(TimeOfDay start, TimeOfDay end) {
    String toStr(TimeOfDay t) {
      final h = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
      final m = t.minute.toString().padLeft(2, '0');
      final ampm = t.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    }

    return '${toStr(start)} - ${toStr(end)}';
  }

  /// Membuka dialog pemilih tanggal (DatePicker)
  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
      firstDate: today,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Color(0xFF130F26),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Membuka dialog pemilih rentang jam (Mulai & Selesai)
  Future<void> _pilihWaktu() async {
    final start = await showTimePicker(
      context: context,
      initialTime: _startTime,
      helpText: 'Select Event Start Time',
    );
    if (start == null || !mounted) return;

    final defaultEndHour = (start.hour + 2) % 24;
    final suggestedEnd = TimeOfDay(
      hour: defaultEndHour == 0 ? 23 : defaultEndHour,
      minute: start.minute,
    );

    final end = await showTimePicker(
      context: context,
      initialTime: (_endTime.hour * 60 + _endTime.minute > start.hour * 60 + start.minute)
          ? _endTime
          : suggestedEnd,
      helpText: 'Select Event End Time',
    );
    if (end == null || !mounted) return;

    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (endMinutes <= startMinutes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jam selesai harus setelah jam mulai event.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _startTime = start;
      _endTime = end;
    });
  }

  /// Membuka file dialog agar pengguna dapat mengunggah banner sendiri dari perangkat/komputer
  Future<void> _pilihDanUploadBanner() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final picked = await pickImageFromDevice();

      // Jika pengguna membatalkan dialog pemilihan file
      if (picked == null) return;

      final bytes = picked.bytes;

      if (!mounted) return;

      setState(() {
        _bannerBytes = bytes;
        _bannerFileName = picked.name;
        _selectedAssetBanner = null; // Reset template asset
        _isUploadingBanner = true;
      });

      // Segera unggah gambar ke backend API jika pengguna sudah login
      final auth = context.read<AuthProvider>();
      final eventProvider = context.read<EventProvider>();

      if (auth.token != null && auth.token!.isNotEmpty) {
        try {
          final url = await eventProvider.uploadBannerImage(
            token: auth.token!,
            bytes: bytes,
            filename: picked.name,
          );

          if (mounted) {
            setState(() {
              _uploadedBannerUrl = url;
              _isUploadingBanner = false;
            });
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Banner berhasil diunggah ke server!'),
                backgroundColor: Color(0xFF16A34A),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isUploadingBanner = false;
            });
            debugPrint('Catatan upload banner background: $e');
          }
        }
      } else {
        setState(() {
          _isUploadingBanner = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingBanner = false;
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

  /// Kotak upload banner dengan garis putus-putus ungu sesuai mockup
  Widget _buildBannerBox() {
    final hasImage = _bannerBytes != null || _selectedAssetBanner != null;

    return GestureDetector(
      onTap: _pilihDanUploadBanner,
      child: CustomPaint(
        painter: DashedBorderPainter(
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
                    // Gambar yang diupload user atau dipilih dari template
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _bannerBytes != null
                          ? Image.memory(
                              _bannerBytes!,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              _selectedAssetBanner!,
                              fit: BoxFit.cover,
                            ),
                    ),

                    // Efek overlay loading saat sedang mengunggah
                    if (_isUploadingBanner)
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
                                'Mengunggah banner...',
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

                    // Badge tombol "Ganti" di pojok kanan atas
                    if (!_isUploadingBanner)
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
                      'Upload event banner',
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

  /// Mempublikasikan event ke backend server
  Future<void> _publishEvent() async {
    // 1. Validasi Judul
    final titleText = _titleController.text.trim();
    if (titleText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event title cannot be empty.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 2. Validasi Banner (Wajib dipilih atau diunggah, tidak ada fallback diam-diam)
    final bool hasBanner = _bannerBytes != null ||
        _selectedAssetBanner != null ||
        _uploadedBannerUrl != null;
    if (!hasBanner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event banner cannot be empty. Please choose or upload an event banner.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 3. Validasi Tanggal (Tidak boleh masa lampau)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_selectedDate.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event date cannot be in the past.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 4. Validasi Jam Selesai harus setelah Jam Mulai
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after event start time.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 5. Validasi Lokasi (Wajib diisi, tidak boleh fallback kosong)
    final locationText = _locationController.text.trim();
    if (locationText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event location cannot be empty.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 6. Validasi Deskripsi (Wajib diisi, tidak boleh fallback kosong)
    final descText = _descriptionController.text.trim();
    if (descText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event description cannot be empty.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 7. Validasi Autentikasi Login
    final auth = context.read<AuthProvider>();
    if (auth.token == null || auth.token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in first to publish an event.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final eventProvider = context.read<EventProvider>();

    try {
      String? finalFotoEvent = _uploadedBannerUrl ?? _selectedAssetBanner;

      // Jika user sudah memilih banner lokal tapi belum sempat terunggah ke backend
      if (finalFotoEvent == null && _bannerBytes != null) {
        try {
          final uploaded = await eventProvider.uploadBannerImage(
            token: auth.token!,
            bytes: _bannerBytes!,
            filename: _bannerFileName ?? 'banner.jpg',
          );
          finalFotoEvent = uploaded;
        } catch (_) {
          // Jika server upload banner gagal, gunakan nama file atau template lokal
          finalFotoEvent = _selectedAssetBanner ?? 'assets/images/event_library.jpg';
        }
      }

      final tglMulai = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final tglSelesai = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      await eventProvider.createEvent(
        token: auth.token!,
        judul: titleText,
        deskripsi: descText,
        kategori: 'Komunitas',
        lokasi: locationText,
        tanggalMulai: tglMulai,
        tanggalSelesai: tglSelesai,
        kuota: 100,
        fotoEvent: finalFotoEvent,
        status: 'APPROVED',
      );

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Event created successfully!'),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPublishing = false;
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

  /// Komponen tombol navigasi bawah Librava
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
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      if (_isAdmin) {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, _, _) => const AdminDashboardPage(),
                            transitionDuration: Duration.zero,
                          ),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, _, _) => const HomePage(),
                            transitionDuration: Duration.zero,
                          ),
                        );
                      }
                    }
                  },
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
                      // 1. Event title
                      const Text(
                        'Event title',
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
                          hintText: 'Book Exchange Day',
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

                      // 2. Event banner (Dashed Box Upload Sendiri)
                      const Text(
                        'Event banner',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B6882),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildBannerBox(),

                      const SizedBox(height: 18),

                      // 3. Date & Time Row (Side by side)
                      Row(
                        children: [
                          // Kolom Date
                          Expanded(
                            flex: 9,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B6882),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pilihTanggal,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
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
                                              _formatDateDisplay(_selectedDate),
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

                          const SizedBox(width: 10),

                          // Kolom Time
                          Expanded(
                            flex: 11,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Time',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B6882),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pilihWaktu,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
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
                                              _formatTimeDisplay(
                                                  _startTime, _endTime),
                                              style: const TextStyle(
                                                fontSize: 12.5,
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

                      // 4. Location
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B6882),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: 'Open Library Tel-U',
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
                          hintText: 'Tell student about your event',
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

                // Tombol "Publish event" di bawah kartu putih (Sesuai Mockup)
                Container(
                  width: double.infinity,
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
                    onPressed: _isPublishing ? null : _publishEvent,
                    child: _isPublishing
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Publish event',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _isAdmin
          ? const AdminBottomNav(selectedIndex: 0)
          : Container(
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

/// CustomPainter untuk menggambar garis putus-putus ungu (Dashed Border)
/// pada kotak upload banner sesuai mockup UI.
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
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
