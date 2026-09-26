# 📚 Librava Backend API

Backend REST API untuk **Librava** (Aplikasi Mobile Barter & Peminjaman Buku Antar-Mahasiswa berbasis Flutter & ExpressJS).

## 🛠️ Tech Stack
- **Runtime**: Node.js (v20+)
- **Language**: TypeScript
- **Framework**: Express.js
- **ORM**: Prisma ORM 7 (`@prisma/adapter-pg`)
- **Database**: PostgreSQL (`pg` connection pool)
- **Security**: JWT (`jsonwebtoken`), `bcryptjs`, Helmet, CORS allowlist & rate limiting
- **Dev Runner**: `tsx`

---

## 📁 Struktur Folder (Clean Layered Architecture)
```text
backend/
├── prisma/
│   ├── schema.prisma              # Schema Prisma 7
│   └── seed.ts                    # Database seeder (semua tabel)
├── src/
│   ├── config/
│   │   ├── database.ts            # PostgreSQL Pool & Auto-Init Schema
│   │   ├── prisma.ts              # Prisma Client v7 + PrismaPg adapter
│   │   └── security.ts            # Validasi JWT_SECRET
│   ├── controllers/
│   │   ├── admin.controller.ts
│   │   ├── auth.controller.ts
│   │   ├── book.controller.ts
│   │   ├── chat.controller.ts
│   │   ├── review.controller.ts
│   │   └── transaction.controller.ts
│   ├── middlewares/
│   │   ├── auth.middleware.ts     # JWT Verification & Role Authorization
│   │   └── error.middleware.ts    # Global Error Handler & 404
│   ├── models/
│   │   └── schema.sql             # PostgreSQL DDL
│   ├── routes/
│   │   ├── admin.routes.ts
│   │   ├── auth.routes.ts
│   │   ├── book.routes.ts
│   │   ├── chat.routes.ts
│   │   ├── review.routes.ts
│   │   ├── transaction.routes.ts
│   │   └── index.ts               # Main Route Aggregator
│   ├── services/
│   │   ├── admin.service.ts
│   │   ├── auth.service.ts
│   │   ├── book.service.ts
│   │   ├── chat.service.ts
│   │   ├── review.service.ts
│   │   └── transaction.service.ts
│   ├── types/
│   │   └── index.ts               # TypeScript Interfaces
│   ├── app.ts                     # Express App Configuration
│   └── server.ts                  # Server Bootstrap
├── .env
├── .env.example
├── package.json
├── test_qa_suite.ts               # QA suite E2E (53 test cases)
├── test_security_audit.ts         # OWASP API Security Top 10
└── tsconfig.json
```

---

## 🚀 Cara Menjalankan Backend

### 1. Jalankan PostgreSQL (via Docker)
```bash
docker run --name librava-postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=librava_db -p 5432:5432 -d postgres
```

### 2. Sinkronkan Schema Prisma
```bash
cd backend
npm run prisma:push
```

### 3. Seed Database (Opsional)
```bash
DATABASE_URL='postgresql://...' npm run db:seed
```

### 4. Development Mode
```bash
cd backend
npm run dev
```

### 5. Build & Production Mode
```bash
npm run build
npm start
```

---

## 🌱 Database Seeding

Seed script (`prisma/seed.ts`) menginisialisasi data demo ke semua tabel. Aman dijalankan berulang kali (menggunakan upsert).

### Data yang di-seed

| Tabel | Jumlah | Detail |
|---|---|---|
| **Users** | 5 | 1 admin + 4 mahasiswa |
| **Books** | 8 | Berbagai kategori (Teknologi, Self-Improvement, Novel) |
| **Transactions** | 4 | Semua status: SELESAI, DALAM_PROSES, DISETUJUI, MENUNGGU |
| **Chats** | 14 | Percakapan realistis di setiap transaksi |
| **Reviews** | 2 | Rating 5★ pada transaksi SELESAI |

### Credentials (password sama: `password123456`)

| Role | Email |
|---|---|
| 👑 Admin | `admin@librava.com` |
| 🎓 Mahasiswa | `budi@student.telkomuniversity.ac.id` |
| 🎓 Mahasiswa | `sari@student.telkomuniversity.ac.id` |
| 🎓 Mahasiswa | `andi@student.telkomuniversity.ac.id` |
| 🎓 Mahasiswa | `rina@student.telkomuniversity.ac.id` |

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
| `PUT` | `/api/transactions/:id/status` | `Bearer Token` | Owner approve/reject request; requester dapat membatalkan request pending |
| `PUT` | `/api/transactions/:id/meeting` | `Bearer Token` | Menentukan `lokasi_pertemuan` & `waktu_pertemuan` setelah request disetujui |
| `PUT` | `/api/transactions/:id/handover` | `Bearer Token` | Mencatat konfirmasi serah terima; status `SELESAI` setelah requester dan owner mengonfirmasi |

#### Lifecycle transaksi

```text
MENUNGGU_KONFIRMASI -> DISETUJUI -> DALAM_PROSES -> SELESAI
MENUNGGU_KONFIRMASI -> DITOLAK
MENUNGGU_KONFIRMASI -> DIBATALKAN
```

Deposit dummy tidak dipotong saat request dibuat. Saldo ditahan secara atomic ketika owner menyetujui request dan dikembalikan setelah kedua pihak menyelesaikan handover.

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

---

### 7. ⚙️ Health & Konfigurasi

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/api/health` | Mengembalikan `200` jika API dan database dapat diakses; `503` jika database gagal |

`JWT_SECRET` wajib diatur di `.env` dan minimal 32 karakter. Server tidak akan membuka port apabila koneksi database gagal.

---

## 🧪 Testing

### QA Test Suite (53 test cases)
```bash
# Lokal
npm run test:qa

# Lokal dengan admin
ADMIN_EMAIL='admin@librava.com' ADMIN_PASSWORD='password123456' npm run test:qa

# Production (Railway)
API_BASE_URL=https://librava-production.up.railway.app \
ADMIN_EMAIL='admin@librava.com' \
ADMIN_PASSWORD='password123456' \
npm run test:qa
```

### Security Audit (OWASP Top 10)
```bash
# Lokal
npm run test:security

# Production
API_BASE_URL=https://librava-production.up.railway.app npm run test:security
```

### Hasil Validasi Production (26 September 2026)
- QA suite: **53/53 PASS (100%)** ✅
- Security audit: semua cek keamanan OWASP lolos ✅
- `/api/health`: `200 OK`, database `connected` via Supabase ✅

---

## 🚀 Deploy ke Railway + Supabase

Backend production berjalan di Railway, PostgreSQL menggunakan Supabase.

**Railway Config:**
- Root directory: `/backend`
- Region: Singapore
- Build: `npm ci && npm run prisma:generate && npm run prisma:push && npm run build`
- Start: `npm start`
- Health check: `/api/health`

**Environment Variables (Railway):**
```env
NODE_ENV=production
DATABASE_URL=postgresql://...pooler.supabase.com:5432/postgres
JWT_SECRET=random-secret-minimal-32-karakter
JWT_EXPIRES_IN=7d
CORS_ORIGIN=*
```

Gunakan connection string **Session Pooler** dari Supabase. Railway menyediakan `PORT` secara otomatis.

**URL Production:**
```
https://librava-production.up.railway.app
https://librava-production.up.railway.app/api/health
```

---

## 🔒 Keamanan (OWASP API Security Top 10)

1. **Anti-Mass Assignment**: Role `mahasiswa` di-hardcode pada register publik
2. **Brute-Force Protection**: Rate limit global pada `/api`
3. **Security Headers**: Helmet (`nosniff`, `SAMEORIGIN`, HSTS, no `X-Powered-By`)
4. **Anti-XSS**: Sanitasi input teks buku
5. **Anti-SQL Injection**: 100% parameterized query via Prisma ORM 7
6. **Anti-IDOR**: Validasi akses di level Service (403 Forbidden)
7. **JWT Secret Policy**: Minimal 32 karakter, no fallback
8. **CORS Allowlist**: Origin terdaftar untuk HTTP API dan Socket.IO
9. **Atomic Transactions**: Approval, deposit, dan status dalam database transaction
