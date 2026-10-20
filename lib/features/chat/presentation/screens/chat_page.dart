import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../books/presentation/screens/my_book_page.dart';
import '../../../books/presentation/screens/search_page.dart';
import '../../../home/presentation/screens/home_page.dart';
import '../../../home/presentation/screens/request_list_page.dart';
import '../../../profile/presentation/screens/profile_page.dart';
import '../../../transactions/domain/models/transaction_model.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';
import '../../domain/models/chat_item_model.dart';
import '../providers/chat_provider.dart';
import 'chat_room_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final int _selectedIndex = 3;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final token = authProvider.token;
        if (token != null) {
          try {
            final trxProvider =
                Provider.of<TransactionProvider>(context, listen: false);
            trxProvider.fetchTransaksi(token);
          } catch (_) {}
          try {
            final chatProvider =
                Provider.of<ChatProvider>(context, listen: false);
            chatProvider.fetchSummary(token);
            chatProvider.startPolling(token);
          } catch (_) {}
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    try {
      Provider.of<ChatProvider>(context, listen: false).stopPolling();
    } catch (_) {}
    _searchController.dispose();
    super.dispose();
  }

  List<ChatItemModel> _getDisplayChats(
      AuthProvider? authProvider,
      TransactionProvider? trxProvider,
      ChatProvider? chatProvider) {
    if (trxProvider == null || trxProvider.semuaTransaksi.isEmpty) {
      return [];
    }
    final currentUserId = authProvider?.currentUser?.id ?? '';
    final currentUserName =
        authProvider?.currentUser?.nama.trim().toLowerCase() ?? '';

    // Kelompokkan percakapan per lawan bicara (partner) agar 1 pengguna hanya muncul 1 kali
    // seperti pada aplikasi chat pada umumnya (WhatsApp, Telegram, dsb).
    final Map<String, List<TransactionModel>> partnerGroups = {};

    for (final trx in trxProvider.semuaTransaksi) {
      final bool isOwner = currentUserId.isNotEmpty && trx.pemilikId.isNotEmpty
          ? (trx.pemilikId == currentUserId)
          : (currentUserName.isNotEmpty &&
              trx.pemilikNama.trim().toLowerCase() == currentUserName);
      final partnerId = isOwner ? trx.pemohonId : trx.pemilikId;
      final partnerName = isOwner ? trx.pemohonNama : trx.pemilikNama;
      final partnerDisplay =
          partnerName.isNotEmpty ? partnerName : 'Mitra Librava';

      final groupKey = partnerId.isNotEmpty
          ? partnerId
          : partnerDisplay.trim().toLowerCase();

      partnerGroups.putIfAbsent(groupKey, () => []).add(trx);
    }

    final List<ChatItemModel> list = [];

    for (final entry in partnerGroups.entries) {
      final txs = entry.value;
      if (txs.isEmpty) continue;

      // Urutkan transaksi dari yang paling baru
      txs.sort((a, b) {
        final idA = int.tryParse(a.id) ?? 0;
        final idB = int.tryParse(b.id) ?? 0;
        return idB.compareTo(idA);
      });

      final primaryTrx = txs.first;
      final bool isOwner =
          currentUserId.isNotEmpty && primaryTrx.pemilikId.isNotEmpty
              ? (primaryTrx.pemilikId == currentUserId)
              : (currentUserName.isNotEmpty &&
                  primaryTrx.pemilikNama.trim().toLowerCase() ==
                      currentUserName);
      final partnerName =
          isOwner ? primaryTrx.pemohonNama : primaryTrx.pemilikNama;
      final partnerDisplay =
          partnerName.isNotEmpty ? partnerName : 'Mitra Librava';

      int totalUnread = 0;
      ({String text, String sentAt, String? senderNama})? mostRecentMsg;
      String latestTxId = primaryTrx.id;
      DateTime? latestMsgTime;

      for (final t in txs) {
        final u =
            chatProvider?.unreadFor(t.id) ?? (t.status == 'pending' ? 1 : 0);
        totalUnread += u;

        final m = chatProvider?.latestMessageFor(t.id);
        if (m != null && m.text.isNotEmpty) {
          DateTime? msgDt;
          try {
            msgDt = DateTime.parse(m.sentAt);
          } catch (_) {}

          if (mostRecentMsg == null) {
            mostRecentMsg = m;
            latestTxId = t.id;
            latestMsgTime = msgDt;
          } else if (msgDt != null &&
              (latestMsgTime == null || msgDt.isAfter(latestMsgTime))) {
            mostRecentMsg = m;
            latestTxId = t.id;
            latestMsgTime = msgDt;
          }
        }
      }

      final String lastMsg;
      if (mostRecentMsg != null && mostRecentMsg.text.isNotEmpty) {
        lastMsg = mostRecentMsg.text;
      } else {
        final isBarter = primaryTrx.jenisTransaksi.toLowerCase() == 'barter';
        lastMsg = isBarter
            ? 'Barter buku: ${primaryTrx.judulBuku}'
            : 'Peminjaman: ${primaryTrx.judulBuku}';
      }

      String displayDate =
          primaryTrx.tanggal.isNotEmpty ? primaryTrx.tanggal : 'Hari ini';
      if (latestMsgTime != null) {
        final now = DateTime.now();
        if (latestMsgTime.year == now.year &&
            latestMsgTime.month == now.month &&
            latestMsgTime.day == now.day) {
          final h = latestMsgTime.hour.toString().padLeft(2, '0');
          final m = latestMsgTime.minute.toString().padLeft(2, '0');
          displayDate = '$h.$m';
        } else {
          final y = latestMsgTime.year.toString();
          final m = latestMsgTime.month.toString().padLeft(2, '0');
          final d = latestMsgTime.day.toString().padLeft(2, '0');
          displayDate = '$y-$m-$d';
        }
      }

      list.add(
        ChatItemModel(
          id: latestTxId,
          name: partnerDisplay,
          lastMessage: lastMsg,
          date: displayDate,
          isOnline: true,
          hasUnread: totalUnread > 0,
          unreadCount: totalUnread,
        ),
      );
    }

    return list;
  }

  List<ChatItemModel> _filterChats(List<ChatItemModel> sourceList) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return sourceList;
    return sourceList
        .where((c) =>
            c.name.toLowerCase().contains(query) ||
            c.lastMessage.toLowerCase().contains(query))
        .toList();
  }

  Widget _buildChatCard(ChatItemModel chat) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomPage(
              userName: chat.name,
              isOnline: chat.isOnline,
              transactionId: chat.id,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E1A34).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF0EEF8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: Color(0xFF130F26),
                    ),
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF130F26),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF7E7A92),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.date,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF7E7A92),
                  ),
                ),
                const SizedBox(height: 6),
                if (chat.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    constraints:
                        const BoxConstraints(minWidth: 20, minHeight: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      chat.unreadCount > 9 ? '9+' : '${chat.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (chat.hasUnread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 8),
              ],
            ),
          ],
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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

  @override
  Widget build(BuildContext context) {
    AuthProvider? authProvider;
    try {
      authProvider = context.watch<AuthProvider>();
    } catch (_) {}

    TransactionProvider? trxProvider;
    try {
      trxProvider = context.watch<TransactionProvider>();
    } catch (_) {}

    ChatProvider? chatProvider;
    try {
      chatProvider = context.watch<ChatProvider>();
    } catch (_) {}

    final pendingRequestCount = trxProvider?.requestMasuk
            .where((t) => t.status == 'pending')
            .length ??
        0;

    final allChats =
        _getDisplayChats(authProvider, trxProvider, chatProvider);
    final filteredList = _filterChats(allChats);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF130F26),
                      letterSpacing: -0.5,
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RequestListPage(),
                        ),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: Color(0xFF5A5576),
                            size: 28,
                          ),
                        ),
                        if (pendingRequestCount > 0)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  pendingRequestCount > 9
                                      ? '9+'
                                      : '$pendingRequestCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E1A34).withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {});
                  },
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search message',
                    hintStyle: TextStyle(
                      color: Color(0xFFA5A0B8),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      CupertinoIcons.search,
                      color: Color(0xFFA5A0B8),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final token = authProvider?.token;
                  if (token != null) {
                    if (trxProvider != null) {
                      await trxProvider.fetchTransaksi(token);
                    }
                    if (chatProvider != null) {
                      await chatProvider.fetchSummary(token);
                    }
                  }
                },
                child: filteredList.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(22),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEBE7FD),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.chat_bubble_2_fill,
                                    color: AppColors.primary,
                                    size: 38,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Belum Ada Obrolan',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E1A34),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Obrolan akan otomatis tersedia ketika Anda memiliki transaksi peminjaman atau barter buku yang sedang berlangsung.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF7E7A92),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return _buildChatCard(filteredList[index]);
                        },
                      ),
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
              activeIcon: CupertinoIcons.ellipses_bubble_fill,
              inactiveIcon: CupertinoIcons.ellipses_bubble,
              badgeCount: chatProvider?.totalUnread ?? 0,
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
