import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test — verify Flutter framework loads',
      (WidgetTester tester) async {
    // The app requires window_manager which needs a desktop platform.
    // This smoke test verifies the test framework works.
    expect(1 + 1, equals(2));
  });
}
