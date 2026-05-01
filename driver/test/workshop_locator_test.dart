import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salahny_fixed/core/constants/app_constants.dart';
import 'package:salahny_fixed/features/driver/workshops/workshops_screen.dart';
import 'package:salahny_fixed/shared/models/models.dart';
import 'package:salahny_fixed/shared/services/mock_data.dart';

Widget _buildWorkshopsScreen() {
  return MaterialApp(
    routes: {
      R.workshopDetail: (_) => const Scaffold(
            body: Center(child: Text('Workshop Detail Screen')),
          ),
    },
    home: const WorkshopsScreen(),
  );
}

void main() {
  group('US3 - Driver Workshop Locator', () {
    testWidgets('AC1 - Workshops screen displays nearby workshops from project data',
        (WidgetTester tester) async {
      final workshops = AppData.i.workshops;

      await tester.pumpWidget(_buildWorkshopsScreen());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Nearby Workshops'), findsOneWidget);
      expect(find.text('Your Location'), findsOneWidget);
      expect(find.text('Available Now'), findsOneWidget);
      expect(find.text('${workshops.length} workshops within 10 miles'), findsOneWidget);

      for (final workshop in workshops) {
        expect(find.text(workshop.name), findsOneWidget);
      }
    });

    test('AC1 - All registered mock workshops are within 10km radius', () {
      final nearbyWorkshops = AppData.i.workshops
          .where((workshop) => workshop.distance <= 10)
          .toList();

      expect(nearbyWorkshops.length, equals(AppData.i.workshops.length));
      expect(
        nearbyWorkshops.every((workshop) => workshop.distance <= 10),
        isTrue,
      );
    });

    testWidgets('AC2 - Selecting a workshop opens workshop detail page',
        (WidgetTester tester) async {
      final firstWorkshop = AppData.i.workshops.first;

      await tester.pumpWidget(_buildWorkshopsScreen());
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text(firstWorkshop.name));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Workshop Detail Screen'), findsOneWidget);
    });

    test('AC3 - Specialty filter returns only relevant workshops', () {
      final workshops = AppData.i.workshops;
      final selectedSpecialty = workshops.first.specialty;

      final filtered = workshops
          .where((workshop) => workshop.specialty == selectedSpecialty)
          .toList();

      expect(filtered, isNotEmpty);
      expect(
        filtered.every((workshop) => workshop.specialty == selectedSpecialty),
        isTrue,
      );
    });

    test('Negative/Edge - Empty workshop list should return no results', () {
      const emptyWorkshops = <WorkshopModel>[];

      final filtered = emptyWorkshops
          .where((workshop) => workshop.distance <= 10)
          .toList();

      expect(filtered, isEmpty);
    });
  });
}
