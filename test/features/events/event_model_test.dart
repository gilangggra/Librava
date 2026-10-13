import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/events/domain/models/event_model.dart';

void main() {
  group('EventModel Unit Tests', () {
    test('EventModel.fromApiJson mem-parsing data API backend dengan benar', () {
      final json = {
        'id': 10,
        'judul': 'Bedah Buku Nasional 2026',
        'deskripsi': 'Diskusi buku sastra dan teknologi',
        'tanggal_mulai': '2026-11-20T09:00:00.000Z',
        'tanggal_selesai': '2026-11-20T12:00:00.000Z',
        'lokasi': 'Auditorium Kampus',
        'kapasitas': 100,
        'jumlah_pendaftar': 35,
        'foto_event': 'https://example.com/cover.jpg',
      };

      final event = EventModel.fromApiJson(json);

      expect(event.id, 10);
      expect(event.judul, 'Bedah Buku Nasional 2026');
      expect(event.deskripsi, 'Diskusi buku sastra dan teknologi');
      expect(event.lokasi, 'Auditorium Kampus');
      expect(event.kuota, 100);
      expect(event.jumlahPendaftar, 35);
      expect(event.sisaKuota, 65);
      expect(event.isPenuh, isFalse);
    });

    test('EventModel menghitung kuota penuh dan sisa kuota dengan akurat', () {
      final eventPenuh = EventModel(
        id: 1,
        judul: 'Workshop Flutter Pemula',
        deskripsi: 'Deskripsi singkat workshop',
        tanggalMulai: DateTime.now(),
        lokasi: 'Lab Komputer',
        kuota: 20,
        jumlahPendaftar: 20,
      );

      expect(eventPenuh.isPenuh, isTrue);
      expect(eventPenuh.sisaKuota, 0);

      final eventLebih = eventPenuh.copyWith(jumlahPendaftar: 25);
      expect(eventLebih.isPenuh, isTrue);
      expect(eventLebih.sisaKuota, 0); // Tidak boleh negatif
    });

    test('EventModel.copyWith memperbarui nilai dengan tepat', () {
      final eventAwal = EventModel(
        id: 2,
        judul: 'Seminar AI Librava',
        deskripsi: 'Deskripsi seminar',
        tanggalMulai: DateTime.now(),
        lokasi: 'Online Zoom',
        kuota: 50,
        jumlahPendaftar: 10,
      );

      final eventBaru = eventAwal.copyWith(
        jumlahPendaftar: 11,
      );

      expect(eventBaru.jumlahPendaftar, 11);
      expect(eventBaru.sisaKuota, 39);
      expect(eventBaru.judul, 'Seminar AI Librava');
    });
  });
}
