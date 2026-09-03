import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import prisma from '../config/prisma';
import { UserPayload } from '../types';

export interface RegisterDTO {
  email: string;
  password: string;
  nama_lengkap: string;
  nim?: string;
  universitas?: string;
  foto_profil?: string;
  role?: 'mahasiswa' | 'admin';
}

export interface LoginDTO {
  email: string;
  password: string;
}

export class AuthService {
  static async register(dto: RegisterDTO) {
    const existingUser = await prisma.user.findFirst({
      where: {
        email: {
          equals: dto.email,
          mode: 'insensitive',
        },
      },
    });

    if (existingUser) {
      const error: any = new Error('Email sudah terdaftar. Silakan gunakan email lain.');
      error.statusCode = 400;
      throw error;
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(dto.password, salt);

    const user = await prisma.user.create({
      data: {
        email: dto.email.toLowerCase(),
        passwordHash,
        namaLengkap: dto.nama_lengkap,
        nim: dto.nim || null,
        universitas: dto.universitas || 'Telkom University',
        fotoProfil: dto.foto_profil || null,
        role: 'mahasiswa',
      },
    });

    const token = this.generateToken({
      id: user.id,
      email: user.email,
      role: user.role,
      nama_lengkap: user.namaLengkap,
    });

    return {
      user: {
        id: user.id,
        email: user.email,
        nama_lengkap: user.namaLengkap,
        nim: user.nim,
        universitas: user.universitas,
        foto_profil: user.fotoProfil,
        role: user.role,
        created_at: user.createdAt,
      },
      token,
    };
  }

  static async login(dto: LoginDTO) {
    const user = await prisma.user.findFirst({
      where: {
        email: {
          equals: dto.email,
          mode: 'insensitive',
        },
      },
    });

    if (!user) {
      const error: any = new Error('Email atau password salah.');
      error.statusCode = 401;
      throw error;
    }

    const isMatch = await bcrypt.compare(dto.password, user.passwordHash || '');
    if (!isMatch) {
      const error: any = new Error('Email atau password salah.');
      error.statusCode = 401;
      throw error;
    }

    const token = this.generateToken({
      id: user.id,
      email: user.email,
      role: user.role,
      nama_lengkap: user.namaLengkap,
    });

    return {
      user: {
        id: user.id,
        email: user.email,
        nama_lengkap: user.namaLengkap,
        nim: user.nim,
        universitas: user.universitas,
        foto_profil: user.fotoProfil,
        role: user.role,
        created_at: user.createdAt,
        updated_at: user.updatedAt,
      },
      token,
    };
  }

  static async getProfile(userId: number) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      const error: any = new Error('Pengguna tidak ditemukan.');
      error.statusCode = 404;
      throw error;
    }

    return {
      id: user.id,
      email: user.email,
      nama_lengkap: user.namaLengkap,
      nim: user.nim,
      universitas: user.universitas,
      foto_profil: user.fotoProfil,
      role: user.role,
      created_at: user.createdAt,
      updated_at: user.updatedAt,
    };
  }

  static async updateProfile(userId: number, updateData: Partial<RegisterDTO>) {
    const data: any = {};
    if (updateData.nama_lengkap !== undefined) data.namaLengkap = updateData.nama_lengkap;
    if (updateData.nim !== undefined) data.nim = updateData.nim;
    if (updateData.universitas !== undefined) data.universitas = updateData.universitas;
    if (updateData.foto_profil !== undefined) data.fotoProfil = updateData.foto_profil;

    if (Object.keys(data).length === 0) {
      return this.getProfile(userId);
    }

    const user = await prisma.user.update({
      where: { id: userId },
      data,
    });

    return {
      id: user.id,
      email: user.email,
      nama_lengkap: user.namaLengkap,
      nim: user.nim,
      universitas: user.universitas,
      foto_profil: user.fotoProfil,
      role: user.role,
      created_at: user.createdAt,
      updated_at: user.updatedAt,
    };
  }

  private static generateToken(payload: UserPayload): string {
    const secret = process.env.JWT_SECRET || 'librava_secret_jwt_key_2026_super_secure';
    const expiresIn = (process.env.JWT_EXPIRES_IN || '7d') as jwt.SignOptions['expiresIn'];
    return jwt.sign(payload, secret, { expiresIn });
  }
}
