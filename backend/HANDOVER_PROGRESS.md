# 📚 DOKUMEN HANDOVER & ARSITEKTUR BACKEND — LIBRAVA

## 1. 📌 Spesifikasi & Tech Stack
- **Nama Project**: Librava (Peer-to-Peer Book Sharing & Barter Antar-Mahasiswa)
- **Role**: Backend Developer
- **Stack**: Express.js, TypeScript (v7+), PostgreSQL (`pg`), JWT, `bcryptjs`, `tsx`
- **Arsitektur**: Clean Layered Architecture (`config` ➔ `routes` ➔ `controllers` ➔ `services` ➔ `models`)

---

## 2. 🗂️ Struktur File & Folder Lengkap (`backend/`)
```text
backend/
├── src/
│   ├── config/
│   │   └── database.ts             # Connection Pool PostgreSQL & Auto-Init Schema Tabel
│   ├── controllers/
│   │   ├── admin.controller.ts     # Controller Dashboard & Monitoring Admin
│   │   ├── auth.controller.ts      # Controller Register, Login, Profil User
│   │   ├── book.controller.ts      # Controller CRUD Buku & Filter/Search
│   │   ├── chat.controller.ts      # Controller Chat per Transaksi
│   │   ├── review.controller.ts    # Controller Rating & Ulasan
│   │   └── transaction.controller.ts# Controller Pengajuan Pinjam/Barter & Serah Terima
│   ├── middlewares/
│   │   ├── auth.middleware.ts      # Verifikasi JWT (authenticate) & Hak Akses (authorizeAdmin)
│   │   └── error.middleware.ts     # Global Error Handler & 404
│   ├── models/
│   │   └── schema.sql              # DDL Tabel PostgreSQL (users, books, transactions, chats, reviews)
│   ├── routes/
│   │   ├── admin.routes.ts         # Endpoint /api/admin
│   │   ├── auth.routes.ts          # Endpoint /api/auth
│   │   ├── book.routes.ts          # Endpoint /api/books
│   │   ├── chat.routes.ts          # Endpoint /api/chats
│   │   ├── review.routes.ts        # Endpoint /api/reviews
│   │   ├── transaction.routes.ts   # Endpoint /api/transactions
│   │   └── index.ts                # Main Route Aggregator & Health check (/api & /api/health)
│   ├── services/
│   │   ├── admin.service.ts        # Query ringkasan statistik, data user, dan transaksi admin
│   │   ├── auth.service.ts         # Logika registrasi, hashing bcrypt, generate JWT, get/update profil
│   │   ├── book.service.ts         # Query CRUD buku, search multi-field, filter kategori & status
│   │   ├── chat.service.ts         # Logika kirim pesan & get pesan chat dengan tanda is_read
│   │   ├── review.service.ts       # Logika rating 1-5, hitung rata-rata rating user
│   │   └── transaction.service.ts  # Lifecycle pinjam/barter, matching buku, deposit dummy, serah terima
│   ├── types/
│   │   └── index.ts                # TypeScript Interfaces lengkap
│   ├── app.ts                      # Inisialisasi Express, CORS, JSON Body Parser
│   └── server.ts                   # Bootstrap Server, Cek Database & Auto Table Initializer
├── .env                            # Konfigurasi Environment Lokal
├── .env.example                    # Template Environment
├── package.json                    # Scripts: "dev": "tsx watch src/server.ts", "build": "tsc", "start": "node dist/server.js"
├── tsconfig.json                   # Konfigurasi TypeScript Node16
└── README.md                       # Panduan Lengkap Backend
```

---

## 3. ✅ Modul & Endpoint yang Telah Diimplementasikan (100% Selesai)

### 🔐 A. Autentikasi & Profil (`/api/auth`)
- `POST /api/auth/register` — Registrasi akun mahasiswa baru (password di-hash dengan `bcryptjs`).
- `POST /api/auth/login` — Login akun mahasiswa & menghasilkan JWT Bearer token.
- `GET /api/auth/profile` — Mengambil data profil user yang sedang login (`Bearer Token`).
- `PUT /api/auth/profile` — Memperbarui biodata / profil user (`Bearer Token`).

### 📚 B. Manajemen & Pencarian Buku (`/api/books`)
- `GET /api/books` — Mengambil seluruh buku dengan query parameter (`search`, `kategori`, `status`, `limit`, `offset`).
- `GET /api/books/:id` — Mengambil detail buku beserta informasi identitas pemilik.
- `GET /api/books/user/my-books` — Mengambil buku milik user yang sedang login (`Bearer Token`).
- `POST /api/books` — Menambahkan buku baru (`Bearer Token`).
- `PUT /api/books/:id` — Mengedit buku (hanya pemilik atau admin).
- `DELETE /api/books/:id` — Menghapus buku (hanya pemilik atau admin).

### 🔄 C. Transaksi Peminjaman & Barter (`/api/transactions`)
- `POST /api/transactions` — Mengajukan pinjam (`BORROW`) / barter (`BARTER`). Validasi ketersediaan buku & kepemilikan buku barter.
- `GET /api/transactions` — Menampilkan daftar transaksi user (filter `role=requester|owner`, `status`).
- `GET /api/transactions/:id` — Detail transaksi lengkap (info kedua pihak, buku yang ditukar, deposit dummy, waktu/tempat).
- `PUT /api/transactions/:id/status` — Pemilik menerima/menolak permintaan (`DISETUJUI`, `DITOLAK`, `DIBATALKAN`). Otomatis update status buku (`Dipinjam`/`Dibarter`/`Tersedia`).
- `PUT /api/transactions/:id/meeting` — Menentukan lokasi & jadwal pertemuan serah terima (status berubah jadi `DALAM_PROSES`).
- `PUT /api/transactions/:id/handover` — Konfirmasi serah terima buku selesai (`SELESAI`).

### 💬 D. Chat per Transaksi (`/api/chats`)
- `GET /api/chats/:transactionId` — Mengambil riwayat pesan antara peminjam & pemilik buku.
- `POST /api/chats/:transactionId` — Mengirim pesan chat baru.

### ⭐ E. Rating & Ulasan (`/api/reviews`)
- `POST /api/reviews` — Memberikan rating (1-5) & feedback untuk rekan transaksi setelah transaksi `SELESAI`.
- `GET /api/reviews/user/:userId` — Melihat ulasan & rata-rata rating mahasiswa.

### 🛡️ F. Admin Monitoring (`/api/admin`)
- `GET /api/admin/dashboard` — Menampilkan statistik total user, buku tersedia/dipinjam/dibarter, transaksi aktif, & total deposit dummy.
- `GET /api/admin/users` — Monitoring seluruh data mahasiswa & admin.
- `GET /api/admin/transactions` — Monitoring seluruh log transaksi sistem.

---

## 4. 🚀 Cara Menjalankan Backend
1. Nyalakan container PostgreSQL:
   ```bash
   docker run --name librava-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=librava_db -p 5432:5432 -d postgres
   ```
2. Jalankan server:
   ```bash
   cd backend
   npm run dev
   ```
3. Akses API di `http://localhost:5000/api`.
