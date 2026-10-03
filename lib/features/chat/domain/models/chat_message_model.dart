class ChatMessageModel {
  final String id;
  final String transactionId;
  final String senderId;
  final String receiverId;
  final String pesan;
  final bool isRead;
  final String sentAt;
  final String? senderNama;

  const ChatMessageModel({
    required this.id,
    required this.transactionId,
    required this.senderId,
    required this.receiverId,
    required this.pesan,
    this.isRead = false,
    required this.sentAt,
    this.senderNama,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      transactionId:
          (json['transaction_id'] ?? json['transactionId'])?.toString() ?? '',
      senderId: (json['sender_id'] ?? json['senderId'])?.toString() ?? '',
      receiverId:
          (json['receiver_id'] ?? json['receiverId'])?.toString() ?? '',
      pesan: json['pesan'] ?? '',
      isRead: json['is_read'] ?? json['isRead'] ?? false,
      sentAt: json['sent_at'] ?? json['sentAt'] ?? '',
      senderNama: json['sender_nama'] ?? json['senderNama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'pesan': pesan,
      'is_read': isRead,
      'sent_at': sentAt,
      'sender_nama': senderNama,
    };
  }
}
