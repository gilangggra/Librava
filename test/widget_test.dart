import 'package:flutter_test/flutter_test.dart';
import 'package:librava/main.dart';

void main() {
  testWidgets('Aplikasi Librava dapat dimuat dengan baik ke Landing Page',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
