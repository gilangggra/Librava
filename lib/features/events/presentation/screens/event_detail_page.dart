import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../books/presentation/screens/my_book_page.dart';
import '../../../books/presentation/screens/search_page.dart';
import '../../../chat/presentation/screens/chat_page.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../profile/presentation/screens/profile_page.dart';
import '../../data/services/event_api_service.dart';
import '../../domain/models/event_model.dart';
import '../providers/event_provider.dart';
import 'add_event_page.dart';

/// Halaman Detail Event Kampus Librava.
/// Didesain teliti dan konsisten 100% mengikuti mockup desain tampilan.
class EventDetailPage extends StatefulWidget {
  final EventModel event;

  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late EventModel _event;
  final int _selectedIndex = 0; // Tab Home aktif

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _refreshEventDetail();
  }

  /// Mengambil data teranyar langsung dari backend database (kuota, pendaftar, dll)
  Future<void> _refreshEventDetail() async {
    try {
      final latest = await EventApiService().getEventById(_event.id);
      if (mounted) {
        setState(() {
          _event = latest;
        });
      }
    } catch (_) {}
  }

  /// Format tanggal sesuai mockup: "Monday, 12 Oct 2026"
  String _formatDate(DateTime dt) {
    const hari = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
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
    final namaHari = hari[dt.weekday];
    final namaBulan = bulan[dt.month];
    return '$namaHari, ${dt.day} $namaBulan ${dt.year}';
  }

  /// Format jam rentang waktu sesuai mockup: "10:00 AM – 4:00 PM"
  String _formatTime(DateTime start, DateTime? end) {
    String to12Hour(DateTime d) {
      final h = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
      final m = d.minute.toString().padLeft(2, '0');
      final ampm = d.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    }

    if (end != null) {
      return '${to12Hour(start)} – ${to12Hour(end)}';
    } else {
      final defaultEnd = start.add(const Duration(hours: 6));
      return '${to12Hour(start)} – ${to12Hour(defaultEnd)}';
    }
  }

  /// Menangani proses pendaftaran event
  Future<void> _konfirmasiDaftar(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null || auth.token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu untuk bergabung di event.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final eventProvider = context.read<EventProvider>();

    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Join Event Kampus?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'Apakah Anda ingin mendaftar pada agenda "${_event.judul}"?\n\n'
          'Sisa kuota: ${_event.sisaKuota} peserta.',
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF555268), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF7E7A92))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Join Sekarang',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (setuju != true || !mounted) return;

    try {
      await eventProvider.registerEvent(
        token: auth.token!,
        eventId: _event.id,
      );

      if (!mounted) return;

      setState(() {
        _event = _event.copyWith(
          jumlahPendaftar: _event.jumlahPendaftar + 1,
        );
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Selamat! Anda berhasil terdaftar di event "${_event.judul}".',
          ),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
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

  /// Membuka halaman Tambah Event (AddEventPage) sesuai mockup desain
  void _bukaModalAddEvent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEventPage(),
      ),
    );
  }

  String _getDefaultEventAsset(EventModel event) {
    if (event.fotoEvent != null &&
        event.fotoEvent!.trim().startsWith('assets/')) {
      return event.fotoEvent!.trim();
    }
    const defaults = [
      'assets/images/event_library.jpg',
      'assets/images/event_reading_meetup.jpg',
      'assets/images/event_book_discussion.jpg',
    ];
    final judulLower = event.judul.toLowerCase();
    final katLower = (event.kategori ?? '').toLowerCase();
    if (judulLower.contains('read') ||
        judulLower.contains('circle') ||
        katLower.contains('circle') ||
        katLower.contains('reading')) {
      return 'assets/images/event_reading_meetup.jpg';
    }
    if (judulLower.contains('panel') ||
        judulLower.contains('review') ||
        judulLower.contains('workshop') ||
        katLower.contains('workshop') ||
        katLower.contains('seminar')) {
      return 'assets/images/event_book_discussion.jpg';
    }
    return defaults[(event.id.abs()) % defaults.length];
  }

  /// Banner gambar event dengan sudut melengkung halus
  Widget _buildGambarBanner() {
    final foto = _event.fotoEvent ?? '';
    final isHttp = foto.startsWith('http://') || foto.startsWith('https://');
    final isUploads =
        foto.startsWith('/uploads/') || foto.startsWith('uploads/');
    final fallbackAsset = _getDefaultEventAsset(_event);

    String? fullNetworkUrl;
    if (isHttp) {
      fullNetworkUrl = foto;
    } else if (isUploads) {
      final cleanPath = foto.startsWith('/') ? foto : '/$foto';
      final rootServer = ApiConstants.baseUrl.replaceAll('/api', '');
      fullNetworkUrl = '$rootServer$cleanPath';
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 215,
        width: double.infinity,
        child: fullNetworkUrl != null
            ? Image.network(
                fullNetworkUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Image.asset(
                  fallbackAsset,
                  fit: BoxFit.cover,
                ),
              )
            : (foto.isNotEmpty && foto.startsWith('assets/')
                ? Image.asset(
                    foto,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.asset(
                      fallbackAsset,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    fallbackAsset,
                    fit: BoxFit.cover,
                  )),
      ),
    );
  }

  /// Tombol bar navigasi bawah yang seragam dengan halaman utama Librava
  Widget _buildNavItem({
    required int index,
    required IconData activeIcon,
    required IconData inactiveIcon,
  }) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        if (index == 0) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const HomePage(),
                transitionDuration: Duration.zero,
              ),
            );
          }
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

                // Top App Bar: Back Button & Add Event Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, _, _) => const HomePage(),
                              transitionDuration: Duration.zero,
                            ),
                          );
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
                    InkWell(
                      onTap: () => _bukaModalAddEvent(context),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              color: Color(0xFF7D799B),
                              size: 26,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Add event',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF7D799B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Header Title: "Event detail"
                const Text(
                  'Event detail',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 18),

                // Event Image Banner
                _buildGambarBanner(),

                const SizedBox(height: 22),

                // Event Title: e.g. "Book Exhange Day"
                Text(
                  _event.judul,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                    letterSpacing: -0.3,
                  ),
                ),

                const SizedBox(height: 14),

                // Card Info: Date, Time, Location (Single White Card)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      // Row 1: Tanggal
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF4C3BCF),
                            size: 23,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _formatDate(_event.tanggalMulai),
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF555268),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Row 2: Waktu
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFF4C3BCF),
                            size: 23,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _formatTime(
                                _event.tanggalMulai,
                                _event.tanggalSelesai,
                              ),
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF555268),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Row 3: Lokasi
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFF4C3BCF),
                            size: 23,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _event.lokasi,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF555268),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Section Title: "About this event"
                const Text(
                  'About this event',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                  ),
                ),

                const SizedBox(height: 12),

                // Card Description
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    _event.deskripsi.isNotEmpty
                        ? _event.deskripsi
                        : 'Book Exchange Day is a campus event where you can meet other book lovers, exchange your favorite books, and discover new reads. Everyone is welcome, whether you want to give, find, or simply talk about books!',
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF75728A),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Button: "Join event"
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
                    onPressed: () => _konfirmasiDaftar(context),
                    child: const Text(
                      'Join event',
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
