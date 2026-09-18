# 🏛️ Panduan Struktur Arsitektur Librava Mobile
> **Pola Arsitektur:** *Feature-First Clean Architecture*  
> **State Management:** *Provider (`ChangeNotifier`)*  
> **Teknologi:** Flutter & Dart

Dokumen ini disusun sebagai panduan belajar untuk memahami fungsi setiap folder dan lapisan (*layer*) kode pada proyek **Librava Mobile**, serta bagaimana setiap bagian saling terhubung.

---

## 🍽️ Analogi Sederhana: Sistem Restoran Modern

Agar sangat mudah dipahami, struktur aplikasi Librava dirancang persis seperti alur kerja sebuah **Restoran Modern**:

| Lapisan di Kodingan | Komponen di Restoran | Tugas & Tanggung Jawab |
| :--- | :--- | :--- |
| **`presentation/screens`** | **Ruang Makan & Meja Pelanggan** | Tempat pelanggan (pengguna HP) duduk, melihat daftar menu, dan berinteraksi. |
| **`presentation/widgets`** | **Peralatan Meja (Sendok/Piring)** | Komponen kecil yang dipakai berulang di berbagai meja (tombol, kolom isian). |
| **`presentation/providers`** | **Pelayan (*Waiter*)** | Mencatat pesanan dari layar, meminta data ke dapur, dan menyajikan hasilnya kembali ke layar (`notifyListeners()`). |
| **`domain/models`** | **Buku Menu & Standar Resep** | Format baku data (mendefinisikan apa saja informasi wajib pada sebuah buku atau transaksi). |
| **`data/repositories`** | **Kulkas & Gudang Bahan Baku** | Tempat mengambil data mentah (saat ini dari data dummy lokal, nanti dari internet/backend). |
| **`data/services`** | **Koki Pengolah di Dapur** | Mesin yang mengolah dan menyaring data rumit (seperti fungsi pencarian kata kunci dan filter kategori). |
| **`core/`** | **Fasilitas Umum Restoran** | Hal-hal umum seperti tema dekorasi restoran, warna dinding, dan standar operasional bersama. |

---

## 🔄 Bagan Alur Kerja Data

Berikut adalah siklus bagaimana data mengalir dari layar sampai ke sumber data:

```text
[ Pengguna Menekan Tombol di HP ]
               │
               ▼
┌──────────────────────────────────────────────┐
│  Presentation Layer: Screen / Widget         │  (Contoh: Tombol "Pinjam Buku")
└──────────────────────┬───────────────────────┘
                       │ Memanggil fungsi
                       ▼
┌──────────────────────────────────────────────┐
│  Presentation Layer: Provider (State)        │  (Contoh: TransactionProvider)
└──────────────────────┬───────────────────────┘
                       │ Mengambil data / logika
                       ▼
┌──────────────────────────────────────────────┐
│  Data Layer: Repository & Service            │  (Contoh: BookRepository, FilterService)
└──────────────────────┬───────────────────────┘
                       │ Menggunakan format cetak biru
                       ▼
┌──────────────────────────────────────────────┐
│  Domain Layer: Model                         │  (Contoh: BookModel, TransactionModel)
└──────────────────────┬───────────────────────┘
                       │ Mengambil sumber fisik
                       ▼
┌──────────────────────────────────────────────┐
│  Sumber Data:                                │
│  • Sekarang: Data Dummy Lokal                │
│  • Nanti: REST API Backend (Express.js)       │
└──────────────────────────────────────────────┘
```

---

## 📂 Penjelasan Rinci Setiap Folder

### 1. Folder `core/` (Pondasi Universal)
Folder ini berisi komponen dan pengaturan yang digunakan **bersama oleh seluruh fitur** di aplikasi.
* **`core/constants/`**:
  * Berisi konstanta global, seperti warna aplikasi (`AppColors.primary`, `AppColors.background`).
* **`core/widgets/`**:
  * Komponen antarmuka universal, seperti `CustomButton` yang dipakai di Landing Page, Login, maupun Register.
* **`core/utils/`**:
  * Helper fungsi umum, seperti pemformat mata uang rupiah atau format tanggal.

---

### 2. Folder `features/<nama_fitur>/` (Struktur per Fitur)
Setiap modul fitur besar (seperti `auth`, `books`, `transactions`) memiliki ruang lingkupnya sendiri yang mandiri:

```text
features/books/
├── domain/
│   └── models/
├── data/
│   ├── repositories/
│   └── services/
└── presentation/
    ├── providers/
    ├── screens/
    └── widgets/
```

#### A. Lapisan `domain/` (Aturan & Cetak Biru Data Murni)
* **Tujuan:** Menjawab pertanyaan: *"Data ini bentuknya seperti apa?"*.
* **Folder `models/`:**
  * Berisi class model Dart murni.
  * **Contoh:** `BookModel` (`id`, `judul`, `penulis`, `kategori`, `lokasiKampus`, `isTersedia`).
  * Model memiliki fungsi `fromJson` (mengubah data JSON dari internet menjadi objek Dart) dan `toJson` (mengubah objek Dart menjadi JSON untuk dikirim ke backend).
* **Ciri Khas:** Lapisan ini murni dan netral. Ia tidak bergantung pada Flutter UI atau package eksternal.

#### B. Lapisan `data/` (Penyedia & Pengolah Data)
* **Tujuan:** Menjawab pertanyaan: *"Dari mana data diambil dan bagaimana cara mengolahnya?"*.
* **Folder `repositories/`:**
  * Bertugas sebagai satu-satunya pintu keluar-masuk data.
  * **Contoh:** `BookRepository.getInitialBooks()`.
  * Saat ini repository mengambil data dummy Andi. Ketika backend Express.js sudah jadi, hanya file repository ini yang diubah untuk memanggil HTTP API. Tampilan UI tidak perlu diubah.
* **Folder `services/`:**
  * Bertugas melakukan komputasi atau filter logika yang kompleks.
  * **Contoh:** `BookFilterService.cariDanFilter()` yang memfilter buku berdasarkan pencarian kata kunci huruf besar-kecil dan kategori.

#### C. Lapisan `presentation/` (Antarmuka & Pengatur Tampilan)
* **Tujuan:** Menjawab pertanyaan: *"Bagaimana data ditampilkan dan bagaimana pengguna berinteraksi?"*.
* **Folder `screens/`:**
  * Halaman penuh aplikasi (memiliki `Scaffold`, `AppBar`, dan struktur halaman lengkap).
  * **Contoh:** `LandingPage`, `RegisterPage`, `LoginPage`.
* **Folder `widgets/`:**
  * Bagian-bagian kecil dari layar yang bisa dipakai berulang kali (*reusable*).
  * **Contoh:** `CustomTextField` (kolom input dengan ikon dan tombol intip password).
* **Folder `providers/`:**
  * Pengatur *State Management* menggunakan class `ChangeNotifier`.
  * **Contoh:** `AuthProvider`, `BookProvider`, `TransactionProvider`.
  * Ketika status data berubah (misal status transaksi berubah dari `pending` ke `disetujui`), provider memanggil `notifyListeners()`. Semua widget yang mendengarkan provider tersebut akan otomatis memperbarui tampilannya secara instan.

---

## 🎯 4 Manfaat Utama Mengapa Kita Memakai Pola Ini

1. **Kode Tidak Bertabrakan (*Separation of Concerns*)**:
   * Jika ingin mengganti warna tombol atau mengubah font, kita cukup mengedit di folder `presentation`. Kode data di `data` dan `domain` tidak akan tersentuh atau rusak.
2. **Mudah Diuji (*Unit Testing Ready*)**:
   * Logika bisnis di `domain` dan `data` dapat kita uji 100% menggunakan script tes otomatis (`flutter test`) tanpa harus menjalankan emulator yang berat.
3. **Peralihan ke Backend Nyata Sangat Cepat**:
   * Karena UI kita hanya berbicara dengan `Provider` dan `Repository`, saat backend selesai, kita cukup mengganti isi repository dari dummy menjadi pemanggilan URL API (`http.get`).
4. **Kolaborasi Tim yang Rapi (ASE Lab)**:
   * **Mobile Dev (Gilang):** Mengatur `presentation` dan integrasi data.
   * **UI/UX (Wahyu):** Memberikan acuan visual untuk file di `screens` dan `widgets`.
   * **Backend Dev (Wifi):** Menyiapkan endpoint yang format JSON-nya disesuaikan dengan `domain/models`.
   * **Software QA (Syahdan):** Menjalankan pengujian di folder `test/`.

---

*Dokumen ini dapat digunakan sebagai referensi belajar mandiri maupun bahan presentasi saat evaluasi progres di lab.*
