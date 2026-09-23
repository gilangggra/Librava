class ChatItemModel {
  final String id;
  final String name;
  final String lastMessage;
  final String date;
  final bool isOnline;
  final bool hasUnread;

  const ChatItemModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.date,
    this.isOnline = false,
    this.hasUnread = false,
  });

  ChatItemModel copyWith({
    String? id,
    String? name,
    String? lastMessage,
    String? date,
    bool? isOnline,
    bool? hasUnread,
  }) {
    return ChatItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      date: date ?? this.date,
      isOnline: isOnline ?? this.isOnline,
      hasUnread: hasUnread ?? this.hasUnread,
    );
  }
}
