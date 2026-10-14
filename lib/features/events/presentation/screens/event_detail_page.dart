import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_constants.dart';
import '../../../admin/presentation/screens/admin_dashboard_page.dart';
import '../../../admin/presentation/widgets/admin_bottom_nav.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../books/presentation/screens/my_book_page.dart';
import '../../../books/presentation/screens/search_page.dart';
import '../../../chat/presentation/screens/chat_page.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../profile/presentation/screens/profile_page.dart';
import '../../data/services/event_api_service.dart';
import '../../domain/models/event_model.dart';
import '../providers/event_provider.dart';

/// Halaman Detail / View Event Kampus Librava.
/// Didesain teliti, rapi, dan 100% konsisten dengan rancangan visual mockup "Event view".
class EventDetailPage extends StatefulWidget {
  final EventModel event;
  final bool? isAdmin;

  const EventDetailPage({
    super.key,
    required this.event,
    this.isAdmin,
  });

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late EventModel _event;
  final int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _refreshEventDetail();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final auth = context.read<AuthProvider>();
        if (auth.token != null) {
          context.read<EventProvider>().fetchMyEvents(auth.token!);
        }
      }
    });
  }

  /// Mengecek apakah tampilan dibuka sebagai Admin atau Mahasiswa
  bool _checkIsAdmin(BuildContext context) {
    if (widget.isAdmin != null) return widget.isAdmin!;
    final auth = context.watch<AuthProvider>();
    return auth.currentUser?.role.toLowerCase() == 'admin';
  }

  /// Mengambil data teranyar langsung dari backend database
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

  /// Dialog pop-up konfirmasi Approve / Reject sesuai mockup
  Future<bool?> _tampilkanDialogKonfirmasi(
    BuildContext context, {
    required bool isApprove,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isApprove
                    ? 'Are you sure you want to approve\nthis event?'
                    : 'Are you sure you want to reject\nthis event?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF130F26),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5B4DFF).withValues(alpha: 0.28),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B4DFF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          isApprove ? 'Approve' : 'Reject',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE2E0FD),
                          foregroundColor: const Color(0xFF5B4DFF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Menangani proses approval event oleh Admin (Approve / Reject)
  Future<void> _prosesApprovalEvent(
    BuildContext context, {
    required bool approve,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final auth = context.read<AuthProvider>();
    final eventProvider = context.read<EventProvider>();

    final setuju = await _tampilkanDialogKonfirmasi(context, isApprove: approve);
    if (setuju != true || !mounted) return;

    final targetStatus = approve ? 'APPROVED' : 'REJECTED';

    try {
      if (auth.token != null && auth.token!.isNotEmpty) {
        final updated = await eventProvider.updateEventStatus(
          token: auth.token!,
          eventId: _event.id,
          status: targetStatus,
        );
        if (mounted) {
          setState(() {
            _event = updated;
          });
        }
      }

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                approve ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  approve
                      ? 'Event "${_event.judul}" berhasil disetujui (Status: APPROVED).'
                      : 'Event "${_event.judul}" telah ditolak (Status: REJECTED).',
                ),
              ),
            ],
          ),
          backgroundColor: approve ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      if (navigator.canPop()) {
        navigator.pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color fg;

    final s = status.toLowerCase();
    if (s.contains('reject')) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFEF4444);
    } else if (s.contains('pend')) {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
    } else {
      bg = const Color(0xFFD1FADF);
      fg = const Color(0xFF12B76A);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  /// Menangani proses pendaftaran event oleh Mahasiswa
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
    final katLower = event.kategori.toLowerCase();
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
      borderRadius: BorderRadius.circular(22),
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

  /// Tombol bar navigasi bawah untuk mahasiswa
  Widget _buildUserNavItem({
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

  Widget _buildUserBottomNav() {
    return Container(
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
          _buildUserNavItem(
            index: 0,
            activeIcon: CupertinoIcons.house_fill,
            inactiveIcon: CupertinoIcons.house,
          ),
          _buildUserNavItem(
            index: 1,
            activeIcon: CupertinoIcons.book_fill,
            inactiveIcon: CupertinoIcons.book,
          ),
          _buildUserNavItem(
            index: 2,
            activeIcon: CupertinoIcons.search,
            inactiveIcon: CupertinoIcons.search,
          ),
          _buildUserNavItem(
            index: 3,
            activeIcon: CupertinoIcons.ellipses_bubble_fill,
            inactiveIcon: CupertinoIcons.ellipses_bubble,
          ),
          _buildUserNavItem(
            index: 4,
            activeIcon: CupertinoIcons.person_fill,
            inactiveIcon: CupertinoIcons.person,
          ),
        ],
      ),
    );
  }

  /// Tombol aksi Admin: Approve dan Reject (side-by-side sesuai mockup)
  Widget _buildAdminActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B4DFF).withValues(alpha: 0.32),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B4DFF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _prosesApprovalEvent(context, approve: true),
              child: const Text(
                'Approve',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEDEAFE),
                foregroundColor: const Color(0xFF5B4DFF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _prosesApprovalEvent(context, approve: false),
              child: const Text(
                'Reject',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Tombol aksi Mahasiswa: Join Event / Sudah Terdaftar
  Widget _buildStudentAction(BuildContext context) {
    return Builder(
      builder: (ctx) {
        final eventProvider = ctx.watch<EventProvider>();
        final isRegistered = eventProvider.isUserRegistered(_event.id);
        return Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isRegistered
                        ? const Color(0xFF16A34A)
                        : AppColors.primary)
                    .withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isRegistered
                  ? const Color(0xFF16A34A)
                  : AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: Icon(
              isRegistered
                  ? Icons.check_circle_rounded
                  : CupertinoIcons.ticket_fill,
              size: 20,
            ),
            label: Text(
              isRegistered ? 'Sudah Terdaftar' : 'Join event',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            onPressed: isRegistered
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Anda telah terdaftar di event "${_event.judul}".'),
                        backgroundColor: const Color(0xFF16A34A),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                : () => _konfirmasiDaftar(context),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _checkIsAdmin(context);

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

                // Top App Bar: Back Button (Chevron Left)
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        if (isAdmin) {
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
                      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                      child: Icon(
                        CupertinoIcons.chevron_left,
                        size: 24,
                        color: Color(0xFF130F26),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Header Title: "Event view" sesuai mockup
                const Text(
                  'Event view',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF130F26),
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 18),

                // Event Image Banner
                _buildGambarBanner(),

                const SizedBox(height: 22),

                // Event Title & Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _event.judul,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF130F26),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(_event.displayStatus),
                  ],
                ),

                const SizedBox(height: 14),

                // Card Info: Date, Time, Location (White Card)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E1A34).withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Row 1: Tanggal (Calendar Icon)
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.calendar,
                            color: Color(0xFF4C3BCF),
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _formatDate(_event.tanggalMulai),
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B6880),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Row 2: Waktu (Clock Icon)
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFF4C3BCF),
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _formatTime(
                                _event.tanggalMulai,
                                _event.tanggalSelesai,
                              ),
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B6880),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Row 3: Lokasi (Pin Location Icon)
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.location_solid,
                            color: Color(0xFF4C3BCF),
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _event.lokasi,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B6880),
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
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E1A34).withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _event.deskripsi.trim().isNotEmpty
                        ? _event.deskripsi.trim()
                        : 'Book Exchange Day is a campus event where you can meet other book lovers, exchange your favorite books, and discover new reads. Everyone is welcome, whether you want to give, find, or simply talk about books!',
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF7E7A92),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // Actions: Admin Mode (Approve / Reject) vs Student Mode (Join Event)
                if (isAdmin)
                  _buildAdminActions(context)
                else
                  _buildStudentAction(context),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: isAdmin
          ? const AdminBottomNav(selectedIndex: 1)
          : _buildUserBottomNav(),
    );
  }
}
