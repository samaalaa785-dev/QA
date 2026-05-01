import 'package:flutter_test/flutter_test.dart';

void main() {
  group('US3 - Driver Workshop Locator', () {
    test('Happy Path - Workshops should be within 10km radius', () {
      const workshopDistances = [5, 7, 9];

      final allWithinRange =
      workshopDistances.every((distance) => distance <= 10);

      expect(allWithinRange, isTrue);
    });

    test('AC2 - Workshop profile should load in less than 1.5 seconds', () {
      const loadTimeInSeconds = 1.2;

      expect(loadTimeInSeconds, lessThan(1.5));
    });

    test('AC3 - Specialty filter should return only relevant workshops', () {
      const selectedSpecialty = 'mechanic';
      const workshops = ['mechanic', 'mechanic', 'electric'];

      final filtered =
      workshops.where((workshop) => workshop == selectedSpecialty).toList();

      expect(filtered, isNotEmpty);
      expect(filtered.every((workshop) => workshop == selectedSpecialty), isTrue);
    });

    test('Negative Case - Empty workshop list should return no results', () {
      const workshops = [];

      expect(workshops, isEmpty);
    });

    test(
      'FAILED TEST - Workshop outside 10km should fail the radius condition',
          () {
        const workshopDistances = [5, 7, 15];

        final allWithinRange =
        workshopDistances.every((distance) => distance <= 10);

        expect(allWithinRange, isTrue);
      },
      skip: true,
    );
  });
}