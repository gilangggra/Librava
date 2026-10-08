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
│   ├── schema.prisma           # Schema Prisma 7 (users, books, events, event_registrations, book_ratings, transactions, chats, reviews)
│   └── seed.ts                 # Database seeder: users, books, transactions, chats, reviews
├── src/
│   ├── config/
│   │   ├── database.ts         # Connection pool PostgreSQL & auto-init schema tabel
│   │   ├── prisma.ts           # Init Prisma Client v7 dengan adapter PrismaPg & dotenv
│   │   └── security.ts         # Validasi JWT_SECRET wajib dan panjang minimum
│   ├── controllers/
│   │   ├── admin.controller.ts # Dashboard, users, transactions, moderasi buku
│   │   ├── auth.controller.ts  # Register, login, profile, Google login
│   │   ├── book-rating.controller.ts # Rating & review buku per item
│   │   ├── book.controller.ts  # CRUD buku, my-books, filter status & moderasi
│   │   ├── chat.controller.ts  # Riwayat pesan & kirim chat
│   │   ├── event.controller.ts # CRUD event admin, view & registrasi event mahasiswa
│   │   ├── review.controller.ts # Rating transaksi antar user
│   │   └── transaction.controller.ts # Lifecycle peminjaman & barter
│   ├── generated/
│   │   └── prisma/             # Client Prisma 7, digenerate langsung ke source tree
│   ├── middlewares/
│   │   ├── auth.middleware.ts  # Verifikasi JWT (authenticate) & role check (authorizeAdmin)
│   │   ├── error.middleware.ts # Global error handler & 404
│   │   ├── upload.middleware.ts # Handler upload file multipart/form-data (Multer)
│   │   └── validate.middleware.ts # Middleware validasi request body/query via Zod
│   ├── models/
│   │   └── schema.sql          # DDL tabel PostgreSQL
│   ├── routes/
│   │   ├── admin.routes.ts     # Rute monitoring & moderasi buku admin
│   │   ├── auth.routes.ts      # Rute register, login, profile, Google auth
│   │   ├── book.routes.ts      # Rute katalog, detail, CRUD buku & book rating
│   │   ├── chat.routes.ts      # Rute percakapan per transaksi
│   │   ├── event.routes.ts     # Rute event kampus & registrasi event
│   │   ├── review.routes.ts    # Rute ulasan transaksi antar pengguna
│   │   ├── transaction.routes.ts # Rute pengajuan, persetujuan, handover, return
│   │   ├── upload.routes.ts    # Rute upload gambar buku/profil/event
│   │   └── index.ts            # Route aggregator + health check (/api, /api/health)
│   ├── schemas/
│   │   ├── auth.schema.ts      # Skema validasi Zod register, login, profile, Google auth
│   │   ├── book.schema.ts      # Skema validasi Zod buku & moderasi
│   │   ├── chat.schema.ts      # Skema validasi Zod pesan chat
│   │   ├── event.schema.ts     # Skema validasi Zod event & registrasi
│   │   ├── review.schema.ts    # Skema validasi Zod ulasan transaksi & book rating
│   │   └── transaction.schema.ts # Skema validasi Zod pengajuan & aksi transaksi
│   ├── services/
│   │   ├── admin.service.ts    # Statistik dashboard, data user, moderasi buku
│   │   ├── auth.service.ts     # Registrasi, bcrypt, JWT, Google OAuth2 verify
│   │   ├── book-rating.service.ts # Agregasi rating & CRUD ulasan buku
│   │   ├── book.service.ts     # CRUD buku, filter katalog moderasi, search
│   │   ├── chat.service.ts     # Pesan chat transaksi & status is_read
│   │   ├── event.service.ts    # CRUD event, filter tanggal/kategori, atomic registration
│   │   ├── review.service.ts   # Rating transaksi & rata-rata reputasi user
│   │   └── transaction.service.ts # Lifecycle pinjam/barter, matching buku, deposit dummy
│   ├── socket/
│   │   └── index.ts            # Socket.IO realtime handler untuk chat transaksi
│   ├── types/
│   │   └── index.ts            # TypeScript interfaces & DTO
│   ├── utils/
│   │   └── sanitize.ts         # Sanitasi input teks (anti-XSS)
│   ├── app.ts                  # Setup Express, CORS, Helmet, Rate Limiter
│   ├── server.ts               # Bootstrap server, Socket.IO & koneksi DB
│   └── test_api_e2e.ts         # E2E runner script
├── uploads/                    # Direktori penyimpanan static file gambar
├── .env
├── .env.example
├── package.json                # Scripts & dependencies
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

### Moderasi Buku, Event, dan Rating

- `GET /api/admin/books/pending` — daftar buku berstatus `PENDING` untuk admin.
- `PATCH /api/admin/books/:id/moderasi` — body `{ "action": "APPROVE" | "REJECT", "catatan?": "..." }`; reject menandai buku `DITOLAK` tanpa menghapus histori.
- `GET /api/events` dan `GET /api/events/:id` — daftar/detail event aktif dengan filter `search`, `kategori`, `mulai_dari`, dan `sampai_dengan`.
- `POST|PUT|DELETE /api/events` — manajemen event khusus admin.
- `POST /api/events/:id/register` — pendaftaran mahasiswa dengan proteksi kuota atomic.
- `POST /api/auth/google` — login memakai Google `id_token`; membutuhkan `GOOGLE_CLIENT_ID`.
- `GET|POST|DELETE /api/books/:id/reviews` — agregat review publik dan upsert/hapus rating mahasiswa.

Kolom buku baru memiliki `status_moderasi` default `PENDING`; katalog publik hanya menampilkan `DISETUJUI`.

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
   Perintah ini membuat tabel event, pendaftaran event, rating buku, indeks pencarian, dan kolom moderasi:
   ```bash
   npx prisma db push
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

### 08 Oktober 2026

**Penyelarasan Kebutuhan SRS Resmi & Ekspansi Database Schema**
- **Moderasi Buku Pra-Katalog (`FR-ADM-07`, `FR-BUK-003`)**:
  - Menambahkan kolom `statusModerasi` (`status_moderasi` VARCHAR(30), default: `"PENDING"`) dan `catatanModerasi` (`catatan_moderasi` TEXT) pada model `Book`.
  - Menambahkan index `@@index([statusModerasi])` dan `@@index([ownerId])` untuk mempercepat query katalog publik (`statusModerasi = 'DISETUJUI'`) dan filter antrean peninjauan buku oleh Admin.
- **Modul Event Kampus & Literasi (`FR-EVT-01`, `FR-EVT-02`)**:
  - Menambahkan model `Event` (`id`, `judul`, `deskripsi`, `kategori`, `lokasi`, `tanggalMulai`, `tanggalSelesai`, `kuota`, `fotoEvent`, `createdById`, timestamps) dengan relasi `createdBy` ke model `User` (`onDelete: Cascade`).
  - Menambahkan model `EventRegistration` untuk pendaftaran mahasiswa dengan constraint unik `@@unique([eventId, userId])`.
  - Menambahkan database indexing: `@@index([tanggalMulai])`, `@@index([kategori])`, `@@index([createdById])`, `@@index([eventId])`, dan `@@index([userId])`.
- **Modul Rating & Ulasan Buku (Book Rating)**:
  - Menambahkan model `BookRating` untuk penilaian langsung pada karya/unit buku (skala 1–5 bintang): `id`, `bookId`, `userId`, `rating`, `komentar`, timestamps.
  - Menambahkan constraint unik `@@unique([bookId, userId])` (1 user hanya bisa memberi 1 rating per buku, mendukung update rating) serta indexing `@@index([bookId])` dan `@@index([userId])`.
- **Pembaruan Relasi Model `User`**:
  - Menambahkan relasi `events` (`Event[]`), `eventRegistrations` (`EventRegistration[]`), dan `bookRatings` (`BookRating[]`).
- **Autentikasi Google OAuth2**:
  - Menambahkan variabel environment `GOOGLE_CLIENT_ID` pada `.env.example` dan `.env`.
  - Mengonfigurasi dependensi `google-auth-library` untuk persiapan endpoint verifikasi `id_token` (`POST /api/auth/google`).

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
