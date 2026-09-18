import prisma from '../config/prisma';
import { Chat } from '../types';

const mapChatWithRelations = (chat: any): Chat => ({
  id: chat.id,
  transaction_id: chat.transactionId,
  sender_id: chat.senderId,
  receiver_id: chat.receiverId,
  pesan: chat.pesan,
  is_read: chat.isRead,
  sent_at: chat.sentAt,
  sender_nama: chat.sender?.namaLengkap,
});

export class ChatService {
  static async getMessages(transactionId: number, userId: number, userRole: string): Promise<Chat[]> {
    const tx = await prisma.transaction.findUnique({
      where: { id: transactionId },
    });

    if (!tx) {
      const error: any = new Error('Transaksi tidak ditemukan.');
      error.statusCode = 404;
      throw error;
    }

    if (userRole !== 'admin' && tx.requesterId !== userId && tx.ownerId !== userId) {
      const error: any = new Error('Anda tidak memiliki akses ke chat transaksi ini.');
      error.statusCode = 403;
      throw error;
    }

    await prisma.chat.updateMany({
      where: {
        transactionId,
        receiverId: userId,
        isRead: false,
      },
      data: {
        isRead: true,
      },
    });

    const chats = await prisma.chat.findMany({
      where: { transactionId },
      include: {
        sender: true,
      },
      orderBy: {
        sentAt: 'asc',
      },
    });

    return chats.map(mapChatWithRelations);
  }

  static async sendMessage(transactionId: number, senderId: number, pesan: string): Promise<Chat> {
    const tx = await prisma.transaction.findUnique({
      where: { id: transactionId },
    });

    if (!tx) {
      const error: any = new Error('Transaksi tidak ditemukan.');
      error.statusCode = 404;
      throw error;
    }

    if (tx.requesterId !== senderId && tx.ownerId !== senderId) {
      const error: any = new Error('Hanya pihak yang bertransaksi yang dapat mengirim pesan.');
      error.statusCode = 403;
      throw error;
    }

    const receiverId = tx.requesterId === senderId ? tx.ownerId : tx.requesterId;

    const chat = await prisma.chat.create({
      data: {
        transactionId,
        senderId,
        receiverId,
        pesan,
      },
      include: {
        sender: true,
      },
    });

    return mapChatWithRelations(chat);
  }
}
