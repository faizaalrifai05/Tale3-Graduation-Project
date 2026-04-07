import 'package:flutter_test/flutter_test.dart';
import 'package:testtale3/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const Tale3App());

    // Verify that the splash screen shows Tale3 branding
    expect(find.text('Tale3'), findsOneWidget);

    // Pump remaining timers and animations to avoid pending timer errors.
    // SplashScreen has a 4-second delayed navigation timer.
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
