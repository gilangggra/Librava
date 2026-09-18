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
│   └── schema.prisma           # Schema Prisma 7 (provider prisma-client, output generated)
├── src/
│   ├── config/
│   │   ├── database.ts         # Connection pool PostgreSQL & auto-init schema tabel
│   │   └── prisma.ts           # Init Prisma Client v7 dengan adapter PrismaPg & dotenv
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
│   └── server.ts               # Bootstrap server, cek koneksi DB, auto table init
├── .env
├── .env.example
├── package.json                # Scripts: dev, build, start, prisma:*, test:qa
├── prisma.config.ts             # Config Prisma 7 CLI & datasource migrations
├── test_qa_suite.ts             # QA suite E2E (52 kasus uji)
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
- `PUT /api/transactions/:id/status` — pemilik approve/reject (`DISETUJUI`, `DITOLAK`, `DIBATALKAN`), status buku ikut ke-update otomatis (`Dipinjam`/`Dibarter`/`Tersedia`).
- `PUT /api/transactions/:id/meeting` — set lokasi & jadwal serah terima, status jadi `DALAM_PROSES`.
- `PUT /api/transactions/:id/handover` — konfirmasi serah terima selesai, status `SELESAI`.

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

## 4. QA Test Suite (`test_qa_suite.ts`)

52 kasus uji E2E, dibagi jadi beberapa kelompok:

1. **Smoke & health check** — `/api/health`, `/api/`, handling 404.
2. **Autentikasi & validasi** — register, cegah email duplikat, tolak password kosong, cek token JWT yang di-tamper/forge, cek profil.
3. **RBAC** — dashboard & monitoring admin diblokir buat mahasiswa (403).
4. **Katalog buku** — CRUD, filter kategori, search, paginasi, proteksi edit/hapus oleh non-pemilik (anti-IDOR).
5. **State machine transaksi** — cegah pinjam buku sendiri, cek kepemilikan buku barter, siklus status `MENUNGGU_KONFIRMASI` → `DISETUJUI` → `DALAM_PROSES` → `SELESAI`, dan status buku ikut ter-update di DB.
6. **Chat** — cuma partisipan transaksi yang bisa baca/kirim pesan, pihak luar diblokir (403).
7. **Rating & reputasi** — rating 1-5, cek transaksi harus selesai dulu, cegah review ganda, kalkulasi rata-rata reputasi.
8. **Teardown** — hak hapus aset cuma buat pemilik sah.

---

## 5. Cara Menjalankan

1. Nyalakan PostgreSQL:
   ```bash
   docker run --name librava-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=librava_db -p 5432:5432 -d postgres
   ```
2. Jalankan server (dev):
   ```bash
   cd backend
   npm run dev
   ```
3. Jalankan QA suite (52 test cases):
   ```bash
   cd backend
   npm run test:qa
   ```
4. Jalankan Security Audit & Penetration Testing (OWASP Top 10):
   ```bash
   cd backend
   npm run test:security
   ```
5. Buka Prisma Studio:
   ```bash
   npm run prisma:studio
   ```
6. API base URL: `http://localhost:5000/api`

---

## 6. Keamanan & Hardening (Cybersecurity)

Backend telah diaudit dan diperkuat sesuai standar **OWASP API Security Top 10**:

1. **Anti-Mass Assignment / Privilege Escalation**: Endpoint registrasi publik `/api/auth/register` secara ketat mengunci `role: 'mahasiswa'`. Role admin tidak dapat diinjeksi via payload publik.
2. **Brute-Force & DoS Protection**: Dilengkapi `express-rate-limit` pada `/api/auth/login` (maksimal 5x percobaan gagal per 15 menit per IP) dan rate limit global pada `/api`.
3. **Security Headers (Helmet)**: Dilengkapi `helmet()` yang menyematkan proteksi browser standar (`X-Content-Type-Options: nosniff`, `X-Frame-Options: SAMEORIGIN`, HSTS, dan menonaktifkan header bocoran `X-Powered-By: Express`).
4. **Anti-Stored XSS**: Input teks buku (`judul`, `penulis`, `deskripsi`) disanitasi menggunakan utilitas pembersih tag script berbahaya (`src/utils/sanitize.ts`).
5. **Anti-SQL Injection**: 100% query basis data menggunakan parameterized abstract syntax tree via **Prisma ORM 7**.
6. **Anti-IDOR (Broken Object Level Authorization)**: Hak akses terhadap buku, chat transaksi, dan rating divalidasi ketat di level Service (`HTTP 403 Forbidden`).
