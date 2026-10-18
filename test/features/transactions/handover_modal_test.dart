import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librava/features/transactions/presentation/screens/handover_modal.dart';

void main() {
  testWidgets('SetHandoverPage menampilkan semua elemen form handover dengan benar',
      (WidgetTester tester) async {
    String? confirmedLocation;

    await tester.pumpWidget(
      MaterialApp(
        home: SetHandoverPage(
          onHandoverConfirmed: (loc) {
            confirmedLocation = loc;
          },
        ),
      ),
    );

    expect(find.text('Set handover'), findsOneWidget);
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
    expect(find.widgetWithText(ElevatedButton, 'Set Handover'), findsOneWidget);

    expect(find.text('Aug 23, 2026'), findsOneWidget);
    expect(find.text('14:00 WIB'), findsOneWidget);

    // Buka DatePicker dengan mengetuk input tanggal
    await tester.tap(find.text('Aug 23, 2026'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Buka TimePicker dengan mengetuk input waktu
    await tester.tap(find.text('14:00 WIB'));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final actionButton = find.widgetWithText(ElevatedButton, 'Set Handover');
    await tester.ensureVisible(actionButton);
    await tester.tap(actionButton);
    await tester.pumpAndSettle();

    expect(confirmedLocation, 'Open Library Telkom University');
  });
}
