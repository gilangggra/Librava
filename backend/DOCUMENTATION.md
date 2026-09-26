# Handover & Arsitektur Backend — Librava

## 1. Spesifikasi & Tech Stack

**Project**: Librava — platform peer-to-peer book sharing & barter antar mahasiswa.
**Role**: Backend Developer
**Stack**: Express.js, TypeScript (v7+), PostgreSQL (`pg`), Prisma ORM 7 (`@prisma/adapter-pg`), JWT, `bcryptjs`, `tsx`
**Arsitektur**: Layered — `config` → `routes` → `controllers` → `services` → `generated/prisma`

---

## 2. Struktur Folder (`backend/`)

```text
backend/
├── prisma/
│   ├── schema.prisma           # Schema Prisma 7 (provider prisma-client, output generated)
│   └── seed.ts                 # Database seeder: users (admin + mahasiswa), books, transactions, chats, reviews
├── src/
│   ├── config/
│   │   ├── database.ts         # Connection pool PostgreSQL & auto-init schema tabel
│   │   ├── prisma.ts           # Init Prisma Client v7 dengan adapter PrismaPg & dotenv
│   │   └── security.ts         # Validasi JWT_SECRET wajib dan panjang minimum
│   ├── controllers/
│   │   ├── admin.controller.ts
│   │   ├── auth.controller.ts
│   │   ├── book.controller.ts
│   │   ├── chat.controller.ts
│   │   ├── review.controller.ts
│   │   └── transaction.controller.ts
│   ├── generated/
│   │   └── prisma/             # Client Prisma 7, digenerate langsung ke source tree
│   ├── middlewares/
│   │   ├── auth.middleware.ts  # Verifikasi JWT (authenticate) & role check (authorizeAdmin)
│   │   └── error.middleware.ts # Global error handler & 404
│   ├── models/
│   │   └── schema.sql          # DDL tabel (users, books, transactions, chats, reviews)
│   ├── routes/
│   │   ├── admin.routes.ts
│   │   ├── auth.routes.ts
│   │   ├── book.routes.ts
│   │   ├── chat.routes.ts
│   │   ├── review.routes.ts
│   │   ├── transaction.routes.ts
│   │   └── index.ts            # Route aggregator + health check (/api, /api/health)
│   ├── services/
│   │   ├── admin.service.ts    # Query statistik, data user & transaksi buat admin
│   │   ├── auth.service.ts     # Registrasi, hashing bcrypt, generate JWT, get/update profil
│   │   ├── book.service.ts     # CRUD buku, search multi-field, filter kategori & status
│   │   ├── chat.service.ts     # Kirim pesan & fetch history dengan flag is_read
│   │   ├── review.service.ts   # Rating 1-5, hitung rata-rata rating user
│   │   └── transaction.service.ts # Lifecycle pinjam/barter, matching buku, deposit dummy, handover
│   ├── types/
│   │   └── index.ts            # TS interfaces
│   ├── app.ts                  # Setup Express, CORS, JSON body parser
│   └── server.ts               # Bootstrap server dan validasi koneksi DB
├── .env
├── .env.example
├── package.json                # Scripts: dev, build, start, prisma:*, db:seed, test:*
├── prisma.config.ts             # Config Prisma 7 CLI & datasource migrations
├── test_qa_suite.ts             # QA suite E2E (53 test cases)
├── test_security_audit.ts       # Penetration testing OWASP API Security Top 10
├── tsconfig.json                # Node16 target
└── README.md
```

---

## 3. Modul & Endpoint yang Sudah Jalan

### Autentikasi & Profil (`/api/auth`)

- `POST /api/auth/register` — registrasi akun mahasiswa, password di-hash pakai `bcryptjs`.
- `POST /api/auth/login` — login, return JWT Bearer token.
- `GET /api/auth/profile` — ambil profil user yang lagi login (Bearer token).
- `PUT /api/auth/profile` — update biodata/profil (Bearer token).

### Manajemen & Pencarian Buku (`/api/books`)

- `GET /api/books` — list buku, support query `search`, `kategori`, `status`, `limit`, `offset`.
- `GET /api/books/:id` — detail buku + info pemilik.
- `GET /api/books/user/my-books` — buku milik user login (Bearer token).
- `POST /api/books` — tambah buku baru (Bearer token).
- `PUT /api/books/:id` — edit buku, dibatasi ke pemilik atau admin.
- `DELETE /api/books/:id` — hapus buku, sama, pemilik atau admin saja.

### Transaksi Peminjaman & Barter (`/api/transactions`)

- `POST /api/transactions` — ajukan pinjam (`BORROW`) atau barter (`BARTER`). Validasi ketersediaan buku dan kepemilikan buku yang mau dibarter.
- `GET /api/transactions` — list transaksi user, filter `role=requester|owner` dan `status`.
- `GET /api/transactions/:id` — detail lengkap: kedua pihak, buku yang ditukar, deposit dummy, jadwal/lokasi.
- `PUT /api/transactions/:id/status` — owner hanya dapat approve/reject request pending; requester dapat membatalkan request pending. Status buku ikut diperbarui secara atomic.
- `PUT /api/transactions/:id/meeting` — set lokasi & jadwal setelah request disetujui, lalu status menjadi `DALAM_PROSES`.
- `PUT /api/transactions/:id/handover` — mencatat konfirmasi requester atau owner. Status baru menjadi `SELESAI` setelah kedua pihak mengonfirmasi.
- `PUT /api/transactions/:id/return` — menggunakan mekanisme konfirmasi dua pihak yang sama untuk menyelesaikan transaksi.

#### Lifecycle transaksi dan deposit

Transisi status yang diizinkan:

```text
MENUNGGU_KONFIRMASI -> DISETUJUI -> DALAM_PROSES -> SELESAI
MENUNGGU_KONFIRMASI -> DITOLAK
MENUNGGU_KONFIRMASI -> DIBATALKAN
```

Deposit tidak ditarik saat request dibuat. Pada approval, saldo requester dikurangi menggunakan conditional update (`saldo_dummy >= deposit`) di dalam transaksi database. Jika saldo tidak cukup, approval dibatalkan. Deposit dikembalikan satu kali ketika kedua pihak mengonfirmasi handover.

### Chat per Transaksi (`/api/chats`)

- `GET /api/chats/:transactionId` — riwayat pesan antara peminjam & pemilik.
- `POST /api/chats/:transactionId` — kirim pesan baru.

### Rating & Ulasan (`/api/reviews`)

- `POST /api/reviews` — kasih rating (1-5) & feedback ke rekan transaksi, hanya bisa setelah status `SELESAI`.
- `GET /api/reviews/user/:userId` — lihat ulasan & rata-rata rating seorang mahasiswa.

### Admin Monitoring (`/api/admin`)

- `GET /api/admin/dashboard` — statistik total user, buku (tersedia/dipinjam/dibarter), transaksi aktif, total deposit dummy.
- `GET /api/admin/users` — monitoring semua data mahasiswa & admin.
- `GET /api/admin/transactions` — log seluruh transaksi sistem.

---

## 4. Database Seeding (`prisma/seed.ts`)

Seed script menginisialisasi data demo ke semua tabel menggunakan Prisma upsert (aman dijalankan berulang kali tanpa duplikat).

### Data yang di-seed

| Tabel | Jumlah | Detail |
|---|---|---|
| **Users** | Demo data | 1 admin + mahasiswa demo tanpa credential ditulis di dokumentasi |
| **Books** | 8 | Clean Code, Pragmatic Programmer, Algoritma Python, Filosofi Teras, Sistem Basis Data, Atomic Habits, Laskar Pelangi, Jaringan Komputer |
| **Transactions** | 4 | SELESAI, DALAM_PROSES, DISETUJUI, MENUNGGU_KONFIRMASI |
| **Chats** | 14 | Percakapan realistis di setiap transaksi |
| **Reviews** | 2 | Rating 5★ pada transaksi yang sudah SELESAI |

### Credentials

Credential demo/admin tidak ditulis di dokumentasi. Simpan email dan password hanya di environment lokal atau secret manager.

| Role | Email |
|---|---|
| Admin | `<admin-email>` |
| Mahasiswa | `<user-email>` |

### Cara menjalankan

```bash
DATABASE_URL='postgresql://...' npm run db:seed
```

---

## 5. QA Test Suite (`test_qa_suite.ts`)

Suite E2E terdiri dari **53 test cases** yang dibagi jadi 8 kelompok:

1. **Smoke & health check** — `/api/health` memverifikasi koneksi database, `/api/`, handling 404.
2. **Autentikasi & validasi** — register, cegah email duplikat, tolak password kosong, cek token JWT yang di-tamper/forge, cek profil.
3. **RBAC** — dashboard & monitoring admin diblokir buat mahasiswa (403), admin yang sudah di-seed bisa login dan akses dashboard/transaksi admin.
4. **Katalog buku** — CRUD, filter kategori, search, paginasi, proteksi edit/hapus oleh non-pemilik (anti-IDOR).
5. **State machine transaksi** — cegah pinjam buku sendiri, cek kepemilikan buku barter, enforce siklus status `MENUNGGU_KONFIRMASI` → `DISETUJUI` → `DALAM_PROSES` → `SELESAI`, konfirmasi handover dua pihak, dan status buku ikut ter-update di DB.
6. **Chat** — cuma partisipan transaksi yang bisa baca/kirim pesan, pihak luar diblokir (403).
7. **Rating & reputasi** — rating 1-5, cek transaksi harus selesai dulu, cegah review ganda, kalkulasi rata-rata reputasi.
8. **Teardown** — hak hapus aset cuma buat pemilik sah.

Target test dapat diubah dengan `API_BASE_URL`; default-nya tetap `http://localhost:5000`. Credential admin dikonfigurasi melalui `ADMIN_EMAIL` dan `ADMIN_PASSWORD`. Jika tidak tersedia, test admin dilewati (SKIP), bukan dianggap gagal.

---

## 6. Cara Menjalankan

1. Nyalakan PostgreSQL:
   ```bash
   docker run --name librava-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=librava_db -p 5432:5432 -d postgres
   ```
2. Sinkronkan schema Prisma:
   ```bash
   cd backend
   npm run prisma:push
   ```
3. Seed database (opsional, untuk demo data):
   ```bash
   DATABASE_URL='postgresql://...' npm run db:seed
   ```
4. Jalankan server (dev):
   ```bash
   cd backend
   npm run dev
   ```
5. Jalankan QA suite:
   ```bash
   npm run test:qa
   ```
6. Jalankan QA suite dengan admin credentials lokal:
   ```bash
   ADMIN_EMAIL='admin-email-kamu' ADMIN_PASSWORD='password-admin-kamu' npm run test:qa
   ```
7. Jalankan Security Audit & Penetration Testing (OWASP Top 10):
   ```bash
   npm run test:security
   ```
8. Buka Prisma Studio:
   ```bash
   npm run prisma:studio
   ```
9. API base URL lokal: `http://localhost:5000/api`

URL production Railway:

```text
REST API: https://librava-production.up.railway.app/api
Socket.IO: https://librava-production.up.railway.app
Health: https://librava-production.up.railway.app/api/health
```

Untuk menjalankan test terhadap Railway:

```bash
API_BASE_URL=https://librava-production.up.railway.app ADMIN_EMAIL='admin-email-kamu' ADMIN_PASSWORD='password-admin-kamu' npm run test:qa
API_BASE_URL=https://librava-production.up.railway.app npm run test:security
```

---

## 7. Keamanan & Hardening (Cybersecurity)

Backend menerapkan kontrol berikut sebagai bagian dari hardening **OWASP API Security Top 10**:

1. **Anti-Mass Assignment / Privilege Escalation**: Endpoint registrasi publik `/api/auth/register` secara ketat mengunci `role: 'mahasiswa'`. Role admin tidak dapat diinjeksi via payload publik.
2. **Brute-Force & DoS Protection**: Dilengkapi rate limit global pada `/api`. Audit production terakhir masih menemukan bahwa rate limit khusus pada percobaan login perlu diperketat; ini menjadi pekerjaan lanjutan sebelum production hardening dianggap selesai.
3. **Security Headers (Helmet)**: Dilengkapi `helmet()` yang menyematkan proteksi browser standar (`X-Content-Type-Options: nosniff`, `X-Frame-Options: SAMEORIGIN`, HSTS, dan menonaktifkan header bocoran `X-Powered-By: Express`).
4. **Anti-Stored XSS**: Input teks buku (`judul`, `penulis`, `deskripsi`) disanitasi menggunakan utilitas pembersih tag script berbahaya (`src/utils/sanitize.ts`).
5. **Anti-SQL Injection**: 100% query basis data menggunakan parameterized abstract syntax tree via **Prisma ORM 7**.
6. **Anti-IDOR (Broken Object Level Authorization)**: Hak akses terhadap buku, chat transaksi, dan rating divalidasi ketat di level Service (`HTTP 403 Forbidden`).
7. **JWT Secret Policy**: JWT ditolak jika `JWT_SECRET` tidak tersedia atau kurang dari 32 karakter; tidak ada fallback secret production.
8. **CORS Allowlist**: HTTP API dan Socket.IO hanya menerima origin yang terdaftar di `CORS_ORIGIN`.
9. **Atomic Transaction Rules**: Approval, penahanan deposit, refund, dan perubahan status diproses dalam transaksi database dengan guard terhadap concurrent update.

---

## 8. Changelog

### 26 September 2026

**Database Seeding**
- Menambahkan `prisma/seed.ts` — seed script lengkap untuk semua tabel (Users, Books, Transactions, Chats, Reviews) dengan data demo realistis konteks Telkom University.
- Menambahkan script `db:seed` di `package.json` (`tsx prisma/seed.ts`).
- Menghapus `scripts/ensure-admin.ts` — fungsinya sudah ter-cover oleh seed script yang lebih lengkap.
- Menghapus script `admin:ensure` dari `package.json`.

**QA Test Suite — Production Validation**
- QA suite dijalankan terhadap Railway production: **53/53 PASS (100%)** dengan admin credentials.
- Semua 8 suite berjalan penuh termasuk RBAC admin (RBAC-03, RBAC-04) yang sebelumnya di-SKIP karena belum ada akun admin.
- Total execution time: ~3.6 detik.

**Security Audit**
- Security audit (`test_security_audit.ts`) berjalan sukses terhadap production.
- SQL injection, IDOR, mass assignment, XSS, dan security headers lolos audit.

**Hasil Validasi Production (26 September 2026)**
- Railway `/api/health`: `200 OK`, database `connected` via Supabase.
- QA suite: **53/53 PASS** dengan credential admin dari seed.
- Security audit: semua cek keamanan OWASP lolos.
