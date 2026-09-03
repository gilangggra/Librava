import { Request } from 'express';

export interface UserPayload {
  id: number;
  email: string;
  role: string;
  nama_lengkap: string;
}

export interface AuthenticatedRequest extends Request {
  user?: UserPayload;
}

export interface User {
  id: number;
  email: string;
  password_hash?: string;
  nama_lengkap: string;
  nim?: string;
  universitas?: string;
  foto_profil?: string;
  role: 'mahasiswa' | 'admin';
  created_at: Date;
  updated_at: Date;
}

export interface Book {
  id: number;
  owner_id: number;
  judul: string;
  penulis: string;
  penerbit?: string;
  isbn?: string;
  deskripsi?: string;
  status: 'Tersedia' | 'Dipinjam' | 'Dibarter' | 'Tidak Tersedia';
  foto_buku?: string;
  kategori?: string;
  created_at: Date;
  updated_at: Date;
  owner_nama?: string;
  owner_universitas?: string;
  owner_foto?: string;
}

export type TransactionType = 'BORROW' | 'BARTER';
export type TransactionStatus = 
  | 'MENUNGGU_KONFIRMASI' 
  | 'DISETUJUI' 
  | 'DITOLAK' 
  | 'DALAM_PROSES' 
  | 'SELESAI' 
  | 'DIBATALKAN';

export interface Transaction {
  id: number;
  requester_id: number;
  owner_id: number;
  book_id: number;
  tipe_transaksi: TransactionType;
  barter_book_id?: number;
  status: TransactionStatus;
  deposit_dummy: number;
  lokasi_pertemuan?: string;
  waktu_pertemuan?: Date;
  created_at: Date;
  updated_at: Date;
  requester_nama?: string;
  requester_universitas?: string;
  owner_nama?: string;
  owner_universitas?: string;
  book_judul?: string;
  book_foto?: string;
  barter_book_judul?: string;
}

export interface Chat {
  id: number;
  transaction_id: number;
  sender_id: number;
  receiver_id: number;
  pesan: string;
  is_read: boolean;
  sent_at: Date;
  sender_nama?: string;
}

export interface Review {
  id: number;
  transaction_id: number;
  reviewer_id: number;
  reviewee_id: number;
  rating: number;
  komentar?: string;
  created_at: Date;
  reviewer_nama?: string;
}

export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  meta?: any;
  error?: any;
}
