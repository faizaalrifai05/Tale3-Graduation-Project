import 'package:flutter_test/flutter_test.dart';
import 'package:testtale3/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const Tale3App());

    // Verify that the splash screen shows Tale3 branding
    expect(find.text('Tale3'), findsOneWidget);
  });
}
