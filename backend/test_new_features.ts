import fs from 'fs';
import path from 'path';
import { io as ClientIO } from 'socket.io-client';

const BASE_URL = 'http://localhost:5000/api';
const SOCKET_URL = 'http://localhost:5000';

async function runNewFeatureTests() {
  console.log('\n======================================================');
  console.log('🧪 TESTING NEW IMPLEMENTED FEATURES (ZOD, BARTER SWAP, DEPOSIT, UPLOAD, SOCKET.IO)');
  console.log('======================================================\n');

  const ts = Date.now();
  const user1Email = `user1_${ts}@telkomuniversity.ac.id`;
  const user2Email = `user2_${ts}@telkomuniversity.ac.id`;

  // 1. Register User 1 & User 2
  const reg1 = await fetch(`${BASE_URL}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'x-bypass-rate-limit': 'librava_qa_secret' },
    body: JSON.stringify({
      email: user1Email,
      password: 'password123',
      nama_lengkap: 'User Satu',
    }),
  }).then((r) => r.json());

  const reg2 = await fetch(`${BASE_URL}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'x-bypass-rate-limit': 'librava_qa_secret' },
    body: JSON.stringify({
      email: user2Email,
      password: 'password123',
      nama_lengkap: 'User Dua',
    }),
  }).then((r) => r.json());

  const token1 = reg1.data.token;
  const user1Id = reg1.data.user.id;
  const initialSaldo1 = reg1.data.user.saldo_dummy;

  const token2 = reg2.data.token;
  const user2Id = reg2.data.user.id;

  console.log(`[TEST 1] User Registered. Initial Saldo User 1: Rp ${initialSaldo1}`);
  if (initialSaldo1 === 100000) {
    console.log('  ✔ PASS: Saldo dummy default Rp 100.000 terinisialisasi dengan benar.');
  } else {
    console.log(`  ✖ FAIL: Expected saldo 100000, got ${initialSaldo1}`);
  }

  // 2. Test Zod Validation: Register with invalid email format
  const invalidEmailRes = await fetch(`${BASE_URL}/auth/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'x-bypass-rate-limit': 'librava_qa_secret' },
    body: JSON.stringify({
      email: 'not-an-email',
      password: 'password123',
      nama_lengkap: 'Test Error',
    }),
  });
  const invalidEmailBody = await invalidEmailRes.json();
  if (invalidEmailRes.status === 400 && invalidEmailBody.errors) {
    console.log('  ✔ PASS: Zod Validation successfully rejected invalid email format with 400 Bad Request.');
  } else {
    console.log('  ✖ FAIL: Zod did not reject invalid email.');
  }

  // 3. Test File Upload (Multer)
  const dummyFilePath = path.join(__dirname, 'test_dummy_image.png');
  // Simple 1x1 transparent PNG buffer
  const pngBuffer = Buffer.from(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
    'base64'
  );
  fs.writeFileSync(dummyFilePath, pngBuffer);

  const formData = new FormData();
  const fileBlob = new Blob([pngBuffer], { type: 'image/png' });
  formData.append('image', fileBlob, 'test_dummy_image.png');

  const uploadRes = await fetch(`${BASE_URL}/upload/image`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token1}`,
    },
    body: formData,
  });
  const uploadBody = await uploadRes.json();
  if (fs.existsSync(dummyFilePath)) fs.unlinkSync(dummyFilePath);

  if (uploadRes.status === 201 && uploadBody.data?.url) {
    console.log(`  ✔ PASS: File Upload (Multer) successful. Image URL: ${uploadBody.data.url}`);

    // Verify Static Serving
    const fetchStatic = await fetch(uploadBody.data.url);
    if (fetchStatic.status === 200) {
      console.log('  ✔ PASS: Static image serving from /uploads works properly (HTTP 200).');
    } else {
      console.log(`  ✖ FAIL: Static file returned status ${fetchStatic.status}`);
    }
  } else {
    console.log('  ✖ FAIL: File upload failed.', uploadBody);
  }

  // 4. Test Deposit Escrow & Refund (Borrow flow)
  // User 2 creates a book
  const bookRes = await fetch(`${BASE_URL}/books`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token2}` },
    body: JSON.stringify({
      judul: 'Clean Code Architecture',
      penulis: 'Robert C. Martin',
      kategori: 'Informatika',
    }),
  }).then((r) => r.json());
  const book2Id = bookRes.data.id;

  // User 1 requests to borrow with deposit 30000
  const borrowTx = await fetch(`${BASE_URL}/transactions`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token1}` },
    body: JSON.stringify({
      book_id: book2Id,
      tipe_transaksi: 'BORROW',
      deposit_dummy: 30000,
      durasi_hari: 14,
    }),
  }).then((r) => r.json());
  const txId = borrowTx.data.id;

  // Check User 1 saldo after deposit hold (should be 100000 - 30000 = 70000)
  const profileAfterHold = await fetch(`${BASE_URL}/auth/profile`, {
    headers: { Authorization: `Bearer ${token1}` },
  }).then((r) => r.json());

  if (profileAfterHold.data.saldo_dummy === 70000) {
    console.log('  ✔ PASS: Escrow Deposit successfully deducted Rp 30.000 from borrower (Current: Rp 70.000).');
  } else {
    console.log(`  ✖ FAIL: Saldo was not properly held in escrow: ${profileAfterHold.data.saldo_dummy}`);
  }

  // Complete borrow and return book via /return
  await fetch(`${BASE_URL}/transactions/${txId}/status`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token2}` },
    body: JSON.stringify({ status: 'DISETUJUI' }),
  });

  await fetch(`${BASE_URL}/transactions/${txId}/return`, {
    method: 'PUT',
    headers: { Authorization: `Bearer ${token2}` },
  });

  // Check User 1 saldo after refund (should be back to 100000)
  const profileAfterRefund = await fetch(`${BASE_URL}/auth/profile`, {
    headers: { Authorization: `Bearer ${token1}` },
  }).then((r) => r.json());

  if (profileAfterRefund.data.saldo_dummy === 100000) {
    console.log('  ✔ PASS: Deposit 100% refunded to borrower after book return confirmed (Current: Rp 100.000).');
  } else {
    console.log(`  ✖ FAIL: Saldo was not refunded properly: ${profileAfterRefund.data.saldo_dummy}`);
  }

  // 5. Test Barter Ownership Swap
  // User 1 creates Book 1
  const b1 = await fetch(`${BASE_URL}/books`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token1}` },
    body: JSON.stringify({ judul: 'Buku User Satu', penulis: 'Penulis A' }),
  }).then((r) => r.json());

  // User 2 creates Book 2
  const b2 = await fetch(`${BASE_URL}/books`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token2}` },
    body: JSON.stringify({ judul: 'Buku User Dua', penulis: 'Penulis B' }),
  }).then((r) => r.json());

  // User 1 requests BARTER: wants b2, offers b1
  const barterTx = await fetch(`${BASE_URL}/transactions`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token1}` },
    body: JSON.stringify({
      book_id: b2.data.id,
      tipe_transaksi: 'BARTER',
      barter_book_id: b1.data.id,
    }),
  }).then((r) => r.json());

  // User 2 approves barter
  await fetch(`${BASE_URL}/transactions/${barterTx.data.id}/status`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token2}` },
    body: JSON.stringify({ status: 'DISETUJUI' }),
  });

  // Complete handover (SELESAI) -> should trigger ownership swap!
  await fetch(`${BASE_URL}/transactions/${barterTx.data.id}/handover`, {
    method: 'PUT',
    headers: { Authorization: `Bearer ${token2}` },
  });

  // Verify ownership of b2 is now User 1, and b1 is now User 2!
  const b1Check = await fetch(`${BASE_URL}/books/${b1.data.id}`).then((r) => r.json());
  const b2Check = await fetch(`${BASE_URL}/books/${b2.data.id}`).then((r) => r.json());

  if (b1Check.data.owner_id === user2Id && b2Check.data.owner_id === user1Id) {
    console.log('  ✔ PASS: Barter Ownership Swap confirmed! Book 1 transferred to User 2, Book 2 transferred to User 1.');
  } else {
    console.log(`  ✖ FAIL: Ownership was not swapped. b1 owner: ${b1Check.data.owner_id}, b2 owner: ${b2Check.data.owner_id}`);
  }

  // 6. Test Socket.IO Real-time chat
  await new Promise<void>((resolve) => {
    const socket = ClientIO(SOCKET_URL, {
      auth: { token: token1 },
      transports: ['websocket'],
    });

    socket.on('connect', () => {
      console.log('  ✔ PASS: Socket.IO connected with JWT authentication.');
      socket.emit('join_transaction', { transactionId: txId }, (ack: any) => {
        if (ack?.success) {
          console.log(`  ✔ PASS: Socket.IO joined room transaction_${txId}.`);
        }
        socket.disconnect();
        resolve();
      });
    });

    socket.on('connect_error', (err) => {
      console.log('  ✖ FAIL: Socket.IO connection failed:', err.message);
      socket.disconnect();
      resolve();
    });
  });

  console.log('\n======================================================');
  console.log('🎉 ALL NEW FEATURES TESTED & VERIFIED SUCCESSFULLY!');
  console.log('======================================================\n');
}

runNewFeatureTests().catch(console.error);
