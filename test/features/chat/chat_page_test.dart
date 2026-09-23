import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/chat/presentation/screens/chat_page.dart';

void main() {
  testWidgets('ChatPage dapat dimuat dan merender daftar obrolan',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChatPage(),
      ),
    );

    expect(find.text('Chats'), findsOneWidget);
    expect(find.text('Search message'), findsOneWidget);
    expect(find.text('User Test'), findsWidgets);
    expect(find.text('Halo bang'), findsWidgets);
    expect(find.text('08/21'), findsWidgets);
  });

  testWidgets('Pencarian pesan di ChatPage memfilter daftar chat',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChatPage(),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Tidak ada');
    await tester.pump();

    expect(find.text('User Test'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    expect(find.text('User Test'), findsWidgets);
  });

  testWidgets('Mengetuk salah satu chat membuka ruang percakapan ChatRoomPage',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ChatPage(),
      ),
    );

    await tester.tap(find.text('User Test').first);
    await tester.pumpAndSettle();

    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Mau nanya'), findsOneWidget);
    expect(find.text('Iya kenapa?'), findsOneWidget);
    expect(find.text('Tulis pesan...'), findsOneWidget);
  });
}
