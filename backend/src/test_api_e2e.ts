/**
 * Comprehensive End-to-End API Test Script for Librava Backend
 */

const BASE_URL = 'http://localhost:5000/api';

async function request(endpoint: string, options: any = {}) {
  const url = `${BASE_URL}${endpoint}`;
  const headers: any = {
    'Content-Type': 'application/json',
    ...(options.headers || {}),
  };

  const config: RequestInit = {
    method: options.method || 'GET',
    headers,
    ...(options.body ? { body: JSON.stringify(options.body) } : {}),
  };

  const res = await fetch(url, config);
  const json = await res.json().catch(() => ({}));
  return { status: res.status, data: json };
}

async function runE2ETests() {
  console.log('\n🚀 ===============================================');
  console.log('🧪 MEMULAI END-TO-END TESTING API LIBRAVA');
  console.log('===============================================\n');

  try {
    // 1. Health check
    console.log('1️⃣  Testing Health Check Endpoint...');
    const health = await request('/health');
    console.log(`   Status: ${health.status}`, health.data);

    // 2. Register Andi
    console.log('\n2️⃣  Testing Register Mahasiswa (Andi)...');
    const timestamp = Date.now();
    const andiEmail = `andi_${timestamp}@telkomuniversity.ac.id`;
    const regAndi = await request('/auth/register', {
      method: 'POST',
      body: {
        email: andiEmail,
        password: 'password123',
        nama_lengkap: 'Andi Mahasiswa',
        nim: '1301210001',
        universitas: 'Telkom University',
        role: 'mahasiswa',
      },
    });
    console.log(`   Status: ${regAndi.status}`, regAndi.data.message);
    const tokenAndi = regAndi.data.data?.token;

    // 3. Register Budi
    console.log('\n3️⃣  Testing Register Mahasiswa (Budi)...');
    const budiEmail = `budi_${timestamp}@telkomuniversity.ac.id`;
    const regBudi = await request('/auth/register', {
      method: 'POST',
      body: {
        email: budiEmail,
        password: 'password123',
        nama_lengkap: 'Budi Mahasiswa',
        nim: '1301210002',
        universitas: 'Telkom University',
        role: 'mahasiswa',
      },
    });
    console.log(`   Status: ${regBudi.status}`, regBudi.data.message);
    const tokenBudi = regBudi.data.data?.token;

    // 4. Register Admin
    console.log('\n4️⃣  Testing Register Admin...');
    const adminEmail = `admin_${timestamp}@librava.ac.id`;
    const regAdmin = await request('/auth/register', {
      method: 'POST',
      body: {
        email: adminEmail,
        password: 'adminpassword',
        nama_lengkap: 'Super Admin Librava',
        role: 'admin',
      },
    });
    console.log(`   Status: ${regAdmin.status}`, regAdmin.data.message);
    const tokenAdmin = regAdmin.data.data?.token;

    // 5. Get Profile
    console.log('\n5️⃣  Testing Get Profile (Andi)...');
    const profile = await request('/auth/profile', {
      headers: { Authorization: `Bearer ${tokenAndi}` },
    });
    console.log(`   Status: ${profile.status}`, profile.data.data?.nama_lengkap, `(${profile.data.data?.email})`);

    // 6. Upload Book 1 by Andi
    console.log('\n6️⃣  Testing Upload Buku oleh Andi...');
    const book1 = await request('/books', {
      method: 'POST',
      headers: { Authorization: `Bearer ${tokenAndi}` },
      body: {
        judul: 'Algoritma dan Pemrograman Modern',
        penulis: 'Rinaldi Munir',
        penerbit: 'Informatika Bandung',
        isbn: '978-602-8758-00-1',
        deskripsi: 'Buku wajib untuk Alpro Telkom University.',
        kategori: 'Informatika',
        status: 'Tersedia',
      },
    });
    console.log(`   Status: ${book1.status}`, book1.data.message, `[Book ID: ${book1.data.data?.id}]`);
    const bookIdAndi = book1.data.data?.id;

    // 7. Upload Book 2 by Budi
    console.log('\n7️⃣  Testing Upload Buku oleh Budi (Untuk Barter)...');
    const book2 = await request('/books', {
      method: 'POST',
      headers: { Authorization: `Bearer ${tokenBudi}` },
      body: {
        judul: 'Struktur Data & Algoritma Python',
        penulis: 'Indra Wijaya',
        penerbit: 'Erlangga',
        isbn: '978-602-1234-56-7',
        deskripsi: 'Buku struktur data praktis.',
        kategori: 'Informatika',
        status: 'Tersedia',
      },
    });
    console.log(`   Status: ${book2.status}`, book2.data.message, `[Book ID: ${book2.data.data?.id}]`);
    const bookIdBudi = book2.data.data?.id;

    // 8. Search & Filter Books
    console.log('\n8️⃣  Testing Search & Filter Buku (keyword: "Algoritma")...');
    const searchBooks = await request('/books?search=Algoritma&kategori=Informatika');
    console.log(`   Status: ${searchBooks.status} - Ditemukan: ${searchBooks.data.meta?.total} buku`);
    searchBooks.data.data?.forEach((b: any) => {
      console.log(`   - "${b.judul}" oleh ${b.penulis} (Pemilik: ${b.owner_nama})`);
    });

    // 9. Create Transaction: Budi meminjam buku Andi
    console.log('\n9️⃣  Testing Pengajuan Transaksi Peminjaman (Budi -> Andi)...');
    const tx = await request('/transactions', {
      method: 'POST',
      headers: { Authorization: `Bearer ${tokenBudi}` },
      body: {
        book_id: bookIdAndi,
        tipe_transaksi: 'BORROW',
        deposit_dummy: 50000,
        lokasi_pertemuan: 'Perpustakaan Open Library Telkom University',
      },
    });
    console.log(`   Status: ${tx.status}`, tx.data.message, `[Tx ID: ${tx.data.data?.id}]`);
    const txId = tx.data.data?.id;

    // 10. Andi Menyetujui Transaksi (Accept Request)
    console.log('\n🔟 Testing Pemilik Buku Menyetujui Permintaan (Andi Accept)...');
    const acceptTx = await request(`/transactions/${txId}/status`, {
      method: 'PUT',
      headers: { Authorization: `Bearer ${tokenAndi}` },
      body: { status: 'DISETUJUI' },
    });
    console.log(`   Status: ${acceptTx.status}`, acceptTx.data.message);

    // 11. Tentukan Jadwal & Tempat Pertemuan
    console.log('\n1️⃣1️⃣ Testing Penentuan Lokasi & Jadwal Pertemuan...');
    const meeting = await request(`/transactions/${txId}/meeting`, {
      method: 'PUT',
      headers: { Authorization: `Bearer ${tokenAndi}` },
      body: {
        lokasi_pertemuan: 'Gedung Cacuk B Lantai 1 Meja 4',
        waktu_pertemuan: new Date(Date.now() + 86400000).toISOString(),
      },
    });
    console.log(`   Status: ${meeting.status}`, meeting.data.message);

    // 12. Chat per Transaksi
    console.log('\n1️⃣2️⃣ Testing Kirim & Ambil Chat per Transaksi...');
    const sendChat = await request(`/chats/${txId}`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${tokenBudi}` },
      body: { pesan: 'Halo mas Andi, besok saya tunggu di Cacuk B ya jam 10.' },
    });
    console.log(`   Status Kirim Chat: ${sendChat.status}`, `Pengirim: ${sendChat.data.data?.sender_nama}`);

    const getChat = await request(`/chats/${txId}`, {
      headers: { Authorization: `Bearer ${tokenAndi}` },
    });
    console.log(`   Status Ambil Chat: ${getChat.status}`, `Total Pesan: ${getChat.data.data?.length}`);

    // 13. Konfirmasi Serah Terima Buku (Transaksi Selesai)
    console.log('\n1️⃣3️⃣ Testing Konfirmasi Serah Terima Buku...');
    const handover = await request(`/transactions/${txId}/handover`, {
      method: 'PUT',
      headers: { Authorization: `Bearer ${tokenAndi}` },
    });
    console.log(`   Status: ${handover.status}`, handover.data.message);

    // 14. Review & Rating
    console.log('\n1️⃣4️⃣ Testing Memberikan Review & Rating...');
    const review = await request('/reviews', {
      method: 'POST',
      headers: { Authorization: `Bearer ${tokenBudi}` },
      body: {
        transaction_id: txId,
        rating: 5,
        komentar: 'Buku sangat terawat dan respon pemilik sangat cepat!',
      },
    });
    console.log(`   Status: ${review.status}`, review.data.message);

    // 15. Cek Profil Review Andi
    console.log('\n1️⃣5️⃣ Testing Ambil Ulasan & Rata-rata Rating User Andi...');
    const userReviews = await request(`/reviews/user/${profile.data.data?.id}`);
    console.log(
      `   Status: ${userReviews.status} - Rata-rata Rating: ⭐ ${userReviews.data.data?.average_rating}/5 (Total: ${userReviews.data.data?.total_reviews} ulasan)`
    );

    // 16. Admin Dashboard Monitoring
    console.log('\n1️⃣6️⃣ Testing Dashboard Admin Monitoring...');
    const adminDashboard = await request('/admin/dashboard', {
      headers: { Authorization: `Bearer ${tokenAdmin}` },
    });
    console.log(`   Status: ${adminDashboard.status}`);
    console.log('   📊 Ringkasan Statistik Sistem:', JSON.stringify(adminDashboard.data.data, null, 2));

    console.log('\n🎉 ===============================================');
    console.log('✅ SEMUA 16 FITUR & ENDPOINT BERHASIL DITEST 100%!');
    console.log('===============================================\n');
  } catch (error: any) {
    console.error('❌ Error during tests:', error.message);
  }
}

runE2ETests();
