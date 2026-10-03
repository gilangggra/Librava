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
    expect(find.widgetWithText(ElevatedButton, "I've made the payment"), findsOneWidget);

    final actionButton = find.widgetWithText(ElevatedButton, "I've made the payment");
    await tester.ensureVisible(actionButton);
    await tester.tap(actionButton);
    await tester.pumpAndSettle();

    expect(confirmedLocation, 'Open Library Telkom University');
  });
}
