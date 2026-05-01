// ============================================================
// Admin Role – Comprehensive Unit Tests
// Framework : flutter_test (no external mocking library)
// Coverage  : login · dashboard · workshops · bookings ·
//             chatbot · registrations · pricing · CRUD · logs
// ============================================================

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salahny_fixed/main.dart';
import 'package:salahny_fixed/features/admin/admin_role_service.dart';

void main() {
  // ──────────────────────────────────────────────────────────
  // SECTION 1 – Admin login / authentication
  // ──────────────────────────────────────────────────────────
  group('Admin login / authentication', () {
    // ── PASS cases ──────────────────────────────────────────

    test('PASS: valid credentials return an admin session with correct role',
            () async {
          final repo = _FakeRepo();
          final service = AdminRoleService(repo);

          final result = await service.login(
            const AdminCredentials(
              email: 'admin@salahny.com',
              password: 'admin123',
            ),
          );

          expect(result.isSuccess, isTrue);
          expect(result.data?.role, 'admin');
          expect(result.data?.token, 'token-admin');
          expect(repo.authenticateCalls, 1);
        });

    test('PASS: email with surrounding whitespace is trimmed before API call',
            () async {
          final repo = _FakeRepo();
          final service = AdminRoleService(repo);

          final result = await service.login(
            const AdminCredentials(
              email: '  admin@salahny.com  ',
              password: 'admin123',
            ),
          );

          expect(result.isSuccess, isTrue);
          // Repository must receive the trimmed email, not the raw padded one.
          expect(repo.lastLoginEmail, 'admin@salahny.com');
        });

    test('PASS: password with special characters is accepted', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.login(
        const AdminCredentials(
          email: 'admin@salahny.com',
          password: r'P@$$w0rd!#&*',
        ),
      );

      expect(result.isSuccess, isTrue);
    });

    test('PASS: email with sub-domain is accepted', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.login(
        const AdminCredentials(
          email: 'admin@mail.salahny.com',
          password: 'admin123',
        ),
      );

      expect(result.isSuccess, isTrue);
    });

    // ── FAIL cases ──────────────────────────────────────────

    test('FAIL: empty email is rejected before any API call', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.login(
        const AdminCredentials(email: '', password: 'admin123'),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
      expect(repo.authenticateCalls, 0);
    });

    test('FAIL: empty password is rejected before any API call', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.login(
        const AdminCredentials(email: 'admin@salahny.com', password: ''),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
      expect(repo.authenticateCalls, 0);
    });

    test('FAIL: both email and password empty are rejected together', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.login(
        const AdminCredentials(email: '', password: ''),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
      expect(repo.authenticateCalls, 0);
    });

    test(
        'FAIL: whitespace-only email is treated as empty and rejected before API',
            () async {
          final repo = _FakeRepo();
          final service = AdminRoleService(repo);

          final result = await service.login(
            const AdminCredentials(email: '   ', password: 'admin123'),
          );

          expect(result.isFailure, isTrue);
          expect(result.failure?.type, AdminRoleErrorType.invalidInput);
          // Email trims to '' → isEmpty check fires → repo never called
          expect(repo.authenticateCalls, 0);
        });

    test('FAIL: email missing @ symbol is rejected as malformed', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.login(
        const AdminCredentials(email: 'adminsalahny.com', password: 'admin123'),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
      expect(repo.authenticateCalls, 0);
    });

    test('FAIL: plain text with no domain is rejected as malformed', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.login(
        const AdminCredentials(email: 'admin', password: 'admin123'),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
    });

    test(
        'FAIL: API returns null session → authenticationFailed (wrong password)',
            () async {
          final repo = _FakeRepo(authenticateResult: null);
          final service = AdminRoleService(repo);

          final result = await service.login(
            const AdminCredentials(
                email: 'admin@salahny.com', password: 'wrongpass'),
          );

          expect(result.isFailure, isTrue);
          expect(result.failure?.type, AdminRoleErrorType.authenticationFailed);
          expect(repo.authenticateCalls, 1);
        });

    test(
        'FAIL: API returns session with empty token → authenticationFailed',
            () async {
          final repo =
          _FakeRepo(authenticateResult: const AdminSession(token: ''));
          final service = AdminRoleService(repo);

          final result = await service.login(
            const AdminCredentials(email: 'admin@salahny.com', password: 'admin123'),
          );

          expect(result.isFailure, isTrue);
          expect(result.failure?.type, AdminRoleErrorType.authenticationFailed);
        });

    test(
        'FAIL: API returns session with whitespace-only token → authenticationFailed',
            () async {
          final repo =
          _FakeRepo(authenticateResult: const AdminSession(token: '   '));
          final service = AdminRoleService(repo);

          final result = await service.login(
            const AdminCredentials(email: 'admin@salahny.com', password: 'admin123'),
          );

          expect(result.isFailure, isTrue);
          expect(result.failure?.type, AdminRoleErrorType.authenticationFailed);
        });

    test('FAIL: network exception → failedResponse error type', () async {
      final repo = _FakeRepo(throwOnAuthenticate: true);
      final service = AdminRoleService(repo);

      final result = await service.login(
        const AdminCredentials(email: 'admin@salahny.com', password: 'admin123'),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });

    test('FAIL: multiple consecutive login attempts track call count', () async {
      final repo = _FakeRepo(authenticateResult: null);
      final service = AdminRoleService(repo);

      await service.login(
          const AdminCredentials(email: 'admin@salahny.com', password: 'p1'));
      await service.login(
          const AdminCredentials(email: 'admin@salahny.com', password: 'p2'));
      await service.login(
          const AdminCredentials(email: 'admin@salahny.com', password: 'p3'));

      // All three reached the repository (valid email, non-empty password)
      expect(repo.authenticateCalls, 3);
    });
  });

  // ──────────────────────────────────────────────────────────
  // SECTION 2 – Admin dashboard
  // ──────────────────────────────────────────────────────────
  group('Admin dashboard loading', () {
    test('PASS: dashboard snapshot returns all KPI counters', () async {
      final service = AdminRoleService(_FakeRepo());

      final result = await service.loadDashboard();

      expect(result.isSuccess, isTrue);
      expect(result.data?.drivers, 2);
      expect(result.data?.workshops, 1);
      expect(result.data?.bookings, 1);
      expect(result.data?.revenue, 450.0);
      expect(result.data?.pendingApprovals, 2);
    });

    test('PASS: dashboard with all-zero values succeeds without error',
            () async {
          final service = AdminRoleService(
            _FakeRepo(
              dashboardResult: const AdminDashboardSnapshot(
                drivers: 0,
                workshops: 0,
                bookings: 0,
                revenue: 0,
                pendingApprovals: 0,
              ),
            ),
          );

          final result = await service.loadDashboard();

          expect(result.isSuccess, isTrue);
          expect(result.data?.pendingApprovals, 0);
        });

    test('PASS: dashboard with large KPI numbers succeeds', () async {
      final service = AdminRoleService(
        _FakeRepo(
          dashboardResult: const AdminDashboardSnapshot(
            drivers: 100000,
            workshops: 50000,
            bookings: 999999,
            revenue: 9999999.99,
            pendingApprovals: 5000,
          ),
        ),
      );

      final result = await service.loadDashboard();

      expect(result.isSuccess, isTrue);
      expect(result.data?.revenue, 9999999.99);
    });

    test('FAIL: null dashboard response → failedResponse', () async {
      final service =
      AdminRoleService(_FakeRepo(dashboardResult: null));

      final result = await service.loadDashboard();

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });

    test('FAIL: dashboard API exception → failedResponse', () async {
      final service =
      AdminRoleService(_FakeRepo(throwOnFetchDashboard: true));

      final result = await service.loadDashboard();

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });
  });

  // ──────────────────────────────────────────────────────────
  // SECTION 3 – Monitor workshops
  // ──────────────────────────────────────────────────────────
  group('Monitor workshops', () {
    test('PASS: returns the full workshop list', () async {
      final service = AdminRoleService(_FakeRepo());

      final result = await service.monitorWorkshops();

      expect(result.isSuccess, isTrue);
      expect(result.data, hasLength(1));
      expect(result.data?.first.name, 'Cairo Auto Care');
    });

    test('PASS: returns verified and unverified workshops in the same list',
            () async {
          final service = AdminRoleService(
            _FakeRepo(
              workshopsResult: const [
                AdminWorkshopSummary(
                    id: 'w1', name: 'Garage A', status: 'active', isVerified: true),
                AdminWorkshopSummary(
                    id: 'w2',
                    name: 'Garage B',
                    status: 'pending',
                    isVerified: false),
              ],
            ),
          );

          final result = await service.monitorWorkshops();

          expect(result.isSuccess, isTrue);
          expect(result.data, hasLength(2));
          expect(result.data?.first.isVerified, isTrue);
          expect(result.data?.last.isVerified, isFalse);
        });

    test('PASS: empty workshop list succeeds without failure', () async {
      final service =
      AdminRoleService(_FakeRepo(workshopsResult: const []));

      final result = await service.monitorWorkshops();

      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });

    test('FAIL: null workshops response → failedResponse', () async {
      final service =
      AdminRoleService(_FakeRepo(workshopsResult: null));

      final result = await service.monitorWorkshops();

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });

    test('FAIL: workshops API exception → failedResponse', () async {
      final service =
      AdminRoleService(_FakeRepo(throwOnFetchWorkshops: true));

      final result = await service.monitorWorkshops();

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });

    test('PASS: returned list is unmodifiable (immutable snapshot)', () async {
      final service = AdminRoleService(_FakeRepo());

      final result = await service.monitorWorkshops();

      expect(
            () => (result.data as List).add(
          const AdminWorkshopSummary(id: 'x', name: 'x', status: 'x'),
        ),
        throwsUnsupportedError,
      );
    });
  });

  // ──────────────────────────────────────────────────────────
  // SECTION 4 – Monitor bookings
  // ──────────────────────────────────────────────────────────
  group('Monitor bookings', () {
    test('PASS: returns booking with correct fields', () async {
      final service = AdminRoleService(_FakeRepo());

      final result = await service.monitorBookings();

      expect(result.isSuccess, isTrue);
      expect(result.data?.first.driverName, 'Mariam');
      expect(result.data?.first.workshopName, 'Cairo Auto Care');
      expect(result.data?.first.status, 'active');
      expect(result.data?.first.total, 450.0);
    });

    test('PASS: multiple bookings across different statuses all returned',
            () async {
          final service = AdminRoleService(
            _FakeRepo(
              bookingsResult: const [
                AdminBookingSummary(
                    id: 'b1',
                    driverName: 'Ali',
                    workshopName: 'W1',
                    status: 'pending',
                    total: 200),
                AdminBookingSummary(
                    id: 'b2',
                    driverName: 'Sara',
                    workshopName: 'W2',
                    status: 'completed',
                    total: 350),
                AdminBookingSummary(
                    id: 'b3',
                    driverName: 'Omar',
                    workshopName: 'W3',
                    status: 'cancelled',
                    total: 0),
              ],
            ),
          );

          final result = await service.monitorBookings();

          expect(result.isSuccess, isTrue);
          expect(result.data, hasLength(3));
        });

    test('PASS: empty bookings list succeeds', () async {
      final service =
      AdminRoleService(_FakeRepo(bookingsResult: const []));

      final result = await service.monitorBookings();

      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });

    test('FAIL: null bookings response → failedResponse', () async {
      final service =
      AdminRoleService(_FakeRepo(bookingsResult: null));

      final result = await service.monitorBookings();

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });

    test('FAIL: bookings API network exception → failedResponse', () async {
      final service =
      AdminRoleService(_FakeRepo(throwOnFetchBookings: true));

      final result = await service.monitorBookings();

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });
  });

  // ──────────────────────────────────────────────────────────
  // SECTION 5 – Monitor chatbot data
  // ──────────────────────────────────────────────────────────
  group('Monitor chatbot data', () {
    test('PASS: returns chatbot metrics with correct fields', () async {
      final service = AdminRoleService(_FakeRepo());

      final result = await service.monitorChatbotData();

      expect(result.isSuccess, isTrue);
      expect(result.data?.first.intent, 'diagnostics_help');
      expect(result.data?.first.conversations, 20);
      expect(result.data?.first.failedAnswers, 1);
    });

    test('PASS: multiple intents returned intact', () async {
      final service = AdminRoleService(
        _FakeRepo(
          chatbotResult: const [
            AdminChatbotMetric(
                intent: 'booking_help', conversations: 45, failedAnswers: 3),
            AdminChatbotMetric(
                intent: 'service_info', conversations: 30, failedAnswers: 0),
            AdminChatbotMetric(
                intent: 'emergency_support', conversations: 5, failedAnswers: 5),
          ],
        ),
      );

      final result = await service.monitorChatbotData();

      expect(result.isSuccess, isTrue);
      expect(result.data, hasLength(3));
    });

    test('PASS: empty chatbot metrics list succeeds without crash', () async {
      final service =
      AdminRoleService(_FakeRepo(chatbotResult: const []));

      final result = await service.monitorChatbotData();

      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });

    test('FAIL: null chatbot response → failedResponse', () async {
      final service =
      AdminRoleService(_FakeRepo(chatbotResult: null));

      final result = await service.monitorChatbotData();

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });

    test('FAIL: chatbot API exception → failedResponse', () async {
      final service =
      AdminRoleService(_FakeRepo(throwOnFetchChatbot: true));

      final result = await service.monitorChatbotData();

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });
  });

  // ──────────────────────────────────────────────────────────
  // SECTION 6 – Accept / reject registration requests
  // ──────────────────────────────────────────────────────────
  group('Accept / reject workshop or driver registration', () {
    test('PASS: accepting a pending workshop saves the decision', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.decideRegistration(
        'workshop-1',
        AdminRegistrationDecision.accept,
      );

      expect(result.isSuccess, isTrue);
      expect(result.data, isTrue);
      expect(repo.decisions['workshop-1'], AdminRegistrationDecision.accept);
    });

    test('PASS: rejecting a pending driver saves the decision', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.decideRegistration(
        'driver-1',
        AdminRegistrationDecision.reject,
      );

      expect(result.isSuccess, isTrue);
      expect(repo.decisions['driver-1'], AdminRegistrationDecision.reject);
    });

    test('PASS: request ID with surrounding whitespace is trimmed', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.decideRegistration(
        '  workshop-2  ',
        AdminRegistrationDecision.accept,
      );

      expect(result.isSuccess, isTrue);
      expect(repo.decisions.containsKey('workshop-2'), isTrue);
    });

    test('PASS: deciding on multiple registrations stores all decisions',
            () async {
          final repo = _FakeRepo();
          final service = AdminRoleService(repo);

          await service.decideRegistration(
              'w-1', AdminRegistrationDecision.accept);
          await service.decideRegistration(
              'w-2', AdminRegistrationDecision.reject);
          await service.decideRegistration(
              'd-1', AdminRegistrationDecision.accept);

          expect(repo.decisions, {
            'w-1': AdminRegistrationDecision.accept,
            'w-2': AdminRegistrationDecision.reject,
            'd-1': AdminRegistrationDecision.accept,
          });
        });

    test('FAIL: empty request ID is rejected as invalid input', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.decideRegistration(
        '',
        AdminRegistrationDecision.accept,
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
      expect(repo.decisions, isEmpty);
    });

    test('FAIL: whitespace-only request ID is rejected as invalid input',
            () async {
          final repo = _FakeRepo();
          final service = AdminRoleService(repo);

          final result = await service.decideRegistration(
            '   ',
            AdminRegistrationDecision.accept,
          );

          expect(result.isFailure, isTrue);
          expect(result.failure?.type, AdminRoleErrorType.invalidInput);
          expect(repo.decisions, isEmpty);
        });

    test('FAIL: repository returns false → failedResponse', () async {
      final repo = _FakeRepo(decideRegistrationResult: false);
      final service = AdminRoleService(repo);

      final result = await service.decideRegistration(
        'driver-2',
        AdminRegistrationDecision.accept,
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });

    test('FAIL: repository throws exception → failedResponse', () async {
      final repo = _FakeRepo(throwOnDecideRegistration: true);
      final service = AdminRoleService(repo);

      final result = await service.decideRegistration(
        'driver-2',
        AdminRegistrationDecision.accept,
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });
  });

  // ──────────────────────────────────────────────────────────
  // SECTION 7 – Update service / package prices
  // ──────────────────────────────────────────────────────────
  group('Update service or package prices', () {
    test('PASS: valid integer price is saved', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.updatePrice('service-1', 250);

      expect(result.isSuccess, isTrue);
      expect(repo.prices['service-1'], 250.0);
    });

    test('PASS: valid decimal price is saved', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.updatePrice('package-1', 99.99);

      expect(result.isSuccess, isTrue);
      expect(repo.prices['package-1'], 99.99);
    });

    test('PASS: minimum valid price (0.01) is accepted', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.updatePrice('service-2', 0.01);

      expect(result.isSuccess, isTrue);
      expect(repo.prices['service-2'], 0.01);
    });

    test('PASS: updating price of both a service and a package in sequence',
            () async {
          final repo = _FakeRepo();
          final service = AdminRoleService(repo);

          await service.updatePrice('service-1', 100);
          await service.updatePrice('package-1', 500);

          expect(repo.prices['service-1'], 100.0);
          expect(repo.prices['package-1'], 500.0);
        });

    test('FAIL: price of 0 is rejected as invalid input', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.updatePrice('service-1', 0);

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
      expect(repo.prices, isEmpty);
    });

    test('FAIL: negative price is rejected as invalid input', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.updatePrice('service-1', -99);

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
      expect(repo.prices, isEmpty);
    });

    test('FAIL: infinite price is rejected as invalid input', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result =
      await service.updatePrice('service-1', double.infinity);

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
    });

    test('FAIL: NaN price is rejected as invalid input', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.updatePrice('service-1', double.nan);

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
    });

    test('FAIL: empty item ID is rejected as invalid input', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.updatePrice('', 200);

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
      expect(repo.prices, isEmpty);
    });

    test('FAIL: whitespace-only item ID is rejected as invalid input',
            () async {
          final repo = _FakeRepo();
          final service = AdminRoleService(repo);

          final result = await service.updatePrice('   ', 200);

          expect(result.isFailure, isTrue);
          expect(result.failure?.type, AdminRoleErrorType.invalidInput);
        });

    test('FAIL: repository returns false → failedResponse', () async {
      final repo = _FakeRepo(updatePriceResult: false);
      final service = AdminRoleService(repo);

      final result = await service.updatePrice('service-1', 100);

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });

    test('FAIL: repository throws exception → failedResponse', () async {
      final repo = _FakeRepo(throwOnUpdatePrice: true);
      final service = AdminRoleService(repo);

      final result = await service.updatePrice('service-1', 100);

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });
  });

  // ──────────────────────────────────────────────────────────
  // SECTION 8 – Add services / packages (CRUD – Create)
  // ──────────────────────────────────────────────────────────
  group('Add services or packages', () {
    const validService = AdminPricedItem(
      id: 'service-10',
      name: 'Full Engine Inspection',
      price: 300,
      type: 'service',
    );

    const validPackage = AdminPricedItem(
      id: 'package-10',
      name: 'Gold Plan',
      price: 2700,
      type: 'package',
    );

    test('PASS: adds a valid service item', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.addPricedItem(validService);

      expect(result.isSuccess, isTrue);
      expect(repo.items.containsKey('service-10'), isTrue);
    });

    test('PASS: adds a valid package item', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.addPricedItem(validPackage);

      expect(result.isSuccess, isTrue);
      expect(repo.items['package-10']?.name, 'Gold Plan');
    });

    test('PASS: item name is trimmed before being passed to repository',
            () async {
          final repo = _FakeRepo();
          final service = AdminRoleService(repo);

          final result = await service.addPricedItem(
            const AdminPricedItem(
                id: 'service-11',
                name: '  Oil Change  ',
                price: 150,
                type: 'service'),
          );

          expect(result.isSuccess, isTrue);
          expect(repo.items['service-11']?.name, 'Oil Change');
        });

    test('PASS: disabled item (isEnabled=false) is added correctly', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.addPricedItem(
        const AdminPricedItem(
          id: 'service-12',
          name: 'Seasonal Check',
          price: 100,
          type: 'service',
          isEnabled: false,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(repo.items['service-12']?.isEnabled, isFalse);
    });

    test('FAIL: empty item ID is rejected as invalid input', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.addPricedItem(
        const AdminPricedItem(id: '', name: 'Test', price: 100, type: 'service'),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
      expect(repo.items, isEmpty);
    });

    test('FAIL: empty item name is rejected as invalid input', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.addPricedItem(
        const AdminPricedItem(
            id: 'service-13', name: '', price: 100, type: 'service'),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
    });

    test('FAIL: whitespace-only name is rejected as invalid input', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.addPricedItem(
        const AdminPricedItem(
            id: 'service-14', name: '   ', price: 100, type: 'service'),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
    });

    test('FAIL: empty type is rejected as invalid input', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.addPricedItem(
        const AdminPricedItem(
            id: 'item-1', name: 'Test Item', price: 100, type: ''),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
    });

    test('FAIL: zero price on add is rejected as invalid input', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.addPricedItem(
        const AdminPricedItem(
            id: 'service-15', name: 'Free Check', price: 0, type: 'service'),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
    });

    test('FAIL: negative price on add is rejected', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.addPricedItem(
        const AdminPricedItem(
            id: 'service-16', name: 'Bad Price', price: -50, type: 'service'),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
    });

    test('FAIL: repository throws on add → failedResponse', () async {
      final repo = _FakeRepo(throwOnAddItem: true);
      final service = AdminRoleService(repo);

      final result = await service.addPricedItem(validService);

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });
  });

  // ──────────────────────────────────────────────────────────
  // SECTION 9 – Edit services / packages (CRUD – Update)
  // ──────────────────────────────────────────────────────────
  group('Edit services or packages', () {
    test('PASS: edits existing item with new name and price', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.editPricedItem(
        const AdminPricedItem(
          id: 'service-1',
          name: 'Updated Oil Change',
          price: 180,
          type: 'service',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(repo.items['service-1']?.name, 'Updated Oil Change');
      expect(repo.items['service-1']?.price, 180.0);
    });

    test('PASS: disabling an existing item via edit is valid', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.editPricedItem(
        const AdminPricedItem(
          id: 'service-1',
          name: 'Oil Change',
          price: 150,
          type: 'service',
          isEnabled: false,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(repo.items['service-1']?.isEnabled, isFalse);
    });

    test('FAIL: editing an item with empty name is rejected', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.editPricedItem(
        const AdminPricedItem(
            id: 'service-1', name: '', price: 150, type: 'service'),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
      expect(repo.items, isEmpty);
    });

    test('FAIL: editing with invalid price is rejected', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.editPricedItem(
        const AdminPricedItem(
            id: 'service-1', name: 'Oil Change', price: -10, type: 'service'),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
    });

    test('FAIL: repository throws on edit → failedResponse', () async {
      final repo = _FakeRepo(throwOnEditItem: true);
      final service = AdminRoleService(repo);

      final result = await service.editPricedItem(
        const AdminPricedItem(
            id: 'service-1', name: 'Oil Change', price: 150, type: 'service'),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });
  });

  // ──────────────────────────────────────────────────────────
  // SECTION 10 – Delete services / packages (CRUD – Delete)
  // ──────────────────────────────────────────────────────────
  group('Delete services or packages', () {
    test('PASS: deletes item by valid ID', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.deletePricedItem('service-1');

      expect(result.isSuccess, isTrue);
      expect(repo.deletedIds, contains('service-1'));
    });

    test('PASS: deletes multiple items sequentially', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      await service.deletePricedItem('service-1');
      await service.deletePricedItem('package-1');

      expect(repo.deletedIds, containsAll(['service-1', 'package-1']));
    });

    test('PASS: ID with surrounding whitespace is trimmed before delete',
            () async {
          final repo = _FakeRepo();
          final service = AdminRoleService(repo);

          final result = await service.deletePricedItem('  service-1  ');

          expect(result.isSuccess, isTrue);
          expect(repo.deletedIds, contains('service-1'));
        });

    test('FAIL: empty ID is rejected as invalid input', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.deletePricedItem('');

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
      expect(repo.deletedIds, isEmpty);
    });

    test('FAIL: whitespace-only ID is rejected as invalid input', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      final result = await service.deletePricedItem('   ');

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
    });

    test('FAIL: repository returns false on delete → failedResponse', () async {
      final repo = _FakeRepo(deleteItemResult: false);
      final service = AdminRoleService(repo);

      final result = await service.deletePricedItem('service-1');

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });

    test('FAIL: repository throws on delete → failedResponse', () async {
      final repo = _FakeRepo(throwOnDeleteItem: true);
      final service = AdminRoleService(repo);

      final result = await service.deletePricedItem('service-1');

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });
  });

  // ──────────────────────────────────────────────────────────
  // SECTION 11 – Full CRUD lifecycle (integration-style)
  // ──────────────────────────────────────────────────────────
  group('Full service CRUD lifecycle', () {
    test('PASS: add → edit → delete a service item in sequence', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      const item = AdminPricedItem(
        id: 'svc-new',
        name: 'Tyre Rotation',
        price: 120,
        type: 'service',
      );

      final add = await service.addPricedItem(item);
      expect(add.isSuccess, isTrue);
      expect(repo.items.containsKey('svc-new'), isTrue);

      final edit = await service.editPricedItem(
        const AdminPricedItem(
          id: 'svc-new',
          name: 'Premium Tyre Rotation',
          price: 150,
          type: 'service',
        ),
      );
      expect(edit.isSuccess, isTrue);
      expect(repo.items['svc-new']?.name, 'Premium Tyre Rotation');

      final delete = await service.deletePricedItem('svc-new');
      expect(delete.isSuccess, isTrue);
      expect(repo.deletedIds, contains('svc-new'));
    });

    test('PASS: add → updatePrice → delete a package item', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      await service.addPricedItem(
        const AdminPricedItem(
            id: 'pkg-new', name: 'Bronze Plan', price: 500, type: 'package'),
      );
      await service.updatePrice('pkg-new', 450);
      await service.deletePricedItem('pkg-new');

      expect(repo.prices['pkg-new'], 450.0);
      expect(repo.deletedIds, contains('pkg-new'));
    });
  });

  // ──────────────────────────────────────────────────────────
  // SECTION 12 – View platform activity logs
  // ──────────────────────────────────────────────────────────
  group('View platform activity logs', () {
    test('PASS: returns activity log entries', () async {
      final service = AdminRoleService(_FakeRepo());

      final result = await service.viewPlatformActivity();

      expect(result.isSuccess, isTrue);
      expect(result.data?.first.action, 'login');
      expect(result.data?.first.details, 'Admin logged in');
    });

    test('PASS: multiple log entries all returned correctly', () async {
      final service = AdminRoleService(
        _FakeRepo(
          activityResult: const [
            AdminActivity(id: 'l1', action: 'login', details: 'Admin logged in'),
            AdminActivity(
                id: 'l2',
                action: 'approve_workshop',
                details: 'Workshop Cairo Auto Care approved'),
            AdminActivity(
                id: 'l3',
                action: 'delete_service',
                details: 'Service Oil Change deleted'),
          ],
        ),
      );

      final result = await service.viewPlatformActivity();

      expect(result.isSuccess, isTrue);
      expect(result.data, hasLength(3));
      expect(result.data?[1].action, 'approve_workshop');
    });

    test('PASS: empty log list succeeds without crash', () async {
      final service =
      AdminRoleService(_FakeRepo(activityResult: const []));

      final result = await service.viewPlatformActivity();

      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });

    test('FAIL: null activity response → failedResponse', () async {
      final service =
      AdminRoleService(_FakeRepo(activityResult: null));

      final result = await service.viewPlatformActivity();

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });

    test('FAIL: activity API exception → failedResponse', () async {
      final service =
      AdminRoleService(_FakeRepo(throwOnFetchActivity: true));

      final result = await service.viewPlatformActivity();

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });
  });

  // ──────────────────────────────────────────────────────────
  // SECTION 13 – Concurrent / parallel operation safety
  // ──────────────────────────────────────────────────────────
  group('Concurrent admin operations', () {
    test('PASS: parallel dashboard + workshops + bookings all succeed',
            () async {
          final service = AdminRoleService(_FakeRepo());

          final results = await Future.wait([
            service.loadDashboard(),
            service.monitorWorkshops(),
            service.monitorBookings(),
          ]);

          for (final r in results) {
            expect(r.isSuccess, isTrue);
          }
        });

    test('PASS: parallel registration decisions are all recorded', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      await Future.wait([
        service.decideRegistration('w-1', AdminRegistrationDecision.accept),
        service.decideRegistration('w-2', AdminRegistrationDecision.reject),
        service.decideRegistration('d-1', AdminRegistrationDecision.accept),
        service.decideRegistration('d-2', AdminRegistrationDecision.reject),
      ]);

      expect(repo.decisions.length, 4);
      expect(repo.decisions['w-1'], AdminRegistrationDecision.accept);
      expect(repo.decisions['d-2'], AdminRegistrationDecision.reject);
    });

    test('PASS: parallel price updates do not overwrite each other', () async {
      final repo = _FakeRepo();
      final service = AdminRoleService(repo);

      await Future.wait([
        service.updatePrice('service-1', 100),
        service.updatePrice('service-2', 200),
        service.updatePrice('package-1', 300),
      ]);

      expect(repo.prices['service-1'], 100.0);
      expect(repo.prices['service-2'], 200.0);
      expect(repo.prices['package-1'], 300.0);
    });
  });

  group('Admin screen navigation widget flow', () {
    testWidgets(
      'PASS: splash opens role selection before any role dashboard',
      (tester) async {
        await tester.pumpWidget(const MyApp());

        expect(find.text('Salahny'), findsOneWidget);
        expect(find.text('Super Admin Access'), findsNothing);

        await tester.pump(const Duration(milliseconds: 750));
        await tester.pumpAndSettle();

        expect(find.text('Choose Role'), findsOneWidget);
        expect(find.text('Admin'), findsOneWidget);
        expect(find.text('Platform command center'), findsNothing);
      },
    );

    testWidgets(
      'PASS: selecting each non-admin role opens that role home',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pump(const Duration(milliseconds: 750));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Driver'));
        await tester.pumpAndSettle();
        expect(find.text('Driver Home'), findsOneWidget);

        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Workshop'));
        await tester.pumpAndSettle();
        expect(find.text('Workshop Home'), findsOneWidget);

        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.tap(find.text('AI Diagnostics'));
        await tester.pumpAndSettle();
        expect(find.text('AI Diagnostics Home'), findsOneWidget);
      },
    );

    testWidgets(
      'PASS: valid admin login opens the dashboard route',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await _openAdminLogin(tester);

        await tester.tap(find.text('Access Admin Dashboard'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 950));
        await tester.pumpAndSettle();

        expect(find.text('Platform command center'), findsOneWidget);
      },
    );

    testWidgets(
      'PASS: dashboard quick action opens Services management',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await _openAdminLogin(tester);

        await tester.tap(find.text('Access Admin Dashboard'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 950));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Manage Services'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Manage Services'));
        await tester.pumpAndSettle();

        expect(find.text('Services'), findsWidgets);
        expect(find.text('Oil Change'), findsOneWidget);
      },
    );

    testWidgets(
      'FAIL scenario: invalid admin credentials stay on login screen',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await _openAdminLogin(tester);

        await tester.enterText(find.byType(EditableText).at(1), 'wrong-password');
        await tester.tap(find.text('Access Admin Dashboard'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 950));

        expect(find.text('Super Admin Access'), findsOneWidget);
        expect(find.text('Platform command center'), findsNothing);
      },
    );

    testWidgets(
      'FAIL scenario: malformed email is rejected before navigation',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await _openAdminLogin(tester);

        await tester.enterText(find.byType(EditableText).first, 'admin-email');
        await tester.tap(find.text('Access Admin Dashboard'));
        await tester.pump();

        expect(find.text('Enter a valid email'), findsOneWidget);
        expect(find.text('Platform command center'), findsNothing);
      },
    );
  });
}

Future<void> _openAdminLogin(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 750));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Admin'));
  await tester.pumpAndSettle();
  expect(find.text('Super Admin Access'), findsOneWidget);
}

// ============================================================
// Fake repository – configurable for all test scenarios
// ============================================================
class _FakeRepo implements AdminRoleRepository {
  _FakeRepo({
    this.authenticateResult = const AdminSession(token: 'token-admin'),
    this.dashboardResult = const AdminDashboardSnapshot(
      drivers: 2,
      workshops: 1,
      bookings: 1,
      revenue: 450,
      pendingApprovals: 2,
    ),
    this.workshopsResult = const [
      AdminWorkshopSummary(
          id: 'workshop-1', name: 'Cairo Auto Care', status: 'pending'),
    ],
    this.bookingsResult = const [
      AdminBookingSummary(
        id: 'booking-1',
        driverName: 'Mariam',
        workshopName: 'Cairo Auto Care',
        status: 'active',
        total: 450,
      ),
    ],
    this.chatbotResult = const [
      AdminChatbotMetric(
          intent: 'diagnostics_help', conversations: 20, failedAnswers: 1),
    ],
    this.activityResult = const [
      AdminActivity(id: 'log-1', action: 'login', details: 'Admin logged in'),
    ],
    this.decideRegistrationResult = true,
    this.updatePriceResult = true,
    this.addItemResult = true,
    this.editItemResult = true,
    this.deleteItemResult = true,
    this.throwOnAuthenticate = false,
    this.throwOnFetchDashboard = false,
    this.throwOnFetchWorkshops = false,
    this.throwOnFetchBookings = false,
    this.throwOnFetchChatbot = false,
    this.throwOnFetchActivity = false,
    this.throwOnDecideRegistration = false,
    this.throwOnUpdatePrice = false,
    this.throwOnAddItem = false,
    this.throwOnEditItem = false,
    this.throwOnDeleteItem = false,
  });

  // Configurable return values
  final AdminSession? authenticateResult;
  final AdminDashboardSnapshot? dashboardResult;
  final List<AdminWorkshopSummary>? workshopsResult;
  final List<AdminBookingSummary>? bookingsResult;
  final List<AdminChatbotMetric>? chatbotResult;
  final List<AdminActivity>? activityResult;
  final bool decideRegistrationResult;
  final bool updatePriceResult;
  final bool addItemResult;
  final bool editItemResult;
  final bool deleteItemResult;

  // Throw-on-call flags
  final bool throwOnAuthenticate;
  final bool throwOnFetchDashboard;
  final bool throwOnFetchWorkshops;
  final bool throwOnFetchBookings;
  final bool throwOnFetchChatbot;
  final bool throwOnFetchActivity;
  final bool throwOnDecideRegistration;
  final bool throwOnUpdatePrice;
  final bool throwOnAddItem;
  final bool throwOnEditItem;
  final bool throwOnDeleteItem;

  // State trackers for assertions
  int authenticateCalls = 0;
  String? lastLoginEmail;
  final decisions = <String, AdminRegistrationDecision>{};
  final prices = <String, double>{};
  final items = <String, AdminPricedItem>{};
  final deletedIds = <String>[];

  @override
  Future<AdminSession?> authenticate(AdminCredentials credentials) async {
    authenticateCalls++;
    lastLoginEmail = credentials.email;
    if (throwOnAuthenticate) throw StateError('network error');
    return authenticateResult;
  }

  @override
  Future<AdminDashboardSnapshot?> fetchDashboard() async {
    if (throwOnFetchDashboard) throw StateError('network error');
    return dashboardResult;
  }

  @override
  Future<List<AdminWorkshopSummary>?> fetchWorkshops() async {
    if (throwOnFetchWorkshops) throw StateError('network error');
    return workshopsResult;
  }

  @override
  Future<List<AdminBookingSummary>?> fetchBookings() async {
    if (throwOnFetchBookings) throw StateError('network error');
    return bookingsResult;
  }

  @override
  Future<List<AdminChatbotMetric>?> fetchChatbotMetrics() async {
    if (throwOnFetchChatbot) throw StateError('network error');
    return chatbotResult;
  }

  @override
  Future<List<AdminActivity>?> fetchActivity() async {
    if (throwOnFetchActivity) throw StateError('network error');
    return activityResult;
  }

  @override
  Future<bool> decideRegistration(
      String requestId,
      AdminRegistrationDecision decision,
      ) async {
    if (throwOnDecideRegistration) throw StateError('network error');
    decisions[requestId] = decision;
    return decideRegistrationResult;
  }

  @override
  Future<bool> updatePrice(String itemId, double price) async {
    if (throwOnUpdatePrice) throw StateError('network error');
    prices[itemId] = price;
    return updatePriceResult;
  }

  @override
  Future<bool> addPricedItem(AdminPricedItem item) async {
    if (throwOnAddItem) throw StateError('network error');
    items[item.id] = item;
    return addItemResult;
  }

  @override
  Future<bool> editPricedItem(AdminPricedItem item) async {
    if (throwOnEditItem) throw StateError('network error');
    items[item.id] = item;
    return editItemResult;
  }

  @override
  Future<bool> deletePricedItem(String itemId) async {
    if (throwOnDeleteItem) throw StateError('network error');
    deletedIds.add(itemId);
    items.remove(itemId);
    return deleteItemResult;
  }
}
