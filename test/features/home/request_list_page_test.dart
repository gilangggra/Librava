import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/home/domain/models/book_request_item.dart';
import 'package:librava/features/home/presentation/screens/request_detail_page.dart';
import 'package:librava/features/home/presentation/screens/request_list_page.dart';

void main() {
  Widget createWidgetUnderTest(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  List<BookRequestItem> getSampleRequests() => [
        BookRequestItem(
          id: '1',
          bookTitle: 'The Unknown',
          bookAuthor: 'Riley Sager',
          bookCover: 'assets/images/book_the_unknown.jpg',
          requesterName: 'Andi',
          requesterHandle: '@andi_telu',
          requesterAvatar: 'assets/images/profile_placeholder.png',
          type: 'Barter',
          exchangeBookTitle: 'Fruit Fly',
          exchangeBookAuthor: 'Josh Silver',
          exchangeBookCover: 'assets/images/book_the_unknown.jpg',
          requestedPeriod: '14 Days (12 - 26 Sep 2026)',
          status: 'Pending',
        ),
        BookRequestItem(
          id: '2',
          bookTitle: 'Adversary to the Villain',
          bookAuthor: 'Veronica Roth',
          bookCover: 'assets/images/book_the_unknown.jpg',
          requesterName: 'Sarah',
          requesterHandle: '@sarah_reader',
          requesterAvatar: 'assets/images/profile_placeholder.png',
          type: 'Pinjam',
          requestedPeriod: '7 Days (15 - 22 Sep 2026)',
          status: 'Pending',
        ),
      ];

  testWidgets('RequestListPage menampilkan empty state saat tidak ada request',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const RequestListPage(initialRequests: [])));
    await tester.pumpAndSettle();

    expect(find.text('Request list'), findsOneWidget);
    expect(find.text('No Incoming Requests Yet'), findsOneWidget);
  });

  testWidgets('RequestListPage merender judul dan daftar request dengan benar',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(RequestListPage(initialRequests: getSampleRequests())));
    await tester.pumpAndSettle();

    expect(find.text('Request list'), findsOneWidget);
    expect(find.text('The Unknown'), findsWidgets);
    expect(find.text('Adversary to the Villain'), findsOneWidget);
    expect(find.text('Offers to exchange with:'), findsWidgets);
    expect(find.text('Requested period:'), findsOneWidget);
    expect(find.text('Accept'), findsWidgets);
    expect(find.text('Decline'), findsWidgets);
  });

  testWidgets(
      'Menekan tombol Accept di RequestListPage memunculkan dialog konfirmasi',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(RequestListPage(initialRequests: getSampleRequests())));
    await tester.pumpAndSettle();

    final acceptBtn = find.widgetWithText(ElevatedButton, 'Accept').first;
    await tester.tap(acceptBtn);
    await tester.pumpAndSettle();

    expect(
      find.text('Are you sure you want to accept\nthis request from Andi?'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);

    // Tekan Accept di dalam dialog untuk konfirmasi
    final dialogAcceptBtn =
        find.widgetWithText(ElevatedButton, 'Accept').last;
    await tester.tap(dialogAcceptBtn);
    await tester.pumpAndSettle();

    expect(find.text('Request from Andi accepted!'), findsOneWidget);
  });

  testWidgets(
      'Mengetuk sub-card request membuka halaman RequestDetailPage',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(RequestListPage(initialRequests: getSampleRequests())));
    await tester.pumpAndSettle();

    final offerCard = find.text('Offers to exchange with:').first;
    await tester.tap(offerCard);
    await tester.pumpAndSettle();

    expect(find.byType(RequestDetailPage), findsOneWidget);
    expect(find.text('Waiting for your response'), findsOneWidget);
    expect(find.text('Request Info'), findsOneWidget);
    expect(find.text('Requester information'), findsOneWidget);
  });

  testWidgets(
      'RequestDetailPage menampilkan elemen detail dan pop up konfirmasi Accept',
      (WidgetTester tester) async {
    final item = BookRequestItem(
      id: 'test_1',
      bookTitle: 'The Unknown',
      bookAuthor: 'Riley Sager',
      bookCover: 'assets/images/book_the_unknown.jpg',
      requesterName: 'Andi',
      requesterHandle: '@andireads',
      type: 'Barter',
      status: 'Pending',
      exchangeBookTitle: 'Fruit Fly',
      exchangeBookAuthor: 'Josh Silver',
      exchangeBookCover: 'assets/images/book_fruit_fly.jpg',
      requestedPeriod: '2 weeks',
      requestedOn: 'Aug 21, 2026',
    );

    await tester.pumpWidget(createWidgetUnderTest(RequestDetailPage(item: item)));
    await tester.pumpAndSettle();

    expect(find.text('The Unknown'), findsOneWidget);
    expect(find.text('Riley Sager'), findsOneWidget);
    expect(find.text('Waiting for your response'), findsOneWidget);
    expect(find.text('Request Info'), findsOneWidget);
    expect(find.text('Requester information'), findsOneWidget);
    expect(find.text('View profile'), findsOneWidget);

    // Tekan Accept setelah scroll ke tombol
    final acceptBtn = find.widgetWithText(ElevatedButton, 'Accept');
    await tester.ensureVisible(acceptBtn);
    await tester.pumpAndSettle();
    await tester.tap(acceptBtn);
    await tester.pumpAndSettle();

    expect(
      find.text('Are you sure you want to accept\nthis request from Andi?'),
      findsOneWidget,
    );

    // Batalkan
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel'), findsNothing);
  });
}
