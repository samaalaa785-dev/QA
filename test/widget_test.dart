import 'package:flutter_test/flutter_test.dart';

import 'package:salahny_fixed/main.dart';

void main() {
  testWidgets('Admin app starts at login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Super Admin Access'), findsOneWidget);
    expect(find.text('Access Admin Dashboard'), findsOneWidget);
  });
}
