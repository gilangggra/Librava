import prisma from '../config/prisma';
import { Transaction, TransactionStatus, TransactionType } from '../types';

export interface CreateTransactionDTO {
  requester_id: number;
  book_id: number;
  tipe_transaksi: TransactionType;
  barter_book_id?: number;
  deposit_dummy?: number;
  durasi_hari?: number;
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
  durasi_hari: tx.durasiHari || undefined,
  due_date: tx.dueDate || undefined,
  returned_at: tx.returnedAt || undefined,
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
    const deposit = Number(dto.deposit_dummy || 0);

    // Verifikasi saldo dummy peminjam jika transaksi membutuhkan deposit
    if (deposit > 0) {
      const requester = await prisma.user.findUnique({
        where: { id: dto.requester_id },
      });
      const currentSaldo = Number(requester?.saldoDummy || 0);
      if (currentSaldo < deposit) {
        const error: any = new Error('Saldo dummy Anda tidak mencukupi untuk membayar deposit transaksi ini.');
        error.statusCode = 400;
        throw error;
      }
    }

    const durasiHari = dto.durasi_hari || 7;
    const dueDate = dto.tipe_transaksi === 'BORROW'
      ? new Date(Date.now() + durasiHari * 24 * 60 * 60 * 1000)
      : null;

    const created = await prisma.$transaction(async (prismaTx) => {
      // Hold deposit ke escrow jika ada
      if (deposit > 0) {
        await prismaTx.user.update({
          where: { id: dto.requester_id },
          data: { saldoDummy: { decrement: deposit } },
        });
      }

      return prismaTx.transaction.create({
        data: {
          requesterId: dto.requester_id,
          ownerId: owner_id,
          bookId: dto.book_id,
          tipeTransaksi: dto.tipe_transaksi,
          barterBookId: dto.barter_book_id || null,
          status: 'MENUNGGU_KONFIRMASI',
          depositDummy: deposit,
          durasiHari: durasiHari,
          dueDate: dueDate,
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
      const updateData: any = { status: newStatus };
      if (newStatus === 'SELESAI') {
        updateData.returnedAt = new Date();
      }

      await prismaTx.transaction.update({
        where: { id },
        data: updateData,
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
      } else if (['DITOLAK', 'DIBATALKAN'].includes(newStatus)) {
        // Kembalikan status buku jadi Tersedia
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

        // Refund deposit dummy ke requester jika ada
        if (tx.deposit_dummy > 0) {
          await prismaTx.user.update({
            where: { id: tx.requester_id },
            data: { saldoDummy: { increment: tx.deposit_dummy } },
          });
        }
      } else if (newStatus === 'SELESAI') {
        if (tx.tipe_transaksi === 'BARTER') {
          // SWAP KEPEMILIKAN: book_id milik requester, barter_book_id milik owner
          await prismaTx.book.update({
            where: { id: tx.book_id },
            data: { ownerId: tx.requester_id, status: 'Tersedia' },
          });
          if (tx.barter_book_id) {
            await prismaTx.book.update({
              where: { id: tx.barter_book_id },
              data: { ownerId: tx.owner_id, status: 'Tersedia' },
            });
          }
        } else {
          // BORROW SELESAI: Buku dikembalikan ke pemilik asli
          await prismaTx.book.update({
            where: { id: tx.book_id },
            data: { status: 'Tersedia' },
          });

          // Refund deposit dummy ke requester saat buku selesai dikembalikan
          if (tx.deposit_dummy > 0) {
            await prismaTx.user.update({
              where: { id: tx.requester_id },
              data: { saldoDummy: { increment: tx.deposit_dummy } },
            });
          }
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

  static async confirmReturn(id: number, userId: number, userRole: string): Promise<Transaction> {
    return this.updateStatus(id, userId, userRole, 'SELESAI');
  }
}
