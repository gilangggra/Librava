class BookRequestItem {
  final String id;
  final String bookTitle;
  final String bookAuthor;
  final String bookCover;
  final String requesterName;
  final String requesterHandle;
  final String? requesterAvatar;
  final String type; // 'Barter' | 'Borrow'
  String status; // 'Pending' | 'Accepted' | 'Declined'

  // Barter specific fields
  final String? exchangeBookTitle;
  final String? exchangeBookAuthor;
  final String? exchangeBookCover;

  // Borrow specific fields
  final String? requestedPeriod; // e.g. '1 week'
  final String? dateRange; // e.g. 'Sep 21, 2026 - Sep 28, 2026'

  final String requestedOn; // e.g. 'Aug 21, 2026'
  final String? requesterUserId;
  final int? transactionId;

  BookRequestItem({
    required this.id,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookCover,
    required this.requesterName,
    required this.requesterHandle,
    this.requesterAvatar,
    required this.type,
    this.status = 'Pending',
    this.exchangeBookTitle,
    this.exchangeBookAuthor,
    this.exchangeBookCover,
    this.requestedPeriod,
    this.dateRange,
    this.requestedOn = 'Aug 21, 2026',
    this.requesterUserId,
    this.transactionId,
  });

  bool get isBarter => type.toLowerCase() == 'barter';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isDeclined => status.toLowerCase() == 'declined';
}
