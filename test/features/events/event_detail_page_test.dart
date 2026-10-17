import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/admin/presentation/widgets/admin_bottom_nav.dart';
import 'package:librava/features/auth/presentation/providers/auth_provider.dart';
import 'package:librava/features/events/domain/models/event_model.dart';
import 'package:librava/features/events/presentation/providers/event_provider.dart';
import 'package:librava/features/events/presentation/screens/event_detail_page.dart';
import 'package:provider/provider.dart';

void main() {
  final sampleEvent = EventModel(
    id: 99,
    judul: 'Book Exchange Day',
    deskripsi: 'Book Exchange Day is a campus event where you can meet other book lovers.',
    kategori: 'Komunitas',
    lokasi: 'Open Library Tel-U',
    tanggalMulai: DateTime(2026, 10, 12, 10, 0),
    tanggalSelesai: DateTime(2026, 10, 12, 16, 0),
    kuota: 100,
    fotoEvent: 'assets/images/event_library.jpg',
  );

  group('EventDetailPage Widget Tests', () {
    testWidgets('renders Event view in Admin mode with Approve and Reject buttons', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => EventProvider()),
          ],
          child: MaterialApp(
            home: EventDetailPage(
              event: sampleEvent,
              isAdmin: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Event view'), findsOneWidget);
      expect(find.text('Book Exchange Day'), findsOneWidget);
      expect(find.text('About this event'), findsOneWidget);
      expect(find.text('Open Library Tel-U'), findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
      expect(find.byType(AdminBottomNav), findsOneWidget);
    });

    testWidgets('renders Event view in Student mode with Join event button', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => EventProvider()),
          ],
          child: MaterialApp(
            home: EventDetailPage(
              event: sampleEvent,
              isAdmin: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Event view'), findsOneWidget);
      expect(find.text('Book Exchange Day'), findsOneWidget);
      expect(find.text('About this event'), findsOneWidget);
      expect(find.text('Join event'), findsOneWidget);
      expect(find.text('Approve'), findsNothing);
      expect(find.text('Reject'), findsNothing);
      expect(find.byType(AdminBottomNav), findsNothing);
    });

    testWidgets('tapping Approve button opens confirmation popup with Approve and Cancel', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => EventProvider()),
          ],
          child: MaterialApp(
            home: EventDetailPage(
              event: sampleEvent,
              isAdmin: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to make Approve visible and tap it
      await tester.ensureVisible(find.text('Approve'));
      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();

      // Pop up dialog is displayed
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.textContaining('Are you sure you want to approve'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap cancel to close dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('tapping Reject button opens confirmation popup with Reject and Cancel', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => EventProvider()),
          ],
          child: MaterialApp(
            home: EventDetailPage(
              event: sampleEvent,
              isAdmin: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Scroll to make Reject visible and tap it
      await tester.ensureVisible(find.text('Reject'));
      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      // Pop up dialog is displayed
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.textContaining('Are you sure you want to reject'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap cancel to close dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    });
  });
}
