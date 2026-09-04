import { Server as HttpServer } from 'http';
import { Server as SocketIOServer, Socket } from 'socket.io';
import jwt from 'jsonwebtoken';
import { UserPayload } from '../types';
import { ChatService } from '../services/chat.service';
import prisma from '../config/prisma';

interface AuthenticatedSocket extends Socket {
  data: {
    user?: UserPayload;
  };
}

let ioInstance: SocketIOServer | null = null;

export const initSocket = (httpServer: HttpServer): SocketIOServer => {
  const io = new SocketIOServer(httpServer, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST'],
      credentials: true,
    },
  });

  // Middleware autentikasi Socket.IO menggunakan JWT
  io.use((socket: AuthenticatedSocket, next) => {
    const token =
      socket.handshake.auth?.token ||
      (socket.handshake.headers.authorization?.startsWith('Bearer ')
        ? socket.handshake.headers.authorization.split(' ')[1]
        : null);

    if (!token) {
      return next(new Error('Autentikasi gagal: Token tidak disertakan.'));
    }

    const secret = process.env.JWT_SECRET || 'librava_secret_jwt_key_2026_super_secure';

    try {
      const decoded = jwt.verify(token, secret) as UserPayload;
      socket.data.user = decoded;
      next();
    } catch (err) {
      return next(new Error('Autentikasi gagal: Token tidak valid atau kedaluwarsa.'));
    }
  });

  io.on('connection', (socket: AuthenticatedSocket) => {
    const user = socket.data.user;
    if (process.env.NODE_ENV === 'development') {
      console.log(`[Socket.IO] User ${user?.nama_lengkap} (ID: ${user?.id}) terhubung. Socket ID: ${socket.id}`);
    }

    // Bergabung ke room transaksi
    socket.on('join_transaction', async (data: { transactionId: number }, callback?: (res: any) => void) => {
      try {
        const { transactionId } = data;
        if (!transactionId || !user) {
          if (callback) callback({ success: false, message: 'ID transaksi tidak valid.' });
          return;
        }

        const tx = await prisma.transaction.findUnique({
          where: { id: Number(transactionId) },
        });

        if (!tx) {
          if (callback) callback({ success: false, message: 'Transaksi tidak ditemukan.' });
          return;
        }

        if (user.role !== 'admin' && tx.requesterId !== user.id && tx.ownerId !== user.id) {
          if (callback) callback({ success: false, message: 'Akses terlarang. Anda bukan partisipan transaksi ini.' });
          return;
        }

        const roomName = `transaction_${transactionId}`;
        await socket.join(roomName);

        if (callback) {
          callback({
            success: true,
            message: `Berhasil bergabung ke room chat transaksi #${transactionId}.`,
            room: roomName,
          });
        }
      } catch (error: any) {
        if (callback) callback({ success: false, message: error.message });
      }
    });

    // Kirim pesan real-time
    socket.on('send_message', async (data: { transactionId: number; pesan: string }, callback?: (res: any) => void) => {
      try {
        const { transactionId, pesan } = data;
        if (!transactionId || !pesan || !pesan.trim() || !user) {
          if (callback) callback({ success: false, message: 'Pesan dan ID transaksi wajib diisi.' });
          return;
        }

        const savedChat = await ChatService.sendMessage(Number(transactionId), user.id, pesan.trim());

        const roomName = `transaction_${transactionId}`;
        // Broadcast ke semua user dalam room transaksi (termasuk pengirim atau exclude pengirim jika diinginkan)
        io.to(roomName).emit('receive_message', savedChat);

        if (callback) {
          callback({ success: true, message: 'Pesan terkirim.', data: savedChat });
        }
      } catch (error: any) {
        if (callback) callback({ success: false, message: error.message });
      }
    });

    // Indikator sedang mengetik (typing indicator)
    socket.on('typing', (data: { transactionId: number; isTyping: boolean }) => {
      if (!data.transactionId || !user) return;
      const roomName = `transaction_${data.transactionId}`;
      socket.to(roomName).emit('user_typing', {
        userId: user.id,
        userName: user.nama_lengkap,
        isTyping: data.isTyping,
      });
    });

    socket.on('disconnect', () => {
      if (process.env.NODE_ENV === 'development') {
        console.log(`[Socket.IO] User ${user?.nama_lengkap} terputus.`);
      }
    });
  });

  ioInstance = io;
  return io;
};

export const getIO = (): SocketIOServer => {
  if (!ioInstance) {
    throw new Error('Socket.IO belum diinisialisasi. Panggil initSocket(httpServer) terlebih dahulu.');
  }
  return ioInstance;
};
