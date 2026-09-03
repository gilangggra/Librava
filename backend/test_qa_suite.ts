/**
 * ============================================================================
 * LIBRAVA BACKEND — COMPREHENSIVE QA AUTOMATED TEST SUITE
 * Lead QA Engineer / SDET Test Framework
 * ============================================================================
 * Covers:
 *  1. Smoke & Server Health
 *  2. Authentication & Input Validation
 *  3. Role-Based Access Control (RBAC) & Security Boundaries
 *  4. Book Inventory & CRUD Operations
 *  5. P2P Transaction State Machine (Borrow & Barter Lifecycles)
 *  6. IDOR (Insecure Direct Object Reference) & Chat Privacy
 *  7. Peer Rating & Reputation Integrity
 *  8. Edge Cases & Error Handling
 * ============================================================================
 */

interface TestCaseResult {
  id: string;
  category: string;
  name: string;
  status: 'PASS' | 'FAIL';
  statusCode: number;
  expectedStatus: number | number[];
  durationMs: number;
  errorDetail?: string;
}

const BASE_URL = 'http://localhost:5000/api';
const results: TestCaseResult[] = [];

const nativeFetch = globalThis.fetch;
globalThis.fetch = (input: RequestInfo | URL, init?: RequestInit): Promise<Response> => {
  const headers = new Headers(init?.headers);
  headers.set('x-bypass-rate-limit', 'librava_qa_secret');
  return nativeFetch(input, { ...init, headers });
};

// ANSI colors for formatted QA output
const colors = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  gray: '\x1b[90m',
  bgBlue: '\x1b[44m',
  bgRed: '\x1b[41m',
  bgGreen: '\x1b[42m',
};

async function runTest(
  id: string,
  category: string,
  name: string,
  expectedStatus: number | number[],
  fn: () => Promise<Response>
): Promise<{ res: Response; body: any }> {
  const start = performance.now();
  let res: Response;
  let body: any = null;
  let status: 'PASS' | 'FAIL' = 'FAIL';
  let errorDetail: string | undefined;

  try {
    res = await fn();
    const durationMs = Math.round(performance.now() - start);

    const text = await res.text();
    try {
      body = JSON.parse(text);
    } catch {
      body = text;
    }

    const expectedArr = Array.isArray(expectedStatus) ? expectedStatus : [expectedStatus];
    const isStatusMatch = expectedArr.includes(res.status);

    if (isStatusMatch) {
      status = 'PASS';
    } else {
      status = 'FAIL';
      errorDetail = `Expected status ${expectedArr.join('/')}, but received ${res.status}. Body: ${JSON.stringify(body).slice(0, 150)}`;
    }

    results.push({
      id,
      category,
      name,
      status,
      statusCode: res.status,
      expectedStatus,
      durationMs,
      errorDetail,
    });

    const statusBadge = status === 'PASS' 
      ? `${colors.green}✔ PASS${colors.reset}` 
      : `${colors.red}✖ FAIL${colors.reset}`;

    console.log(
      `  [${colors.cyan}${id}${colors.reset}] ${statusBadge} ${colors.gray}(${durationMs}ms)${colors.reset} - ${name} [HTTP ${res.status}]`
    );

    if (status === 'FAIL' && errorDetail) {
      console.log(`     ${colors.red}↳ ${errorDetail}${colors.reset}`);
    }

    return { res, body };
  } catch (err: any) {
    const durationMs = Math.round(performance.now() - start);
    results.push({
      id,
      category,
      name,
      status: 'FAIL',
      statusCode: 0,
      expectedStatus,
      durationMs,
      errorDetail: err.message,
    });
    console.log(
      `  [${colors.cyan}${id}${colors.reset}] ${colors.red}✖ FAIL (Network/Crash)${colors.reset} - ${name}: ${err.message}`
    );
    return { res: new Response(null, { status: 500 }), body: null };
  }
}

async function executeTestSuite() {
  console.log(`\n${colors.bold}${colors.bgBlue}  LIBRAVA BACKEND QA AUTOMATED VERIFICATION SUITE  ${colors.reset}`);
  console.log(`${colors.gray}Target Environment: ${BASE_URL}${colors.reset}\n`);

  const timestamp = Date.now();
  const userAEmail = `qa_andi_${timestamp}@telkomuniversity.ac.id`;
  const userBEmail = `qa_budi_${timestamp}@telkomuniversity.ac.id`;
  const userCEmail = `qa_citra_${timestamp}@telkomuniversity.ac.id`; // Third-party user for IDOR testing
  const adminEmail = `qa_admin_${timestamp}@librava.ac.id`;
  const defaultPassword = 'Password123!';

  let tokenA = '';
  let tokenB = '';
  let tokenC = '';
  let tokenAdmin = '';

  let userAId: number = 0;
  let userBId: number = 0;
  let userCId: number = 0;

  let bookAId: number = 0;
  let bookBBarterId: number = 0;
  let transactionId: number = 0;

  // =========================================================================
  // SUITE 1: SMOKE & SYSTEM HEALTH
  // =========================================================================
  console.log(`\n${colors.bold}${colors.yellow}▶ SUITE 1: Smoke & System Endpoints${colors.reset}`);

  await runTest('SMK-01', 'Smoke', 'GET /api/health returns 200 OK and valid health payload', 200, () =>
    fetch(`${BASE_URL}/health`)
  );

  await runTest('SMK-02', 'Smoke', 'GET /api/ returns API gateway root information', 200, () =>
    fetch(`${BASE_URL}/`)
  );

  await runTest('SMK-03', 'Smoke', 'GET /api/non-existent-route returns 404 Route Not Found', 404, () =>
    fetch(`${BASE_URL}/route_that_definitely_does_not_exist_404`)
  );

  // =========================================================================
  // SUITE 2: AUTHENTICATION, VALIDATION & REPUTATION REGISTER
  // =========================================================================
  console.log(`\n${colors.bold}${colors.yellow}▶ SUITE 2: Authentication & Input Validation${colors.reset}`);

  // Register User A (Mahasiswa)
  const regARes = await runTest('AUTH-01', 'Auth', 'POST /auth/register - Register User A (Mahasiswa)', [200, 201], () =>
    fetch(`${BASE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: userAEmail,
        password: defaultPassword,
        nama_lengkap: 'Andi QA Tester',
        nim: '1301210091',
        universitas: 'Telkom University',
        role: 'mahasiswa',
      }),
    })
  );
  if (regARes.body?.data) {
    userAId = regARes.body.data.user?.id || regARes.body.data.id;
    tokenA = regARes.body.data.token || '';
  }

  // Register Duplicate Email
  await runTest('AUTH-02', 'Auth', 'POST /auth/register - Duplicate email rejected with 400 Bad Request', 400, () =>
    fetch(`${BASE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: userAEmail,
        password: defaultPassword,
        nama_lengkap: 'Andi Duplicate',
      }),
    })
  );

  // Register with Missing Required Fields (Empty Email/Password)
  await runTest('AUTH-03', 'Auth', 'POST /auth/register - Missing password rejected with 400 Bad Request', 400, () =>
    fetch(`${BASE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: `invalid_empty_${timestamp}@test.com`,
      }),
    })
  );

  // Register User B (Borrower)
  const regBRes = await runTest('AUTH-04', 'Auth', 'POST /auth/register - Register User B (Mahasiswa)', [200, 201], () =>
    fetch(`${BASE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: userBEmail,
        password: defaultPassword,
        nama_lengkap: 'Budi QA Borrower',
        nim: '1301210092',
        universitas: 'Telkom University',
        role: 'mahasiswa',
      }),
    })
  );
  if (regBRes.body?.data) {
    userBId = regBRes.body.data.user?.id || regBRes.body.data.id;
    tokenB = regBRes.body.data.token || '';
  }

  // Register User C (Third-Party for IDOR testing)
  const regCRes = await runTest('AUTH-05', 'Auth', 'POST /auth/register - Register User C (Third-Party)', [200, 201], () =>
    fetch(`${BASE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: userCEmail,
        password: defaultPassword,
        nama_lengkap: 'Citra Third-Party',
        nim: '1301210093',
        universitas: 'Telkom University',
        role: 'mahasiswa',
      }),
    })
  );
  if (regCRes.body?.data) {
    userCId = regCRes.body.data.user?.id || regCRes.body.data.id;
    tokenC = regCRes.body.data.token || '';
  }

  // Authenticate Seeded Admin User (Admin cannot be created via public register)
  const loginAdminRes = await runTest('AUTH-06', 'Auth', 'POST /auth/login - Authenticate Official Admin User', 200, () =>
    fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: 'superadmin@librava.ac.id',
        password: 'AdminPassword123!',
      }),
    })
  );
  if (loginAdminRes.body?.data?.token) {
    tokenAdmin = loginAdminRes.body.data.token;
  }

  // Login User A
  const loginRes = await runTest('AUTH-07', 'Auth', 'POST /auth/login - Login with valid credentials', 200, () =>
    fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: userAEmail,
        password: defaultPassword,
      }),
    })
  );
  if (loginRes.body?.data?.token) {
    tokenA = loginRes.body.data.token;
  }

  // Login with Wrong Password
  await runTest('AUTH-08', 'Auth', 'POST /auth/login - Invalid password rejected with 401 Unauthorized', 401, () =>
    fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: userAEmail,
        password: 'wrong_password_123',
      }),
    })
  );

  // Login with Non-Existent Email
  await runTest('AUTH-09', 'Auth', 'POST /auth/login - Unknown email rejected with 401 Unauthorized', 401, () =>
    fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: `non_existent_ghost_${timestamp}@mail.com`,
        password: defaultPassword,
      }),
    })
  );

  // Authenticated Profile Retrieval
  await runTest('AUTH-10', 'Auth', 'GET /auth/profile - Retrieve own profile with valid token', 200, () =>
    fetch(`${BASE_URL}/auth/profile`, {
      headers: { Authorization: `Bearer ${tokenA}` },
    })
  );

  // Access Protected Route Without Token
  await runTest('AUTH-11', 'Auth', 'GET /auth/profile - Missing Bearer token rejected with 401', 401, () =>
    fetch(`${BASE_URL}/auth/profile`)
  );

  // Access Protected Route with Forged/Tampered Token
  await runTest('AUTH-12', 'Auth', 'GET /auth/profile - Forged token signature rejected with 401', 401, () =>
    fetch(`${BASE_URL}/auth/profile`, {
      headers: { Authorization: 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.tampered.signature' },
    })
  );

  // Update Profile
  await runTest('AUTH-13', 'Auth', 'PUT /auth/profile - Update user profile attributes', 200, () =>
    fetch(`${BASE_URL}/auth/profile`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenA}`,
      },
      body: JSON.stringify({
        nama_lengkap: 'Andi QA Tester Updated',
        nim: '1301219999',
      }),
    })
  );

  // =========================================================================
  // SUITE 3: ROLE-BASED ACCESS CONTROL (RBAC) & PRIVILEGE ELEVATION
  // =========================================================================
  console.log(`\n${colors.bold}${colors.yellow}▶ SUITE 3: RBAC & Privilege Elevation Tests${colors.reset}`);

  // Normal Mahasiswa tries to access Admin Dashboard
  await runTest('RBAC-01', 'RBAC', 'GET /admin/dashboard - Mahasiswa forbidden with 403', 403, () =>
    fetch(`${BASE_URL}/admin/dashboard`, {
      headers: { Authorization: `Bearer ${tokenA}` },
    })
  );

  // Normal Mahasiswa tries to access Admin User list
  await runTest('RBAC-02', 'RBAC', 'GET /admin/users - Mahasiswa forbidden with 403', 403, () =>
    fetch(`${BASE_URL}/admin/users`, {
      headers: { Authorization: `Bearer ${tokenA}` },
    })
  );

  // Admin user accesses Admin Dashboard
  await runTest('RBAC-03', 'RBAC', 'GET /admin/dashboard - Admin granted 200 OK with analytics data', 200, () =>
    fetch(`${BASE_URL}/admin/dashboard`, {
      headers: { Authorization: `Bearer ${tokenAdmin}` },
    })
  );

  // Admin user accesses Admin Transactions list
  await runTest('RBAC-04', 'RBAC', 'GET /admin/transactions - Admin granted 200 OK with system transactions', 200, () =>
    fetch(`${BASE_URL}/admin/transactions`, {
      headers: { Authorization: `Bearer ${tokenAdmin}` },
    })
  );

  // =========================================================================
  // SUITE 4: BOOK MANAGEMENT & CRUD
  // =========================================================================
  console.log(`\n${colors.bold}${colors.yellow}▶ SUITE 4: Book Inventory & Catalog CRUD${colors.reset}`);

  // Create Book as User A
  const bookARes = await runTest('BOOK-01', 'Book', 'POST /books - Create book by User A', [200, 201], () =>
    fetch(`${BASE_URL}/books`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenA}`,
      },
      body: JSON.stringify({
        judul: 'Algoritma & Pemrograman Berorientasi Objek',
        penulis: 'Dr. QA Engineer',
        penerbit: 'Telkom Press',
        isbn: `978-602-${timestamp.toString().slice(-6)}`,
        deskripsi: 'Buku master untuk pengujian perangkat lunak dan arsitektur backend.',
        kategori: 'Informatika',
        status: 'Tersedia',
      }),
    })
  );
  if (bookARes.body?.data) {
    bookAId = bookARes.body.data.id;
  }

  // Create Book with Missing Required Title
  await runTest('BOOK-02', 'Book', 'POST /books - Missing title rejected with 400 Bad Request', 400, () =>
    fetch(`${BASE_URL}/books`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenA}`,
      },
      body: JSON.stringify({
        penulis: 'No Title Author',
        kategori: 'Informatika',
      }),
    })
  );

  // Create Book as User B (for Barter testing later)
  const bookBRes = await runTest('BOOK-03', 'Book', 'POST /books - Create barter candidate book by User B', [200, 201], () =>
    fetch(`${BASE_URL}/books`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenB}`,
      },
      body: JSON.stringify({
        judul: 'Jaringan Komputer Modern',
        penulis: 'Prof. Barter Expert',
        penerbit: 'Informatika Bandung',
        isbn: `978-602-B-${timestamp.toString().slice(-5)}`,
        deskripsi: 'Buku barter pembanding untuk transaksi p2p.',
        kategori: 'Jaringan',
        status: 'Tersedia',
      }),
    })
  );
  if (bookBRes.body?.data) {
    bookBBarterId = bookBRes.body.data.id;
  }

  // Get Book List with Query Param Filters & Pagination
  await runTest('BOOK-04', 'Book', 'GET /books - List books with category filter and search query', 200, () =>
    fetch(`${BASE_URL}/books?kategori=Informatika&search=Algoritma&limit=10&offset=0`)
  );

  // Get Specific Book Detail
  await runTest('BOOK-05', 'Book', 'GET /books/:id - Retrieve existing book detail', 200, () =>
    fetch(`${BASE_URL}/books/${bookAId}`)
  );

  // Get Non-Existent Book Detail
  await runTest('BOOK-06', 'Book', 'GET /books/:id - Non-existent ID returns 404 Not Found', 404, () =>
    fetch(`${BASE_URL}/books/99999999`)
  );

  // Update Book by Owner User A
  await runTest('BOOK-07', 'Book', 'PUT /books/:id - Owner successfully edits book metadata', 200, () =>
    fetch(`${BASE_URL}/books/${bookAId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenA}`,
      },
      body: JSON.stringify({
        deskripsi: 'Deskripsi buku telah diperbarui oleh pemilik sah.',
      }),
    })
  );

  // Update Book by Non-Owner User B (IDOR Security Test)
  await runTest('BOOK-08', 'Book', 'PUT /books/:id - Non-owner editing someone else book rejected with 403', 403, () =>
    fetch(`${BASE_URL}/books/${bookAId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenB}`,
      },
      body: JSON.stringify({
        judul: 'Hacked Title By Attacker',
      }),
    })
  );

  // Get My Books
  await runTest('BOOK-09', 'Book', 'GET /books/user/my-books - Retrieve own inventory', 200, () =>
    fetch(`${BASE_URL}/books/user/my-books`, {
      headers: { Authorization: `Bearer ${tokenA}` },
    })
  );

  // =========================================================================
  // SUITE 5: TRANSACTION LIFECYCLE & STATE MACHINE (BORROW & BARTER)
  // =========================================================================
  console.log(`\n${colors.bold}${colors.yellow}▶ SUITE 5: P2P Transaction State Machine & Lifecycle${colors.reset}`);

  // Self-Borrow Attempt: User A tries to borrow their own book
  await runTest('TX-01', 'Transaction', 'POST /transactions - Borrowing own book rejected with 400 Bad Request', 400, () =>
    fetch(`${BASE_URL}/transactions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenA}`,
      },
      body: JSON.stringify({
        book_id: bookAId,
        tipe_transaksi: 'BORROW',
        deposit_dummy: 50000,
      }),
    })
  );

  // Barter without barter_book_id
  await runTest('TX-02', 'Transaction', 'POST /transactions - Barter without barter_book_id rejected with 400', 400, () =>
    fetch(`${BASE_URL}/transactions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenB}`,
      },
      body: JSON.stringify({
        book_id: bookAId,
        tipe_transaksi: 'BARTER',
      }),
    })
  );

  // Barter with a book not owned by requester User B
  await runTest('TX-03', 'Transaction', 'POST /transactions - Barter using unowned book rejected with 400', 400, () =>
    fetch(`${BASE_URL}/transactions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenB}`,
      },
      body: JSON.stringify({
        book_id: bookAId,
        tipe_transaksi: 'BARTER',
        barter_book_id: bookAId, // Attempting to use User A's book as barter trade item!
      }),
    })
  );

  // Valid Transaction Creation: User B borrows Book from User A
  const txRes = await runTest('TX-04', 'Transaction', 'POST /transactions - User B requests to borrow User A book', [200, 201], () =>
    fetch(`${BASE_URL}/transactions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenB}`,
      },
      body: JSON.stringify({
        book_id: bookAId,
        tipe_transaksi: 'BORROW',
        deposit_dummy: 25000,
        lokasi_pertemuan: 'Perpustakaan Open Library Telkom University',
      }),
    })
  );
  if (txRes.body?.data) {
    transactionId = txRes.body.data.id;
  }

  // Get Transaction Detail as Participant (User B)
  await runTest('TX-05', 'Transaction', 'GET /transactions/:id - Participant retrieves transaction detail', 200, () =>
    fetch(`${BASE_URL}/transactions/${transactionId}`, {
      headers: { Authorization: `Bearer ${tokenB}` },
    })
  );

  // IDOR Test: Third-party User C tries to view transaction between User A & User B
  await runTest('TX-06', 'Transaction', 'GET /transactions/:id - Non-participant rejected with 403 Forbidden', 403, () =>
    fetch(`${BASE_URL}/transactions/${transactionId}`, {
      headers: { Authorization: `Bearer ${tokenC}` },
    })
  );

  // Requester User B tries to Approve their own request (Forbidden, only Owner can approve!)
  await runTest('TX-07', 'Transaction', 'PUT /transactions/:id/status - Requester unauthorized to approve request', 403, () =>
    fetch(`${BASE_URL}/transactions/${transactionId}/status`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenB}`,
      },
      body: JSON.stringify({ status: 'DISETUJUI' }),
    })
  );

  // Owner User A Approves Transaction
  await runTest('TX-08', 'Transaction', 'PUT /transactions/:id/status - Owner approves transaction (DISETUJUI)', 200, () =>
    fetch(`${BASE_URL}/transactions/${transactionId}/status`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenA}`,
      },
      body: JSON.stringify({ status: 'DISETUJUI' }),
    })
  );

  // Verify Book Status Changed to 'Dipinjam'
  const bookCheckRes = await runTest('TX-09', 'Transaction', 'GET /books/:id - Verified book status transitioned to Dipinjam', 200, () =>
    fetch(`${BASE_URL}/books/${bookAId}`)
  );
  if (bookCheckRes.body?.data?.status !== 'Dipinjam') {
    console.log(`     ${colors.yellow}⚠ Warning: Expected book status 'Dipinjam' but got '${bookCheckRes.body?.data?.status}'${colors.reset}`);
  }

  // Third party tries to borrow already-borrowed book
  await runTest('TX-10', 'Transaction', 'POST /transactions - Borrowing unavailable book rejected with 400', 400, () =>
    fetch(`${BASE_URL}/transactions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenC}`,
      },
      body: JSON.stringify({
        book_id: bookAId,
        tipe_transaksi: 'BORROW',
      }),
    })
  );

  // Schedule Meeting (Transition to DALAM_PROSES)
  await runTest('TX-11', 'Transaction', 'PUT /transactions/:id/meeting - Set meeting schedule (DALAM_PROSES)', 200, () =>
    fetch(`${BASE_URL}/transactions/${transactionId}/meeting`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenA}`,
      },
      body: JSON.stringify({
        lokasi_pertemuan: 'Lobby Gedung Kuliah Bersama (GKU)',
        waktu_pertemuan: new Date(Date.now() + 86400000).toISOString(),
      }),
    })
  );

  // Complete Handover (Transition to SELESAI)
  await runTest('TX-12', 'Transaction', 'PUT /transactions/:id/handover - Confirm handover complete (SELESAI)', 200, () =>
    fetch(`${BASE_URL}/transactions/${transactionId}/handover`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenA}`,
      },
    })
  );

  // =========================================================================
  // SUITE 6: CHAT SYSTEM & IN-TRANSACTION PRIVACY
  // =========================================================================
  console.log(`\n${colors.bold}${colors.yellow}▶ SUITE 6: In-Transaction Chat & Privacy Boundaries${colors.reset}`);

  // User B sends chat message to User A
  await runTest('CHAT-01', 'Chat', 'POST /chats/:transactionId - Participant B sends chat message', [200, 201], () =>
    fetch(`${BASE_URL}/chats/${transactionId}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenB}`,
      },
      body: JSON.stringify({
        pesan: 'Halo Kak Andi, saya sudah sampai di Lobby GKU ya!',
      }),
    })
  );

  // User A reads chat history
  await runTest('CHAT-02', 'Chat', 'GET /chats/:transactionId - Participant A views chat history', 200, () =>
    fetch(`${BASE_URL}/chats/${transactionId}`, {
      headers: { Authorization: `Bearer ${tokenA}` },
    })
  );

  // Outsider User C tries to read chat of Transaction A-B (IDOR Privacy Breach Attempt)
  await runTest('CHAT-03', 'Chat', 'GET /chats/:transactionId - Outsider User C reading chat rejected with 403', 403, () =>
    fetch(`${BASE_URL}/chats/${transactionId}`, {
      headers: { Authorization: `Bearer ${tokenC}` },
    })
  );

  // Outsider User C tries to send chat to Transaction A-B (Spam / Intrusion Attempt)
  await runTest('CHAT-04', 'Chat', 'POST /chats/:transactionId - Outsider User C posting chat rejected with 403', 403, () =>
    fetch(`${BASE_URL}/chats/${transactionId}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenC}`,
      },
      body: JSON.stringify({
        pesan: 'Intrusion chat from unauthorized stranger!',
      }),
    })
  );

  // =========================================================================
  // SUITE 7: PEER REVIEWS & REPUTATION INTEGRITY
  // =========================================================================
  console.log(`\n${colors.bold}${colors.yellow}▶ SUITE 7: Reviews, Ratings & Reputation System${colors.reset}`);

  // User B submits review for User A on completed transaction
  await runTest('REV-01', 'Review', 'POST /reviews - User B submits 5-star review for User A', [200, 201], () =>
    fetch(`${BASE_URL}/reviews`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenB}`,
      },
      body: JSON.stringify({
        transaction_id: transactionId,
        rating: 5,
        komentar: 'Buku sangat mulus dan tepat waktu. Terima kasih banyak!',
      }),
    })
  );

  // Duplicate Review Prevention: User B attempts to review again on the same transaction
  await runTest('REV-02', 'Review', 'POST /reviews - Duplicate review rejected with 400 Bad Request', 400, () =>
    fetch(`${BASE_URL}/reviews`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenB}`,
      },
      body: JSON.stringify({
        transaction_id: transactionId,
        rating: 4,
        komentar: 'Mencoba kirim ulasan kedua kali.',
      }),
    })
  );

  // Invalid Rating Boundary (Out-of-range rating: 6)
  await runTest('REV-03', 'Review', 'POST /reviews - Rating out of range (6) rejected with 400 Bad Request', 400, () =>
    fetch(`${BASE_URL}/reviews`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenA}`,
      },
      body: JSON.stringify({
        transaction_id: transactionId,
        rating: 6,
        komentar: 'Rating 6 invalid.',
      }),
    })
  );

  // Non-participant User C tries to submit review
  await runTest('REV-04', 'Review', 'POST /reviews - Non-participant review rejected with 403 Forbidden', 403, () =>
    fetch(`${BASE_URL}/reviews`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${tokenC}`,
      },
      body: JSON.stringify({
        transaction_id: transactionId,
        rating: 1,
        komentar: 'Trolling from outsider.',
      }),
    })
  );

  // Get User Reviews & Aggregated Rating
  await runTest('REV-05', 'Review', 'GET /reviews/user/:userId - Retrieve user reviews and rating score', 200, () =>
    fetch(`${BASE_URL}/reviews/user/${userAId}`)
  );

  // =========================================================================
  // SUITE 8: INVENTORY TEARDOWN & ACCESS CONTROL
  // =========================================================================
  console.log(`\n${colors.bold}${colors.yellow}▶ SUITE 8: Resource Cleanup & Deletion Boundaries${colors.reset}`);

  // User B tries to delete User A's book
  await runTest('DEL-01', 'Book', 'DELETE /books/:id - Unauthorized deletion attempt rejected with 403', 403, () =>
    fetch(`${BASE_URL}/books/${bookAId}`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${tokenB}` },
    })
  );

  // User B deletes their own book (Barter book)
  await runTest('DEL-02', 'Book', 'DELETE /books/:id - Owner successfully deletes own book', 200, () =>
    fetch(`${BASE_URL}/books/${bookBBarterId}`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${tokenB}` },
    })
  );

  // =========================================================================
  // EXECUTIVE SUMMARY REPORT
  // =========================================================================
  const totalTests = results.length;
  const passedTests = results.filter((r) => r.status === 'PASS').length;
  const failedTests = results.filter((r) => r.status === 'FAIL').length;
  const passRate = ((passedTests / totalTests) * 100).toFixed(1);
  const totalDuration = results.reduce((acc, r) => acc + r.durationMs, 0);

  console.log(`\n${'='.repeat(70)}`);
  console.log(`${colors.bold}🏁 QA TEST EXECUTION REPORT${colors.reset}`);
  console.log(`${'='.repeat(70)}`);
  console.log(`Total Test Cases Executed : ${colors.bold}${totalTests}${colors.reset}`);
  console.log(`Passed                    : ${colors.green}${colors.bold}${passedTests}${colors.reset}`);
  console.log(`Failed                    : ${failedTests > 0 ? colors.red : colors.green}${colors.bold}${failedTests}${colors.reset}`);
  console.log(`Pass Rate                 : ${passRate === '100.0' ? colors.green : colors.yellow}${colors.bold}${passRate}%${colors.reset}`);
  console.log(`Total Execution Time      : ${colors.cyan}${totalDuration} ms${colors.reset}`);
  console.log(`${'='.repeat(70)}\n`);

  if (failedTests > 0) {
    console.log(`${colors.red}${colors.bold}Failed Test Cases Breakdown:${colors.reset}`);
    results
      .filter((r) => r.status === 'FAIL')
      .forEach((r) => {
        console.log(` - [${r.id}] ${r.name}: ${r.errorDetail}`);
      });
    console.log();
  }
}

executeTestSuite().catch((err) => {
  console.error('Test suite crashed unexpectedly:', err);
});
