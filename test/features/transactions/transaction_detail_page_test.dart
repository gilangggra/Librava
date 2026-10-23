import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/transactions/presentation/screens/transaction_detail_page.dart';

void main() {
  testWidgets('TransactionDetailPage menampilkan semua informasi transaksi sesuai mockup',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TransactionDetailPage(
          bookTitle: 'The Unknown',
          bookAuthor: 'Riley Sager',
          status: 'Waiting for owner’s response',
          requestedDate: 'Aug 21, 2026',
          preferredPeriod: '2 weeks',
          depositAmount: '50.000 Rupiah',
          handoverLocation: 'Set handover',
          ownerName: 'Andi',
          ownerUsername: '@andireads',
        ),
      ),
    );

    expect(find.text('The Unknown'), findsOneWidget);
    expect(find.text('Riley Sager'), findsOneWidget);

    expect(find.text('Waiting for owner’s response'), findsOneWidget);
    expect(
      find.text('Your request has been sent. Please wait for a response from the owner'),
      findsOneWidget,
    );

    expect(find.text('Transaction Info'), findsOneWidget);
    expect(find.text('Type'), findsOneWidget);
    expect(find.text('Borrow'), findsOneWidget);
    expect(find.text('Requested on'), findsOneWidget);
    expect(find.text('Aug 21, 2026'), findsOneWidget);
    expect(find.text('Preferred period'), findsOneWidget);
    expect(find.text('2 weeks'), findsOneWidget);
    expect(find.text('Deposit'), findsOneWidget);
    expect(find.text('50.000 Rupiah'), findsOneWidget);
    expect(find.text('Handover'), findsOneWidget);
    expect(find.text('Set handover'), findsOneWidget);

    expect(find.text('Handover confirmation'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(
      find.text('Transaction will complete after both parties confirm'),
      findsOneWidget,
    );

    expect(find.text('Owner information'), findsOneWidget);
    expect(find.text('Andi'), findsOneWidget);
    expect(find.text('@andireads'), findsOneWidget);
    expect(find.text('View profile'), findsOneWidget);

    expect(find.text('Message Owner'), findsOneWidget);
    expect(find.text('Cancel Request'), findsOneWidget);
  });

  testWidgets('Menekan baris deposit membuka modal pembayaran dan dapat diselesaikan',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TransactionDetailPage(
          depositAmount: '50.000 Rupiah',
        ),
      ),
    );

    await tester.tap(find.text('Deposit'));
    await tester.pumpAndSettle();

    expect(find.text('Complete your deposit'), findsOneWidget);
    expect(
      find.text('Scan this QR code below to complete your deposit for this transaction'),
      findsOneWidget,
    );
    expect(find.text('Deposit amount'), findsOneWidget);
    expect(find.text('RP 50.000'), findsOneWidget);
    expect(
      find.text('The deposit will be held securely and will be refunded after the book is returned'),
      findsOneWidget,
    );
    expect(find.text("I've made the payment"), findsOneWidget);

    await tester.ensureVisible(find.text("I've made the payment"));
    await tester.tap(find.text("I've made the payment"));
    await tester.pumpAndSettle();

    expect(find.text('Payment successful! Deposit is now secured.'), findsOneWidget);
  });

  testWidgets('Menekan baris handover membuka modal Set handover dan dapat diselesaikan',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TransactionDetailPage(
          handoverLocation: 'Set handover',
        ),
      ),
    );

    await tester.ensureVisible(find.text('Set handover'));
    await tester.tap(find.text('Set handover'));
    await tester.pumpAndSettle();

    expect(find.text('Set handover'), findsWidgets);
    expect(
      find.text('Choose the date, time, and location for the book handover'),
      findsOneWidget,
    );
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(
      find.text(
        'Please make sure the details are correct. You and the book owner will meet at the selected location on the choosen date and time',
      ),
      findsOneWidget,
    );

    final actionButton = find.widgetWithText(ElevatedButton, 'Set Handover');
    await tester.ensureVisible(actionButton);
    await tester.tap(actionButton);
    await tester.pumpAndSettle();

    expect(find.text('Handover set to Open Library Telkom University'), findsOneWidget);
  });

  testWidgets('Menekan tombol Cancel Request memunculkan dialog konfirmasi',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TransactionDetailPage(),
      ),
    );

    await tester.ensureVisible(find.text('Cancel Request'));
    await tester.tap(find.text('Cancel Request'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel Request?'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Yes, Cancel'), findsOneWidget);
  });

  testWidgets('Menekan tombol View profile membuka halaman Profile view dengan data pemilik',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TransactionDetailPage(
          ownerName: 'Andi',
          ownerUsername: '@andireads',
        ),
      ),
    );

    await tester.ensureVisible(find.text('View profile'));
    await tester.tap(find.text('View profile'));
    await tester.pumpAndSettle();

    expect(find.text('Profile view'), findsOneWidget);
    expect(find.text('User'), findsOneWidget);
    expect(find.text('A casual reader'), findsOneWidget);
    expect(find.text('Andi'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Books Read'), findsOneWidget);
    expect(find.text('Books Borrowed'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
  });

  testWidgets('Menekan tombol Konfirmasi Serah Terima memunculkan dialog konfirmasi dan mengubah status',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TransactionDetailPage(
          bookTitle: 'The Unknown',
          youConfirmed: false,
          ownerConfirmed: false,
          handoverLocation: 'Open Library Telkom University',
        ),
      ),
    );

    expect(find.text('Confirm Handover'), findsOneWidget);

    await tester.ensureVisible(find.text('Confirm Handover'));
    await tester.tap(find.text('Confirm Handover'));
    await tester.pumpAndSettle();

    expect(find.text('Have you handed over or received "The Unknown" at Open Library Telkom University?'), findsOneWidget);
    expect(find.text('Yes, Confirm'), findsOneWidget);

    await tester.tap(find.text('Yes, Confirm'));
    await tester.pumpAndSettle();

    expect(find.text('Your handover confirmation has been recorded.'), findsOneWidget);
  });

  testWidgets('Yang meminjamkan (isOwner: true) menekan baris deposit hanya membuka modal cek status deposit dan TIDAK menampilkan modal isi deposit',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TransactionDetailPage(
          isOwner: true,
          depositAmount: '20.000 Rupiah',
          isDepositPaid: false,
          ownerName: 'Gilang Ramadan',
        ),
      ),
    );

    await tester.tap(find.text('Deposit'));
    await tester.pumpAndSettle();

    // Memastikan modal cek status deposit pemilik yang muncul
    expect(find.text('Status Deposit Peminjam'), findsOneWidget);
    expect(find.text('Peminjam belum membayar deposit'), findsOneWidget);
    expect(find.text('Belum Dibayar'), findsOneWidget);
    expect(find.text('Tutup'), findsOneWidget);

    // Memastikan modal isi deposit (QR & Virtual Account) SAMA SEKALI TIDAK MUNCUL
    expect(find.text('Complete your deposit'), findsNothing);
    expect(find.text("I've made the payment"), findsNothing);

    // Menekan tombol Tutup menutup dialog
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.text('Status Deposit Peminjam'), findsNothing);
  });

  testWidgets('Yang meminjamkan (isOwner: true) menekan baris handover hanya membuka modal cek status handover dan TIDAK menampilkan modal isi Set Handover',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TransactionDetailPage(
          isOwner: true,
          handoverLocation: 'Tentukan lokasi',
          ownerName: 'Gilang Ramadan',
        ),
      ),
    );

    // Untuk pemilik, teks belum ditentukan ditampilkan
    expect(find.text('Belum ditentukan'), findsOneWidget);

    await tester.ensureVisible(find.text('Belum ditentukan'));
    await tester.tap(find.text('Belum ditentukan'));
    await tester.pumpAndSettle();

    // Memastikan modal cek status serah terima pemilik yang muncul
    expect(find.text('Status Serah Terima Buku'), findsOneWidget);
    expect(find.text('Peminjam belum menentukan lokasi'), findsOneWidget);
    expect(find.text('Belum Ditentukan'), findsOneWidget);
    expect(find.text('Tutup'), findsOneWidget);

    // Memastikan modal form isi handover SAMA SEKALI TIDAK MUNCUL
    expect(find.text('Set handover'), findsNothing);
    expect(find.text('Choose the date, time, and location for the book handover'), findsNothing);

    // Menekan tombol Tutup menutup dialog
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.text('Status Serah Terima Buku'), findsNothing);
  });
}

