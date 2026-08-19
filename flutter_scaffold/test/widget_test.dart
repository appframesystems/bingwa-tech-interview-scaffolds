import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_scaffold/main.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our welcome screen is displayed.
    expect(find.text('Welcome to the Flutter Scaffold!'), findsOneWidget);
  });
}
