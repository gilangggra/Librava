import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../books/presentation/screens/my_book_page.dart';
import '../../../books/presentation/screens/search_page.dart';
import '../../../chat/presentation/screens/chat_page.dart';
import '../../../chat/presentation/screens/chat_room_page.dart';
import '../../../home/presentation/screens/home_page.dart';
import 'profile_page.dart';

/// Halaman Profile View untuk melihat profil pengguna / pemilik buku
/// yang terhubung dan tersinkronisasi langsung dengan Database backend Librava.
class ProfileViewPage extends StatefulWidget {
  final UserModel? user;
  final String? userId;
  final String? name;
  final String? role;
  final String? bio;
  final String? email;
  final String? phone;
  final int? booksRead;
  final int? booksBorrowed;
  final int? favorites;
  final String? transactionId;

  const ProfileViewPage({
    super.key,
    this.user,
    this.userId,
    this.name,
    this.role,
    this.bio,
    this.email,
    this.phone,
    this.booksRead,
    this.booksBorrowed,
    this.favorites,
    this.transactionId,
  });

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  UserModel? _fetchedUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null && widget.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _muatProfilDariDatabase();
      });
    }
  }

  Future<void> _muatProfilDariDatabase() async {
    if (widget.userId == null) return;
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final userDb = await auth.ambilProfilPenggunaLain(widget.userId!);
    if (mounted) {
      setState(() {
        _fetchedUser = userDb;
        _isLoading = false;
      });
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8A88A5),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6E6B87),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required int count,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 28,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF130F26),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8A88A5),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, a1, a2) => const HomePage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, a1, a2) => const MyBookPage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, a1, a2) => const SearchPage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, a1, a2) => const ChatPage(),
              transitionDuration: Duration.zero,
            ),
          );
        } else if (index == 4) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, a1, a2) => const ProfilePage(),
                transitionDuration: Duration.zero,
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 60,
        height: 46,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE5E0FD) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            icon,
            color: isSelected ? AppColors.primary : const Color(0xFF52518D),
            size: 26,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider? auth;
    try {
      auth = context.watch<AuthProvider>();
    } catch (_) {}

    final authUser = auth?.currentUser;
    final activeUser = widget.user ?? _fetchedUser;

    // Nilai tersinkronisasi dengan Database PostgreSQL
    final displayName = widget.name ??
        activeUser?.nama ??
        authUser?.nama ??
        'Ujang Knalpot';

    final displayRole = widget.role ??
        (activeUser?.username != null && activeUser!.username.isNotEmpty
            ? activeUser.username
            : (authUser?.username != null && authUser!.username.isNotEmpty
                ? authUser.username
                : 'User'));

    final displayBio = widget.bio ??
        (activeUser?.bio != null && activeUser!.bio.isNotEmpty
            ? activeUser.bio
            : (authUser?.bio != null && authUser!.bio.isNotEmpty
                ? authUser.bio
                : 'A casual reader'));

    final displayEmail = widget.email ??
        activeUser?.email ??
        authUser?.email ??
        'ujang@example.com';

    final displayPhone = widget.phone ??
        (activeUser?.phone != null && activeUser!.phone.isNotEmpty
            ? activeUser.phone
            : (authUser?.phone != null && authUser!.phone.isNotEmpty
                ? authUser.phone
                : '+62 8959982898'));

    final displayBooksRead = widget.booksRead ??
        activeUser?.booksRead ??
        authUser?.booksRead ??
        12;

    final displayBooksBorrowed = widget.booksBorrowed ??
        activeUser?.booksBorrowed ??
        authUser?.booksBorrowed ??
        3;

    final displayFavorites = widget.favorites ??
        activeUser?.favorites ??
        authUser?.favorites ??
        5;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header: Back button (jika ada) + Judul "Profile view"
              Row(
                children: [
                  if (Navigator.canPop(context)) ...[
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.only(right: 12),
                        child: const Icon(
                          CupertinoIcons.chevron_left,
                          size: 26,
                          color: Color(0xFF130F26),
                        ),
                      ),
                    ),
                  ],
                  const Text(
                    'Profile view',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF130F26),
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (_isLoading) ...[
                    const SizedBox(width: 12),
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Kartu Pengguna (User Card) dengan tombol Chat mengambang di bawah
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 42),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar Pengguna dengan border hitam
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFC7C2FB),
                            border: Border.all(
                              color: const Color(0xFF130F26),
                              width: 2.2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 52,
                              color: Color(0xFF130F26),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          displayRole,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF130F26),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(
                          color: Color(0xFFEDEDF5),
                          height: 1,
                          thickness: 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            displayBio,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF757489),
                            ),
                          ),
                        ),
                        const Divider(
                          color: Color(0xFFEDEDF5),
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Name', displayName),
                        const SizedBox(height: 8),
                        const Divider(
                          color: Color(0xFFEDEDF5),
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Email', displayEmail),
                        const SizedBox(height: 12),
                        _buildInfoRow('Phone', displayPhone),
                      ],
                    ),
                  ),

                  // Tombol Chat Mengambang
                  Positioned(
                    bottom: 0,
                    child: SizedBox(
                      width: 220,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatRoomPage(
                                userName: displayName,
                                isOnline: true,
                                transactionId: widget.transactionId,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E5BF7),
                          elevation: 8,
                          shadowColor:
                              const Color(0xFF5E5BF7).withValues(alpha: 0.45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Chat',
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
              const SizedBox(height: 32),

              // Bagian Activity (Tersinkron dengan data database)
              const Text(
                'Activity',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF130F26),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 14),

              // Kartu Activity (Books Read, Books Borrowed, Favorites)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActivityItem(
                        icon: CupertinoIcons.book,
                        count: displayBooksRead,
                        label: 'Books Read',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 44,
                      color: const Color(0xFFE8E6F2),
                    ),
                    Expanded(
                      child: _buildActivityItem(
                        icon: CupertinoIcons.arrow_2_squarepath,
                        count: displayBooksBorrowed,
                        label: 'Books Borrowed',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 44,
                      color: const Color(0xFFE8E6F2),
                    ),
                    Expanded(
                      child: _buildActivityItem(
                        icon: CupertinoIcons.bookmark,
                        count: displayFavorites,
                        label: 'Favorites',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
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
              context: context,
              index: 0,
              icon: CupertinoIcons.house,
            ),
            _buildNavItem(
              context: context,
              index: 1,
              icon: CupertinoIcons.book,
            ),
            _buildNavItem(
              context: context,
              index: 2,
              icon: CupertinoIcons.search,
            ),
            _buildNavItem(
              context: context,
              index: 3,
              icon: CupertinoIcons.ellipses_bubble,
            ),
            _buildNavItem(
              context: context,
              index: 4,
              icon: CupertinoIcons.person_fill,
              isSelected: true,
            ),
          ],
        ),
      ),
    );
  }
}
