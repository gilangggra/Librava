import { Request, Response, NextFunction } from 'express';
import { AuthenticatedRequest } from '../types';
import { EventService } from '../services/event.service';

export class EventController {
  static async list(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const events = await EventService.list(req.query as any);
      res.json({ success: true, message: 'Berhasil mengambil daftar event.', data: events });
    } catch (error) { next(error); }
  }

  static async getById(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const event = await EventService.getById(Number(req.params.id));
      res.json({ success: true, message: 'Berhasil mengambil detail event.', data: event });
    } catch (error) { next(error); }
  }

  static async create(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const event = await EventService.create(req.user!.id, req.body);
      res.status(201).json({ success: true, message: 'Event berhasil dibuat.', data: event });
    } catch (error) { next(error); }
  }

  static async update(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const event = await EventService.update(Number(req.params.id), req.body);
      res.json({ success: true, message: 'Event berhasil diperbarui.', data: event });
    } catch (error) { next(error); }
  }

  static async remove(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      await EventService.remove(Number(req.params.id));
      res.json({ success: true, message: 'Event berhasil dihapus.' });
    } catch (error) { next(error); }
  }

  static async register(req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> {
    try {
      const registration = await EventService.register(Number(req.params.id), req.user!.id);
      res.status(201).json({ success: true, message: 'Berhasil mendaftar event.', data: registration });
    } catch (error) { next(error); }
  }
}
