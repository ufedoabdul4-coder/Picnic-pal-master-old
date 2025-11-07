import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('App starts without error', (WidgetTester tester) async {
    // Build our app
   await tester.pumpWidget(const MyApp());

    // Verify that the splash screen or HomeScreen title is shown
    expect(find.text('PicnicPal'), findsOneWidget);

    // Pump for a few seconds to let any timers run safely
    await tester.pump(const Duration(seconds: 5)); // ensures timers fire without crashing
  });
}
