import 'package:flutter_test/flutter_test.dart';

import 'package:salahny_fixed/main.dart';

void main() {
  testWidgets('App starts with splash then opens role selection', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Salahny'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 750));
    await tester.pumpAndSettle();

    expect(find.text('Choose Role'), findsOneWidget);
    expect(find.text('Driver'), findsOneWidget);
    expect(find.text('Workshop'), findsOneWidget);
    expect(find.text('AI Diagnostics'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });
}
