# 📚 Librava Backend API

Backend REST API untuk **Librava** (Aplikasi Mobile Barter & Peminjaman Buku Antar-Mahasiswa berbasis Flutter & ExpressJS).

## 🛠️ Tech Stack
- **Runtime**: Node.js (v20+)
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: PostgreSQL (`pg` connection pool)
- **Security**: JWT (`jsonwebtoken`) & `bcryptjs`
- **Dev Runner**: `tsx`

---

## 📁 Struktur Folder (Clean Layered Architecture)
```text
backend/
├── src/
│   ├── config/
│   │   └── database.ts             # PostgreSQL Pool & Auto-Init Schema
│   ├── controllers/
│   │   ├── admin.controller.ts     # Controller Admin Dashboard
│   │   ├── auth.controller.ts      # Controller Auth & Profil
│   │   ├── book.controller.ts      # Controller CRUD Buku & Filter
│   │   ├── chat.controller.ts      # Controller Pesan Chat Transaksi
│   │   ├── review.controller.ts    # Controller Rating & Review
│   │   └── transaction.controller.ts# Controller Peminjaman & Barter
│   ├── middlewares/
│   │   ├── auth.middleware.ts      # JWT Verification & Role Authorization (Admin)
│   │   └── error.middleware.ts     # Global Error Handler & 404
│   ├── models/
│   │   └── schema.sql              # PostgreSQL DDL
│   ├── routes/
│   │   ├── admin.routes.ts         # /api/admin
│   │   ├── auth.routes.ts          # /api/auth
│   │   ├── book.routes.ts          # /api/books
│   │   ├── chat.routes.ts          # /api/chats
│   │   ├── review.routes.ts        # /api/reviews
│   │   ├── transaction.routes.ts   # /api/transactions
│   │   └── index.ts                # Main Route Aggregator
│   ├── services/
│   │   ├── admin.service.ts
│   │   ├── auth.service.ts
│   │   ├── book.service.ts
│   │   ├── chat.service.ts
│   │   ├── review.service.ts
│   │   └── transaction.service.ts
│   ├── types/
│   │   └── index.ts                # TypeScript Interfaces
│   ├── app.ts                      # Express App Configuration
│   └── server.ts                   # Server Bootstrap
├── .env                            # Environment Variables
├── .env.example
├── package.json
└── tsconfig.json
```

---

## 🚀 Cara Menjalankan Backend

### 1. Jalankan PostgreSQL (via Docker)
```bash
docker run --name librava-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=librava_db -p 5432:5432 -d postgres
```

### 2. Development Mode
```bash
cd backend
npm run dev
```

### 3. Build & Production Mode
```bash
npm run build
npm start
```

---

## 📡 Dokumentasi Endpoint REST API

### 1. 🔐 Autentikasi (`/api/auth`)
| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| `POST` | `/api/auth/register` | Publik | Registrasi akun baru (`email`, `password`, `nama_lengkap`, `nim`, `universitas`, dll) |
| `POST` | `/api/auth/login` | Publik | Login & mendapatkan JWT token |
| `GET` | `/api/auth/profile` | `Bearer Token` | Mengambil data profil user yang sedang login |
| `PUT` | `/api/auth/profile` | `Bearer Token` | Update profil user (`nama_lengkap`, `nim`, `universitas`, `foto_profil`) |

---

### 2. 📚 Buku (`/api/books`)
| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| `GET` | `/api/books` | Publik | Ambil semua buku (Query: `search`, `kategori`, `status`, `limit`, `offset`) |
| `GET` | `/api/books/:id` | Publik | Ambil detail satu buku beserta info pemilik |
| `GET` | `/api/books/user/my-books` | `Bearer Token` | Ambil daftar buku yang diunggah oleh user login |
| `POST` | `/api/books` | `Bearer Token` | Upload / tambah buku baru |
| `PUT` | `/api/books/:id` | `Bearer Token` | Edit data buku (hanya pemilik / admin) |
| `DELETE` | `/api/books/:id` | `Bearer Token` | Hapus buku (hanya pemilik / admin) |

---

### 3. 🔄 Transaksi & Matching (`/api/transactions`)
| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| `POST` | `/api/transactions` | `Bearer Token` | Mengajukan pinjam (`BORROW`) / barter (`BARTER`) buku |
| `GET` | `/api/transactions` | `Bearer Token` | Ambil daftar transaksi user (Query: `role=requester\|owner`, `status`) |
| `GET` | `/api/transactions/:id` | `Bearer Token` | Ambil detail transaksi (beserta buku barter, deposit, & lokasi) |
| `PUT` | `/api/transactions/:id/status` | `Bearer Token` | Update status: `DISETUJUI`, `DITOLAK`, `DIBATALKAN`, `SELESAI` |
| `PUT` | `/api/transactions/:id/meeting` | `Bearer Token` | Menentukan `lokasi_pertemuan` & `waktu_pertemuan` |
| `PUT` | `/api/transactions/:id/handover` | `Bearer Token` | Konfirmasi serah terima buku (menyelesaikan transaksi) |

---

### 4. 💬 Chat per Transaksi (`/api/chats`)
| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| `GET` | `/api/chats/:transactionId` | `Bearer Token` | Mengambil seluruh riwayat pesan per transaksi |
| `POST` | `/api/chats/:transactionId` | `Bearer Token` | Mengirim pesan chat baru (`pesan`) |

---

### 5. ⭐ Review & Rating (`/api/reviews`)
| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| `POST` | `/api/reviews` | `Bearer Token` | Memberikan review & rating (1-5) setelah transaksi selesai |
| `GET` | `/api/reviews/user/:userId` | Publik | Melihat seluruh review dan rata-rata rating seorang user |

---

### 6. 🛡️ Admin Monitoring (`/api/admin`)
| Method | Endpoint | Auth | Deskripsi |
|---|---|---|---|
| `GET` | `/api/admin/dashboard` | `Admin Token` | Statistik ringkasan user, buku, transaksi, dan total deposit dummy |
| `GET` | `/api/admin/users` | `Admin Token` | Monitoring seluruh data user |
| `GET` | `/api/admin/transactions` | `Admin Token` | Monitoring seluruh riwayat transaksi sistem |
