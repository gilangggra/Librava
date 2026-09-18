import { Pool, Client, QueryResult, QueryResultRow } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const dbHost = process.env.DB_HOST || 'localhost';
const dbPort = parseInt(process.env.DB_PORT || '5432', 10);
const dbUser = process.env.DB_USER || 'postgres';
const dbPassword = process.env.DB_PASSWORD || 'postgres';
const dbName = process.env.DB_NAME || 'librava_db';

export const ensureDatabaseExists = async (): Promise<void> => {
  const maintenanceClient = new Client({
    host: dbHost,
    port: dbPort,
    user: dbUser,
    password: dbPassword,
    database: 'postgres',
  });

  try {
    await maintenanceClient.connect();
    const checkDb = await maintenanceClient.query(
      `SELECT 1 FROM pg_database WHERE datname = $1`,
      [dbName]
    );

    if (checkDb.rows.length === 0) {
      await maintenanceClient.query(`CREATE DATABASE "${dbName}"`);
      console.log(`Database "${dbName}" created.`);
    }
  } catch (err: any) {
    console.warn(`Database check notice: ${err.message}`);
  } finally {
    await maintenanceClient.end().catch(() => {});
  }
};

const pool = new Pool({
  host: dbHost,
  port: dbPort,
  user: dbUser,
  password: dbPassword,
  database: dbName,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

export const query = async <T extends QueryResultRow = any>(
  text: string,
  params?: any[]
): Promise<QueryResult<T>> => {
  const start = Date.now();
  const res = await pool.query<T>(text, params);
  const duration = Date.now() - start;
  if (process.env.NODE_ENV === 'development') {
    console.log(`[SQL Query] (${duration}ms) ${text.slice(0, 80).replace(/\s+/g, ' ')}...`);
  }
  return res;
};

export const initDb = async (): Promise<void> => {
  const schemaSql = `
    CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        nama_lengkap VARCHAR(255) NOT NULL,
        nim VARCHAR(50),
        universitas VARCHAR(100) DEFAULT 'Telkom University',
        foto_profil TEXT,
        role VARCHAR(20) DEFAULT 'mahasiswa',
        saldo_dummy NUMERIC(12, 2) DEFAULT 100000,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    ALTER TABLE users ADD COLUMN IF NOT EXISTS saldo_dummy NUMERIC(12, 2) DEFAULT 100000;

    CREATE TABLE IF NOT EXISTS books (
        id SERIAL PRIMARY KEY,
        owner_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        judul VARCHAR(255) NOT NULL,
        penulis VARCHAR(255) NOT NULL,
        penerbit VARCHAR(255),
        isbn VARCHAR(50),
        deskripsi TEXT,
        status VARCHAR(50) DEFAULT 'Tersedia',
        foto_buku TEXT,
        kategori VARCHAR(100),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS transactions (
        id SERIAL PRIMARY KEY,
        requester_id INT NOT NULL REFERENCES users(id),
        owner_id INT NOT NULL REFERENCES users(id),
        book_id INT NOT NULL REFERENCES books(id),
        tipe_transaksi VARCHAR(20) NOT NULL,
        barter_book_id INT REFERENCES books(id),
        status VARCHAR(50) DEFAULT 'MENUNGGU_KONFIRMASI',
        deposit_dummy NUMERIC(12, 2) DEFAULT 0,
        durasi_hari INT DEFAULT 7,
        due_date TIMESTAMP,
        returned_at TIMESTAMP,
        lokasi_pertemuan TEXT,
        waktu_pertemuan TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    ALTER TABLE transactions ADD COLUMN IF NOT EXISTS durasi_hari INT DEFAULT 7;
    ALTER TABLE transactions ADD COLUMN IF NOT EXISTS due_date TIMESTAMP;
    ALTER TABLE transactions ADD COLUMN IF NOT EXISTS returned_at TIMESTAMP;

    CREATE TABLE IF NOT EXISTS chats (
        id SERIAL PRIMARY KEY,
        transaction_id INT REFERENCES transactions(id) ON DELETE CASCADE,
        sender_id INT NOT NULL REFERENCES users(id),
        receiver_id INT NOT NULL REFERENCES users(id),
        pesan TEXT NOT NULL,
        is_read BOOLEAN DEFAULT FALSE,
        sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS reviews (
        id SERIAL PRIMARY KEY,
        transaction_id INT REFERENCES transactions(id) ON DELETE CASCADE,
        reviewer_id INT NOT NULL REFERENCES users(id),
        reviewee_id INT NOT NULL REFERENCES users(id),
        rating INT CHECK (rating >= 1 AND rating <= 5),
        komentar TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;

  try {
    await pool.query(schemaSql);
    console.log('PostgreSQL schema initialized.');
  } catch (err: any) {
    console.error('Error initializing schema:', err.message);
  }
};

export default pool;
