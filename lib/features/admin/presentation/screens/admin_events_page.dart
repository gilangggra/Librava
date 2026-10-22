import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_constants.dart';
import '../../../events/domain/models/event_model.dart';
import '../../../events/presentation/providers/event_provider.dart';
import '../../../events/presentation/screens/add_event_page.dart';
import '../../../events/presentation/screens/event_detail_page.dart';
import '../widgets/admin_bottom_nav.dart';

/// Halaman Daftar Data Event Kampus untuk Admin (Event data).
/// Didesain 100% presisi dan konsisten dengan rancangan visual mockup "Event data".
class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({super.key});

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _kataKunci = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchEvents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final dayName = hari[dt.weekday];
    final monthName = bulan[dt.month];
    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }

  Widget _buildEventThumbnail(String? foto) {
    final String path = (foto ?? '').trim();
    String? fullNetworkUrl;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      fullNetworkUrl = path;
    } else if (path.startsWith('/uploads/') || path.startsWith('uploads/')) {
      final clean = path.startsWith('/') ? path : '/$path';
      fullNetworkUrl = '${ApiConstants.baseUrl.replaceAll('/api', '')}$clean';
    }

    Widget fallbackWidget() {
      return Container(
        width: 56,
        height: 74,
        color: const Color(0xFFEBE7FD),
        child: const Icon(
          Icons.calendar_month_rounded,
          color: AppColors.primary,
          size: 24,
        ),
      );
    }

    if (fullNetworkUrl != null) {
      return Image.network(
        fullNetworkUrl,
        width: 56,
        height: 74,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallbackWidget(),
      );
    }

    if (path.isNotEmpty && path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: 56,
        height: 74,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallbackWidget(),
      );
    }

    return Image.asset(
      'assets/images/event_library.jpg',
      width: 56,
      height: 74,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallbackWidget(),
    );
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
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildEventRow(EventModel event) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailPage(event: event, isAdmin: true),
          ),
        );
        if (mounted) {
          context.read<EventProvider>().fetchEvents(forceRefresh: true);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildEventThumbnail(event.fotoEvent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.judul,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF130F26),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.calendar,
                        size: 13,
                        color: Color(0xFF7E7A92),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _formatDate(event.tanggalMulai),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7E7A92),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.location_solid,
                        size: 13,
                        color: Color(0xFF7E7A92),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          event.lokasi,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF7E7A92),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(event.displayStatus),
                const SizedBox(height: 14),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKotakSearch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1A34).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _kataKunci = val.trim().toLowerCase();
          });
        },
        style: const TextStyle(fontSize: 15, color: Color(0xFF130F26)),
        decoration: const InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            color: Color(0xFF8A88A5),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: Color(0xFF8A88A5),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final allEvents = eventProvider.events;

    final displayedEvents = _kataKunci.isEmpty
        ? allEvents
        : allEvents.where((e) {
            final judul = e.judul.toLowerCase();
            final lokasi = e.lokasi.toLowerCase();
            final status = e.displayStatus.toLowerCase();
            return judul.contains(_kataKunci) ||
                lokasi.contains(_kataKunci) ||
                status.contains(_kataKunci);
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => eventProvider.fetchEvents(forceRefresh: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Header Title: "Event data" & Tombol Tambah Event
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Event data',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF130F26),
                          letterSpacing: -0.5,
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddEventPage(isAdmin: true),
                            ),
                          );
                          if (context.mounted) {
                            context.read<EventProvider>().fetchEvents(forceRefresh: true);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEAFE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add_rounded, size: 15, color: AppColors.primary),
                              SizedBox(width: 3),
                              Text(
                                'Tambah',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Search Box
                  _buildKotakSearch(),

                  const SizedBox(height: 18),

                  // Event Data White Card Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E1A34).withValues(alpha: 0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Builder(
                      builder: (_) {
                        if (eventProvider.isLoading && allEvents.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }

                        if (displayedEvents.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _kataKunci.isNotEmpty
                                        ? 'Tidak ada event yang sesuai dengan pencarian.'
                                        : 'Belum ada data event kampus.',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: Color(0xFF7E7A92),
                                    ),
                                  ),
                                  if (_kataKunci.isEmpty) ...[
                                    const SizedBox(height: 10),
                                    TextButton.icon(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const AddEventPage(isAdmin: true),
                                          ),
                                        );
                                        if (context.mounted) {
                                          context.read<EventProvider>().fetchEvents(forceRefresh: true);
                                        }
                                      },
                                      icon: const Icon(Icons.add, size: 16),
                                      label: const Text('Buat Event Baru'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            for (int i = 0; i < displayedEvents.length; i++) ...[
                              _buildEventRow(displayedEvents[i]),
                              if (i < displayedEvents.length - 1)
                                const Divider(
                                  color: Color(0xFFF0EEF8),
                                  height: 20,
                                  thickness: 1,
                                ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(selectedIndex: 0),
    );
  }
}
