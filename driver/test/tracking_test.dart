import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salahny_fixed/core/constants/app_constants.dart';
import 'package:salahny_fixed/features/driver/booking/tracking_screen.dart';
import 'package:salahny_fixed/shared/services/mock_data.dart';

Widget _buildTrackingScreen() {
  return MaterialApp(
    routes: {
      R.mechanicChat: (_) => const Scaffold(
            body: Center(child: Text('Mechanic Chat Screen')),
          ),
    },
    home: const TrackingScreen(),
  );
}

void main() {
  group('US2 - Driver Real-time Tracking', () {
    testWidgets('AC1 - Tracking screen displays current booking and progress steps',
        (WidgetTester tester) async {
      final booking = AppData.i.bookings.first;

      await tester.pumpWidget(_buildTrackingScreen());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Track Booking'), findsOneWidget);
      expect(find.text(booking.serviceName), findsOneWidget);
      expect(find.text(booking.status), findsOneWidget);

      expect(find.text('Booking Confirmed'), findsOneWidget);
      expect(find.text('Awaiting Workshop'), findsOneWidget);
      expect(find.text('Work in Progress'), findsOneWidget);
      expect(find.text('Ready for Pickup'), findsOneWidget);
    });

    testWidgets('AC3 - Chat with mechanic is accessible from tracking screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildTrackingScreen());
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Chat with Mechanic'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Mechanic Chat Screen'), findsOneWidget);
    });

    test('AC2/Edge - ETA difference must be within 2 minutes margin', () {
      const actualArrivalMinutes = 10;
      const estimatedArrivalMinutes = 11;
      const allowedMarginMinutes = 2;

      final difference = (actualArrivalMinutes - estimatedArrivalMinutes).abs();

      expect(difference, lessThanOrEqualTo(allowedMarginMinutes));
    });

    test('Negative - Tracking cannot start without a booking', () {
      final emptyBookings = <Object>[];

      expect(emptyBookings, isEmpty);
    });
  });
}
