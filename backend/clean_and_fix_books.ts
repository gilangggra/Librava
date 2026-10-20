import prisma from './src/config/prisma';

const coverMap: Record<string, string> = {
  'clean code': '/uploads/cover_clean_code.jpg',
  'pragmatic programmer': '/uploads/cover_pragmatic_programmer.jpg',
  'algoritma': '/uploads/cover_algoritma_python.jpg',
  'filosofi teras': '/uploads/cover_filosofi_teras.jpg',
  'sistem basis data': '/uploads/cover_sistem_basis_data.jpg',
  'atomic habits': '/uploads/cover_atomic_habits.jpg',
  'laskar pelangi': '/uploads/cover_laskar_pelangi.jpg',
  'jaringan komputer': '/uploads/cover_jaringan_komputer.jpg',
  'belajar html': '/uploads/cover_belajar_html.jpg',
  'everyday things': '/uploads/cover_design_everyday_things.jpg',
  'zero to one': '/uploads/cover_zero_to_one.jpg',
  'bodo amat': '/uploads/cover_bodo_amat.jpg',
  'thinking, fast and slow': '/uploads/cover_thinking_fast_slow.jpg',
  'refactoring': '/uploads/cover_refactoring.jpg',
  'introduction to algorithms': '/uploads/cover_introduction_to_algorithms.jpg',
  'sapiens': '/uploads/cover_sapiens.jpg',
  'cosmos': '/uploads/cover_cosmos.jpg',
  'bumi': '/uploads/cover_bumi.jpg',
  'laut bercerita': '/uploads/cover_laut_bercerita.jpg',
  'negeri 5 menara': '/uploads/cover_negeri_5_menara.jpg',
  'one piece': '/uploads/cover_one_piece_vol1.jpg',
};

function getCover(judul: string): string | null {
  const lower = judul.toLowerCase();
  for (const [key, cover] of Object.entries(coverMap)) {
    if (lower.includes(key)) return cover;
  }
  return null;
}

async function main() {
  console.log('Cleaning and deduplicating books in database...');

  const allBooks = await prisma.book.findMany({
    orderBy: { id: 'asc' },
  });

  console.log(`Found ${allBooks.length} total books.`);

  // Group by trimmed lower title
  const grouped = new Map<string, typeof allBooks>();
  for (const b of allBooks) {
    const key = b.judul.trim().toLowerCase();
    if (!grouped.has(key)) grouped.set(key, []);
    grouped.get(key)!.push(b);
  }

  for (const [key, books] of grouped.entries()) {
    // Keep the one with highest ID (or one that has transactions)
    const primary = books[books.length - 1];
    const duplicates = books.slice(0, books.length - 1);

    const cover = getCover(primary.judul);
    await prisma.book.update({
      where: { id: primary.id },
      data: {
        statusModerasi: 'DISETUJUI',
        status: 'Tersedia',
        ...(cover ? { fotoBuku: cover } : {}),
      },
    });

    for (const dup of duplicates) {
      // Re-point transactions referencing dup to primary
      await prisma.transaction.updateMany({
        where: { bookId: dup.id },
        data: { bookId: primary.id },
      });
      await prisma.transaction.updateMany({
        where: { barterBookId: dup.id },
        data: { barterBookId: primary.id },
      });
      // Delete duplicate book
      await prisma.book.delete({
        where: { id: dup.id },
      });
      console.log(`  Merged & deleted duplicate book #${dup.id} -> #${primary.id} (${primary.judul})`);
    }
  }

  const remaining = await prisma.book.count();
  console.log(`\nDone! Remaining distinct books in DB: ${remaining}`);
}

main().catch(console.error).finally(() => prisma.$disconnect());
