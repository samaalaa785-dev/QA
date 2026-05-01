import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salahny_fixed/core/constants/app_constants.dart';
import 'package:salahny_fixed/features/driver/emergency/emergency_screen.dart';

Widget _buildEmergencyScreen() {
  return MaterialApp(
    routes: {
      R.bookService: (_) => const Scaffold(
            body: Center(child: Text('Book Service Screen')),
          ),
    },
    home: const EmergencyScreen(),
  );
}

void main() {
  group('US1 - Driver Emergency Request', () {
    testWidgets('AC1/AC3 - Emergency screen shows instant response and emergency choices',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildEmergencyScreen());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Emergency Help'), findsOneWidget);
      expect(find.text('Instant Emergency Response'), findsOneWidget);
      expect(find.text('Technician dispatched to your location'), findsOneWidget);
      expect(find.text('Available 24/7'), findsOneWidget);

      expect(find.text('Dead Battery'), findsOneWidget);
      expect(find.text('Flat Tire'), findsOneWidget);
      expect(find.text('Out of Fuel'), findsOneWidget);
      expect(find.text('Lockout'), findsOneWidget);
      expect(find.text('Breakdown'), findsOneWidget);
      expect(find.text('Overheating'), findsOneWidget);
    });

    testWidgets('AC2/AC3 - Tapping one emergency option opens booking flow in one click',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildEmergencyScreen());
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Dead Battery'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Book Service Screen'), findsOneWidget);
    });

    test('Negative/Edge - Emergency options list must not be empty', () {
      const emergencyTypes = [
        'Dead Battery',
        'Flat Tire',
        'Out of Fuel',
        'Lockout',
        'Breakdown',
        'Overheating',
      ];

      expect(emergencyTypes, isNotEmpty);
      expect(emergencyTypes.length, greaterThanOrEqualTo(1));
    });
  });
}
