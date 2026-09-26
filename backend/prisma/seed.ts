import 'dotenv/config';
import bcrypt from 'bcryptjs';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../src/generated/prisma/client';

const databaseUrl = process.env.DATABASE_URL?.trim();

if (!databaseUrl) {
  throw new Error('DATABASE_URL wajib diisi.');
}

const adapter = new PrismaPg({ connectionString: databaseUrl });
const prisma = new PrismaClient({ adapter });

async function main() {
  console.log('Seeding database...\n');

  const passwordHash = await bcrypt.hash('password123456', 12);

 
  console.log('Seeding Users...');

  const admin = await prisma.user.upsert({
    where: { email: 'admin@librava.com' },
    update: { passwordHash, role: 'admin' },
    create: {
      email: 'admin@librava.com',
      passwordHash,
      namaLengkap: 'Librava Admin',
      universitas: 'Telkom University',
      role: 'admin',
    },
  });
  console.log(`Admin: ${admin.email}`);

  const budi = await prisma.user.upsert({
    where: { email: 'budi@student.telkomuniversity.ac.id' },
    update: { passwordHash },
    create: {
      email: 'budi@student.telkomuniversity.ac.id',
      passwordHash,
      namaLengkap: 'Budi Santoso',
      nim: '1301210001',
      universitas: 'Telkom University',
      role: 'mahasiswa',
    },
  });
  console.log(`Mahasiswa: ${budi.email}`);

  const sari = await prisma.user.upsert({
    where: { email: 'sari@student.telkomuniversity.ac.id' },
    update: { passwordHash },
    create: {
      email: 'sari@student.telkomuniversity.ac.id',
      passwordHash,
      namaLengkap: 'Sari Dewi',
      nim: '1301210002',
      universitas: 'Telkom University',
      role: 'mahasiswa',
    },
  });
  console.log(`Mahasiswa: ${sari.email}`);

  const andi = await prisma.user.upsert({
    where: { email: 'andi@student.telkomuniversity.ac.id' },
    update: { passwordHash },
    create: {
      email: 'andi@student.telkomuniversity.ac.id',
      passwordHash,
      namaLengkap: 'Andi Pratama',
      nim: '1301210003',
      universitas: 'Telkom University',
      role: 'mahasiswa',
    },
  });
  console.log(`Mahasiswa: ${andi.email}`);

  const rina = await prisma.user.upsert({
    where: { email: 'rina@student.telkomuniversity.ac.id' },
    update: { passwordHash },
    create: {
      email: 'rina@student.telkomuniversity.ac.id',
      passwordHash,
      namaLengkap: 'Rina Kartika',
      nim: '1301210004',
      universitas: 'Telkom University',
      role: 'mahasiswa',
    },
  });
  console.log(`Mahasiswa: ${rina.email}`);

  // ══════════════════════════════════════════════════════════════
  // 2. BOOKS
  // ══════════════════════════════════════════════════════════════
  console.log('\needing Books...');

  const booksData = [
    // Budi's books
    {
      ownerId: budi.id,
      judul: 'Clean Code: A Handbook of Agile Software Craftsmanship',
      penulis: 'Robert C. Martin',
      penerbit: 'Prentice Hall',
      isbn: '9780132350884',
      deskripsi: 'Panduan menulis kode yang bersih, mudah dibaca, dan mudah di-maintain. Wajib baca buat software engineer.',
      kategori: 'Teknologi',
      status: 'Tersedia',
    },
    {
      ownerId: budi.id,
      judul: 'The Pragmatic Programmer',
      penulis: 'David Thomas, Andrew Hunt',
      penerbit: 'Addison-Wesley',
      isbn: '9780135957059',
      deskripsi: 'Tips dan teknik praktis untuk menjadi programmer yang lebih baik. Dari debugging sampai project management.',
      kategori: 'Teknologi',
      status: 'Tersedia',
    },
    // Sari's books
    {
      ownerId: sari.id,
      judul: 'Algoritma dan Pemrograman dengan Python',
      penulis: 'Rinaldi Munir',
      penerbit: 'Informatika Bandung',
      isbn: '9786023621118',
      deskripsi: 'Buku teks algoritma dan pemrograman dasar berbahasa Indonesia, cocok untuk mahasiswa semester awal.',
      kategori: 'Teknologi',
      status: 'Tersedia',
    },
    {
      ownerId: sari.id,
      judul: 'Filosofi Teras',
      penulis: 'Henry Manampiring',
      penerbit: 'Kompas Gramedia',
      isbn: '9786024126698',
      deskripsi: 'Filsafat Stoa untuk kehidupan modern. Buku self-improvement paling laris di Indonesia.',
      kategori: 'Self-Improvement',
      status: 'Tersedia',
    },
    // Andi's books
    {
      ownerId: andi.id,
      judul: 'Sistem Basis Data',
      penulis: 'Fathansyah',
      penerbit: 'Informatika Bandung',
      isbn: '9789797695392',
      deskripsi: 'Buku referensi database relasional, normalisasi, SQL, dan perancangan basis data.',
      kategori: 'Teknologi',
      status: 'Tersedia',
    },
    {
      ownerId: andi.id,
      judul: 'Atomic Habits',
      penulis: 'James Clear',
      penerbit: 'Penguin Random House',
      isbn: '9780735211292',
      deskripsi: 'Cara membangun kebiasaan baik dan menghilangkan kebiasaan buruk. Perubahan kecil, hasil luar biasa.',
      kategori: 'Self-Improvement',
      status: 'Tersedia',
    },
    // Rina's books
    {
      ownerId: rina.id,
      judul: 'Laskar Pelangi',
      penulis: 'Andrea Hirata',
      penerbit: 'Bentang Pustaka',
      isbn: '9789793062792',
      deskripsi: 'Novel inspiratif tentang perjuangan anak-anak di Belitung untuk meraih pendidikan.',
      kategori: 'Novel',
      status: 'Tersedia',
    },
    {
      ownerId: rina.id,
      judul: 'Jaringan Komputer dan Internet',
      penulis: 'Onno W. Purbo',
      penerbit: 'Andi Publisher',
      isbn: '9789792940435',
      deskripsi: 'Panduan lengkap jaringan komputer, TCP/IP, routing, dan keamanan jaringan.',
      kategori: 'Teknologi',
      status: 'Tersedia',
    },
  ];

  const books = [];
  for (const bookData of booksData) {
    const book = await prisma.book.create({ data: bookData });
    books.push(book);
    console.log(`  ✔ "${book.judul}" (${book.status}) — owner: ${bookData.ownerId}`);
  }

  // ══════════════════════════════════════════════════════════════
  // 3. TRANSACTIONS
  // ══════════════════════════════════════════════════════════════
  console.log('\nSeeding Transactions...');

  // TX1: Sari meminjam "Clean Code" dari Budi — SELESAI
  const tx1 = await prisma.transaction.create({
    data: {
      requesterId: sari.id,
      ownerId: budi.id,
      bookId: books[0].id, // Clean Code
      tipeTransaksi: 'pinjam',
      status: 'SELESAI',
      durasiHari: 7,
      lokasiPertemuan: 'Gedung Sate, Lantai 2 - Ruang Baca',
      waktuPertemuan: new Date('2026-09-20T10:00:00Z'),
      requesterConfirmedAt: new Date('2026-09-22T14:00:00Z'),
      ownerConfirmedAt: new Date('2026-09-22T15:00:00Z'),
    },
  });
  console.log(` TX-${tx1.id}: Sari pinjam "Clean Code" dari Budi [SELESAI]`);

  // TX2: Andi meminjam "Filosofi Teras" dari Sari — DALAM_PROSES
  const tx2 = await prisma.transaction.create({
    data: {
      requesterId: andi.id,
      ownerId: sari.id,
      bookId: books[3].id, // Filosofi Teras
      tipeTransaksi: 'pinjam',
      status: 'DALAM_PROSES',
      durasiHari: 14,
      lokasiPertemuan: 'Kantin MSU, Telkom University',
      waktuPertemuan: new Date('2026-09-28T13:00:00Z'),
    },
  });
  // Update book status
  await prisma.book.update({
    where: { id: books[3].id },
    data: { status: 'Dipinjam' },
  });
  console.log(`  TX-${tx2.id}: Andi pinjam "Filosofi Teras" dari Sari [DALAM_PROSES]`);

  // TX3: Rina barter "Laskar Pelangi" dengan "Pragmatic Programmer" Budi — DISETUJUI
  const tx3 = await prisma.transaction.create({
    data: {
      requesterId: rina.id,
      ownerId: budi.id,
      bookId: books[1].id, // Pragmatic Programmer
      tipeTransaksi: 'barter',
      barterBookId: books[6].id, // Laskar Pelangi
      status: 'DISETUJUI',
      lokasiPertemuan: 'Lobby GKU, Telkom University',
      waktuPertemuan: new Date('2026-09-30T09:00:00Z'),
    },
  });
  // Update both books
  await prisma.book.update({
    where: { id: books[1].id },
    data: { status: 'Dipinjam' },
  });
  await prisma.book.update({
    where: { id: books[6].id },
    data: { status: 'Dipinjam' },
  });
  console.log(`  TX-${tx3.id}: Rina barter "Laskar Pelangi" ↔ "Pragmatic Programmer" [DISETUJUI]`);

  // TX4: Budi meminjam "Sistem Basis Data" dari Andi — MENUNGGU_KONFIRMASI
  const tx4 = await prisma.transaction.create({
    data: {
      requesterId: budi.id,
      ownerId: andi.id,
      bookId: books[4].id, // Sistem Basis Data
      tipeTransaksi: 'pinjam',
      status: 'MENUNGGU_KONFIRMASI',
      durasiHari: 7,
    },
  });
  console.log(` TX-${tx4.id}: Budi mau pinjam "Sistem Basis Data" dari Andi [MENUNGGU_KONFIRMASI]`);

  // ══════════════════════════════════════════════════════════════
  // 4. CHATS
  // ══════════════════════════════════════════════════════════════
  console.log('\nSeeding Chats...');

  const chatsData = [
    // Chat di TX1 (Sari ↔ Budi — Clean Code)
    { transactionId: tx1.id, senderId: sari.id, receiverId: budi.id, pesan: 'Hai Budi, aku mau pinjam buku Clean Code-nya dong. Masih available?', isRead: true, sentAt: new Date('2026-09-18T08:00:00Z') },
    { transactionId: tx1.id, senderId: budi.id, receiverId: sari.id, pesan: 'Hai Sari! Masih kok, mau ketemu kapan?', isRead: true, sentAt: new Date('2026-09-18T08:15:00Z') },
    { transactionId: tx1.id, senderId: sari.id, receiverId: budi.id, pesan: 'Hari Sabtu jam 10 di Gedung Sate bisa?', isRead: true, sentAt: new Date('2026-09-18T08:20:00Z') },
    { transactionId: tx1.id, senderId: budi.id, receiverId: sari.id, pesan: 'Oke siap! Sampai ketemu ya 👍', isRead: true, sentAt: new Date('2026-09-18T08:25:00Z') },
    { transactionId: tx1.id, senderId: sari.id, receiverId: budi.id, pesan: 'Bukunya udah selesai aku baca, bagus banget! Kapan bisa balikin?', isRead: true, sentAt: new Date('2026-09-22T10:00:00Z') },
    { transactionId: tx1.id, senderId: budi.id, receiverId: sari.id, pesan: 'Nanti sore aja langsung di tempat yang sama ya', isRead: true, sentAt: new Date('2026-09-22T10:10:00Z') },

    // Chat di TX2 (Andi ↔ Sari — Filosofi Teras)
    { transactionId: tx2.id, senderId: andi.id, receiverId: sari.id, pesan: 'Sari, buku Filosofi Teras-nya boleh aku pinjam 2 minggu gak?', isRead: true, sentAt: new Date('2026-09-25T09:00:00Z') },
    { transactionId: tx2.id, senderId: sari.id, receiverId: andi.id, pesan: 'Boleh banget Andi! Kebetulan udah selesai dibaca.', isRead: true, sentAt: new Date('2026-09-25T09:30:00Z') },
    { transactionId: tx2.id, senderId: andi.id, receiverId: sari.id, pesan: 'Nice, ketemu di kantin MSU Senin jam 1 siang ya?', isRead: true, sentAt: new Date('2026-09-25T09:45:00Z') },
    { transactionId: tx2.id, senderId: sari.id, receiverId: andi.id, pesan: 'Oke deal! 📚', isRead: false, sentAt: new Date('2026-09-25T10:00:00Z') },

    // Chat di TX3 (Rina ↔ Budi — Barter)
    { transactionId: tx3.id, senderId: rina.id, receiverId: budi.id, pesan: 'Budi, mau gak barter Pragmatic Programmer-mu sama Laskar Pelangi aku?', isRead: true, sentAt: new Date('2026-09-26T07:00:00Z') },
    { transactionId: tx3.id, senderId: budi.id, receiverId: rina.id, pesan: 'Wah boleh juga tuh, Laskar Pelangi emang udah lama pengen baca!', isRead: true, sentAt: new Date('2026-09-26T07:30:00Z') },
    { transactionId: tx3.id, senderId: rina.id, receiverId: budi.id, pesan: 'Yay! Tukeran hari Selasa di lobby GKU ya jam 9 pagi', isRead: false, sentAt: new Date('2026-09-26T08:00:00Z') },

    // Chat di TX4 (Budi ↔ Andi — Menunggu)
    { transactionId: tx4.id, senderId: budi.id, receiverId: andi.id, pesan: 'Andi, boleh pinjam buku Sistem Basis Data-nya? Lagi butuh buat belajar UTS.', isRead: false, sentAt: new Date('2026-09-26T11:00:00Z') },
  ];

  for (const chat of chatsData) {
    await prisma.chat.create({ data: chat });
  }
  console.log(`  ✔ ${chatsData.length} chat messages created`);

  // ══════════════════════════════════════════════════════════════
  // 5. REVIEWS
  // ══════════════════════════════════════════════════════════════
  console.log('\nSeeding Reviews...');

  const reviewsData = [
    // Review untuk TX1 (SELESAI) — Sari review Budi, Budi review Sari
    {
      transactionId: tx1.id,
      reviewerId: sari.id,
      revieweeId: budi.id,
      rating: 5,
      komentar: 'Budi orangnya ramah dan tepat waktu. Buku-nya juga dalam kondisi bagus. Recommended!',
    },
    {
      transactionId: tx1.id,
      reviewerId: budi.id,
      revieweeId: sari.id,
      rating: 5,
      komentar: 'Sari sangat bertanggung jawab, buku dikembalikan tepat waktu dan dalam kondisi rapi. Terima kasih!',
    },
  ];

  for (const review of reviewsData) {
    await prisma.review.create({ data: review });
  }
  console.log(`  ✔ ${reviewsData.length} reviews created`);

  // ══════════════════════════════════════════════════════════════
  // SUMMARY
  // ══════════════════════════════════════════════════════════════
  console.log('\n══════════════════════════════════════════════');
  console.log('🌱 Seeding selesai!\n');
  console.log('📋 Semua Credentials (password sama: password123456)');
  console.log('   👑 Admin     : admin@librava.com');
  console.log('   🎓 Mahasiswa : budi@student.telkomuniversity.ac.id');
  console.log('   🎓 Mahasiswa : sari@student.telkomuniversity.ac.id');
  console.log('   🎓 Mahasiswa : andi@student.telkomuniversity.ac.id');
  console.log('   🎓 Mahasiswa : rina@student.telkomuniversity.ac.id');
  console.log('\n📊 Data Summary:');
  console.log('   📚 8 Books (berbagai kategori)');
  console.log('   🔄 4 Transactions (SELESAI, DALAM_PROSES, DISETUJUI, MENUNGGU)');
  console.log('   💬 14 Chat messages');
  console.log('   ⭐ 2 Reviews');
  console.log('══════════════════════════════════════════════');
}

main()
  .catch((error) => {
    console.error('❌ Seeding gagal:', error.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
