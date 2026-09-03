import prisma from '../config/prisma';
import { Transaction, TransactionStatus, TransactionType } from '../types';

export interface CreateTransactionDTO {
  requester_id: number;
  book_id: number;
  tipe_transaksi: TransactionType;
  barter_book_id?: number;
  deposit_dummy?: number;
  lokasi_pertemuan?: string;
  waktu_pertemuan?: Date | string;
}

const mapTransactionWithRelations = (tx: any): Transaction => ({
  id: tx.id,
  requester_id: tx.requesterId,
  owner_id: tx.ownerId,
  book_id: tx.bookId,
  tipe_transaksi: tx.tipeTransaksi as TransactionType,
  barter_book_id: tx.barterBookId || undefined,
  status: tx.status as TransactionStatus,
  deposit_dummy: Number(tx.depositDummy || 0),
  lokasi_pertemuan: tx.lokasiPertemuan || undefined,
  waktu_pertemuan: tx.waktuPertemuan || undefined,
  created_at: tx.createdAt,
  updated_at: tx.updatedAt,
  requester_nama: tx.requester?.namaLengkap,
  requester_universitas: tx.requester?.universitas,
  owner_nama: tx.owner?.namaLengkap,
  owner_universitas: tx.owner?.universitas,
  book_judul: tx.book?.judul,
  book_foto: tx.book?.fotoBuku || undefined,
  barter_book_judul: tx.barterBook?.judul || undefined,
});

export class TransactionService {
  static async createTransaction(dto: CreateTransactionDTO): Promise<Transaction> {
    const requestedBook = await prisma.book.findUnique({
      where: { id: dto.book_id },
    });

    if (!requestedBook) {
      const error: any = new Error('Buku yang diminta tidak ditemukan.');
      error.statusCode = 404;
      throw error;
    }

    if (requestedBook.ownerId === dto.requester_id) {
      const error: any = new Error('Anda tidak dapat meminjam atau membarter buku milik sendiri.');
      error.statusCode = 400;
      throw error;
    }

    if (requestedBook.status !== 'Tersedia') {
      const error: any = new Error(`Buku saat ini sedang ${requestedBook.status.toLowerCase()}.`);
      error.statusCode = 400;
      throw error;
    }

    if (dto.tipe_transaksi === 'BARTER') {
      if (!dto.barter_book_id) {
        const error: any = new Error('Buku penukar (barter_book_id) wajib dipilih untuk transaksi Barter.');
        error.statusCode = 400;
        throw error;
      }

      const barterBook = await prisma.book.findUnique({
        where: { id: dto.barter_book_id },
      });

      if (!barterBook) {
        const error: any = new Error('Buku penukar tidak ditemukan.');
        error.statusCode = 404;
        throw error;
      }

      if (barterBook.ownerId !== dto.requester_id) {
        const error: any = new Error('Buku penukar harus merupakan buku milik Anda sendiri.');
        error.statusCode = 400;
        throw error;
      }

      if (barterBook.status !== 'Tersedia') {
        const error: any = new Error(`Buku penukar Anda saat ini berstatus ${barterBook.status.toLowerCase()}.`);
        error.statusCode = 400;
        throw error;
      }
    }

    const owner_id = requestedBook.ownerId;
    const deposit = dto.deposit_dummy || 0;

    const created = await prisma.transaction.create({
      data: {
        requesterId: dto.requester_id,
        ownerId: owner_id,
        bookId: dto.book_id,
        tipeTransaksi: dto.tipe_transaksi,
        barterBookId: dto.barter_book_id || null,
        status: 'MENUNGGU_KONFIRMASI',
        depositDummy: deposit,
        lokasiPertemuan: dto.lokasi_pertemuan || null,
        waktuPertemuan: dto.waktu_pertemuan ? new Date(dto.waktu_pertemuan) : null,
      },
      include: {
        requester: true,
        owner: true,
        book: true,
        barterBook: true,
      },
    });

    return mapTransactionWithRelations(created);
  }

  static async getUserTransactions(
    userId: number,
    filter?: { roleFilter?: 'requester' | 'owner'; status?: string }
  ): Promise<Transaction[]> {
    const where: any = {};

    if (filter?.roleFilter === 'requester') {
      where.requesterId = userId;
    } else if (filter?.roleFilter === 'owner') {
      where.ownerId = userId;
    } else {
      where.OR = [{ requesterId: userId }, { ownerId: userId }];
    }

    if (filter?.status) {
      where.status = filter.status;
    }

    const txs = await prisma.transaction.findMany({
      where,
      include: {
        requester: true,
        owner: true,
        book: true,
        barterBook: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    return txs.map(mapTransactionWithRelations);
  }

  static async getTransactionById(id: number, userId: number, userRole: string): Promise<Transaction> {
    const tx = await prisma.transaction.findUnique({
      where: { id },
      include: {
        requester: true,
        owner: true,
        book: true,
        barterBook: true,
      },
    });

    if (!tx) {
      const error: any = new Error('Transaksi tidak ditemukan.');
      error.statusCode = 404;
      throw error;
    }

    if (userRole !== 'admin' && tx.requesterId !== userId && tx.ownerId !== userId) {
      const error: any = new Error('Anda tidak memiliki akses ke transaksi ini.');
      error.statusCode = 403;
      throw error;
    }

    return mapTransactionWithRelations(tx);
  }

  static async updateStatus(
    id: number,
    userId: number,
    userRole: string,
    newStatus: TransactionStatus
  ): Promise<Transaction> {
    const tx = await this.getTransactionById(id, userId, userRole);

    if (userRole !== 'admin') {
      if (['DISETUJUI', 'DITOLAK'].includes(newStatus) && tx.owner_id !== userId) {
        const error: any = new Error('Hanya pemilik buku yang dapat menyetujui atau menolak transaksi.');
        error.statusCode = 403;
        throw error;
      }

      if (newStatus === 'DIBATALKAN' && tx.status !== 'MENUNGGU_KONFIRMASI') {
        const error: any = new Error('Transaksi yang sudah diproses tidak dapat dibatalkan.');
        error.statusCode = 400;
        throw error;
      }
    }

    await prisma.$transaction(async (prismaTx) => {
      await prismaTx.transaction.update({
        where: { id },
        data: { status: newStatus },
      });

      if (newStatus === 'DISETUJUI') {
        const bookStatus = tx.tipe_transaksi === 'BORROW' ? 'Dipinjam' : 'Dibarter';
        await prismaTx.book.update({
          where: { id: tx.book_id },
          data: { status: bookStatus },
        });
        if (tx.barter_book_id) {
          await prismaTx.book.update({
            where: { id: tx.barter_book_id },
            data: { status: 'Dibarter' },
          });
        }
      } else if (['DITOLAK', 'DIBATALKAN', 'SELESAI'].includes(newStatus)) {
        await prismaTx.book.update({
          where: { id: tx.book_id },
          data: { status: 'Tersedia' },
        });
        if (tx.barter_book_id) {
          await prismaTx.book.update({
            where: { id: tx.barter_book_id },
            data: { status: 'Tersedia' },
          });
        }
      }
    });

    return this.getTransactionById(id, userId, userRole);
  }

  static async setMeetingDetails(
    id: number,
    userId: number,
    userRole: string,
    lokasi: string,
    waktu?: Date | string
  ): Promise<Transaction> {
    await this.getTransactionById(id, userId, userRole);

    await prisma.transaction.update({
      where: { id },
      data: {
        lokasiPertemuan: lokasi,
        waktuPertemuan: waktu ? new Date(waktu) : new Date(),
        status: 'DALAM_PROSES',
      },
    });

    return this.getTransactionById(id, userId, userRole);
  }

  static async confirmHandover(id: number, userId: number, userRole: string): Promise<Transaction> {
    return this.updateStatus(id, userId, userRole, 'SELESAI');
  }
}
