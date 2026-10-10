import prisma from '../config/prisma';
import { sanitizeText } from '../utils/sanitize';

export interface EventDTO {
  judul: string;
  deskripsi: string;
  kategori?: string | null;
  lokasi: string;
  tanggal_mulai: Date;
  tanggal_selesai?: Date | null;
  kuota?: number;
  foto_event?: string | null;
}

const mapEvent = (event: any) => ({
  id: event.id,
  judul: event.judul,
  deskripsi: event.deskripsi,
  kategori: event.kategori,
  lokasi: event.lokasi,
  tanggal_mulai: event.tanggalMulai,
  tanggal_selesai: event.tanggalSelesai,
  kuota: event.kuota,
  foto_event: event.fotoEvent,
  created_by_id: event.createdById,
  created_at: event.createdAt,
  updated_at: event.updatedAt,
  jumlah_pendaftar: event._count?.registrations ?? undefined,
});

const notFound = () => {
  const error: any = new Error('Event tidak ditemukan.');
  error.statusCode = 404;
  return error;
};

export class EventService {
  static async list(params: { search?: string; kategori?: string; mulai_dari?: Date; sampai_dengan?: Date }) {
    const where: any = {
      OR: [
        { tanggalSelesai: null },
        { tanggalSelesai: { gte: new Date() } },
      ],
    };
    if (params.search) {
      where.AND = [{ OR: [
        { judul: { contains: params.search, mode: 'insensitive' } },
        { deskripsi: { contains: params.search, mode: 'insensitive' } },
      ] }];
    }
    if (params.kategori) where.kategori = { equals: params.kategori, mode: 'insensitive' };
    if (params.mulai_dari || params.sampai_dengan) {
      where.tanggalMulai = {};
      if (params.mulai_dari) where.tanggalMulai.gte = params.mulai_dari;
      if (params.sampai_dengan) where.tanggalMulai.lte = params.sampai_dengan;
    }

    const events = await prisma.event.findMany({
      where,
      include: { _count: { select: { registrations: true } } },
      orderBy: { tanggalMulai: 'asc' },
    });
    return events.map(mapEvent);
  }

  static async getById(id: number) {
    const event = await prisma.event.findUnique({
      where: { id },
      include: { _count: { select: { registrations: true } } },
    });
    if (!event) throw notFound();
    return mapEvent(event);
  }

  static async create(createdById: number, dto: EventDTO) {
    const event = await prisma.event.create({
      data: {
        createdById,
        judul: sanitizeText(dto.judul) || dto.judul,
        deskripsi: sanitizeText(dto.deskripsi) || dto.deskripsi,
        kategori: dto.kategori || null,
        lokasi: sanitizeText(dto.lokasi) || dto.lokasi,
        tanggalMulai: dto.tanggal_mulai,
        tanggalSelesai: dto.tanggal_selesai || null,
        kuota: dto.kuota ?? 100,
        fotoEvent: dto.foto_event || null,
      },
    });
    return mapEvent(event);
  }

  static async update(id: number, dto: Partial<EventDTO>) {
    await this.getById(id);
    const data: any = {};
    if (dto.judul !== undefined) data.judul = sanitizeText(dto.judul) || dto.judul;
    if (dto.deskripsi !== undefined) data.deskripsi = sanitizeText(dto.deskripsi) || dto.deskripsi;
    if (dto.kategori !== undefined) data.kategori = dto.kategori;
    if (dto.lokasi !== undefined) data.lokasi = sanitizeText(dto.lokasi) || dto.lokasi;
    if (dto.tanggal_mulai !== undefined) data.tanggalMulai = dto.tanggal_mulai;
    if (dto.tanggal_selesai !== undefined) data.tanggalSelesai = dto.tanggal_selesai;
    if (dto.kuota !== undefined) data.kuota = dto.kuota;
    if (dto.foto_event !== undefined) data.fotoEvent = dto.foto_event;

    const event = await prisma.event.update({ where: { id }, data });
    return mapEvent(event);
  }

  static async remove(id: number) {
    await this.getById(id);
    await prisma.event.delete({ where: { id } });
  }

  static async register(eventId: number, userId: number) {
    try {
      return await prisma.$transaction(async (tx) => {
        const event = await tx.event.findUnique({ where: { id: eventId } });
        if (!event) throw notFound();
        if (event.tanggalSelesai && event.tanggalSelesai < new Date()) {
          const error: any = new Error('Pendaftaran event sudah ditutup.');
          error.statusCode = 400;
          throw error;
        }

        const total = await tx.eventRegistration.count({ where: { eventId } });
        if (total >= event.kuota) {
          const error: any = new Error('Kuota event sudah penuh.');
          error.statusCode = 409;
          throw error;
        }

        const registration = await tx.eventRegistration.create({ data: { eventId, userId } });
        return { id: registration.id, event_id: eventId, user_id: userId, registered_at: registration.registeredAt };
      }, { isolationLevel: 'Serializable' });
    } catch (error: any) {
      if (error.code === 'P2002') {
        error.statusCode = 409;
        error.message = 'Anda sudah terdaftar pada event ini.';
      }
      throw error;
    }
  }
}
