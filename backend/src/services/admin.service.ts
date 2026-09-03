import prisma from '../config/prisma';

export class AdminService {
  static async getDashboardStats() {
    const [
      totalUsers,
      totalMahasiswa,
      totalBooks,
      availableBooks,
      borrowedBooks,
      barteredBooks,
      totalTx,
      pendingTx,
      activeTx,
      completedTx,
      depositAggregate,
      recentTxs,
    ] = await Promise.all([
      prisma.user.count(),
      prisma.user.count({ where: { role: 'mahasiswa' } }),
      prisma.book.count(),
      prisma.book.count({ where: { status: 'Tersedia' } }),
      prisma.book.count({ where: { status: 'Dipinjam' } }),
      prisma.book.count({ where: { status: 'Dibarter' } }),
      prisma.transaction.count(),
      prisma.transaction.count({ where: { status: 'MENUNGGU_KONFIRMASI' } }),
      prisma.transaction.count({
        where: {
          status: {
            in: ['DISETUJUI', 'DALAM_PROSES'],
          },
        },
      }),
      prisma.transaction.count({ where: { status: 'SELESAI' } }),
      prisma.transaction.aggregate({
        _sum: {
          depositDummy: true,
        },
      }),
      prisma.transaction.findMany({
        take: 10,
        orderBy: {
          createdAt: 'desc',
        },
        include: {
          requester: true,
          owner: true,
          book: true,
        },
      }),
    ]);

    const formattedRecentTx = recentTxs.map((t) => ({
      id: t.id,
      requester_id: t.requesterId,
      owner_id: t.ownerId,
      book_id: t.bookId,
      tipe_transaksi: t.tipeTransaksi,
      status: t.status,
      deposit_dummy: Number(t.depositDummy),
      lokasi_pertemuan: t.lokasiPertemuan,
      waktu_pertemuan: t.waktuPertemuan,
      created_at: t.createdAt,
      requester_nama: t.requester.namaLengkap,
      owner_nama: t.owner.namaLengkap,
      book_judul: t.book.judul,
    }));

    return {
      users: {
        total: totalUsers,
        mahasiswa: totalMahasiswa,
      },
      books: {
        total: totalBooks,
        tersedia: availableBooks,
        dipinjam: borrowedBooks,
        dibarter: barteredBooks,
      },
      transactions: {
        total: totalTx,
        menunggu_konfirmasi: pendingTx,
        dalam_proses: activeTx,
        selesai: completedTx,
        total_deposit_dummy: Number(depositAggregate._sum.depositDummy || 0),
      },
      recent_transactions: formattedRecentTx,
    };
  }

  static async getAllUsers(search?: string) {
    const where: any = {};
    if (search) {
      where.OR = [
        { namaLengkap: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } },
        { nim: { contains: search, mode: 'insensitive' } },
      ];
    }

    const users = await prisma.user.findMany({
      where,
      orderBy: {
        createdAt: 'desc',
      },
      select: {
        id: true,
        email: true,
        namaLengkap: true,
        nim: true,
        universitas: true,
        fotoProfil: true,
        role: true,
        createdAt: true,
      },
    });

    return users.map((u) => ({
      id: u.id,
      email: u.email,
      nama_lengkap: u.namaLengkap,
      nim: u.nim,
      universitas: u.universitas,
      foto_profil: u.fotoProfil,
      role: u.role,
      created_at: u.createdAt,
    }));
  }

  static async getAllTransactions(status?: string, type?: string) {
    const where: any = {};
    if (status) {
      where.status = status;
    }
    if (type) {
      where.tipeTransaksi = type;
    }

    const txs = await prisma.transaction.findMany({
      where,
      orderBy: {
        createdAt: 'desc',
      },
      include: {
        requester: true,
        owner: true,
        book: true,
      },
    });

    return txs.map((t) => ({
      id: t.id,
      requester_id: t.requesterId,
      owner_id: t.ownerId,
      book_id: t.bookId,
      tipe_transaksi: t.tipeTransaksi,
      barter_book_id: t.barterBookId,
      status: t.status,
      deposit_dummy: Number(t.depositDummy),
      lokasi_pertemuan: t.lokasiPertemuan,
      waktu_pertemuan: t.waktuPertemuan,
      created_at: t.createdAt,
      updated_at: t.updatedAt,
      requester_nama: t.requester.namaLengkap,
      requester_email: t.requester.email,
      owner_nama: t.owner.namaLengkap,
      owner_email: t.owner.email,
      book_judul: t.book.judul,
    }));
  }
}
