import 'package:flutter_test/flutter_test.dart';
import 'package:salahny_fixed/features/admin/admin_role_service.dart';

void main() {
  group('Admin login / authentication', () {
    test('success: returns an admin session for valid credentials', () async {
      final repo = _FakeAdminRoleRepository();
      final service = AdminRoleService(repo);

      final result = await service.login(
        const AdminCredentials(
          email: ' admin@salahny.com ',
          password: 'admin123',
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.data?.role, 'admin');
      expect(result.data?.token, 'token-admin');
      expect(repo.lastLoginEmail, 'admin@salahny.com');
    });

    test('failure: rejects empty email or password before API call', () async {
      final repo = _FakeAdminRoleRepository();
      final service = AdminRoleService(repo);

      final result = await service.login(
        const AdminCredentials(email: '', password: ''),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
      expect(repo.authenticateCalls, 0);
    });

    test('invalid input: rejects malformed admin email', () async {
      final repo = _FakeAdminRoleRepository();
      final service = AdminRoleService(repo);

      final result = await service.login(
        const AdminCredentials(email: 'admin-email', password: 'admin123'),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
      expect(repo.authenticateCalls, 0);
    });

    test('failure: handles invalid credentials returned by API', () async {
      final repo = _FakeAdminRoleRepository(authenticateResult: null);
      final service = AdminRoleService(repo);

      final result = await service.login(
        const AdminCredentials(email: 'admin@salahny.com', password: 'bad'),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.authenticationFailed);
    });

    test('failure: handles failed authentication API response', () async {
      final repo = _FakeAdminRoleRepository(throwOnAuthenticate: true);
      final service = AdminRoleService(repo);

      final result = await service.login(
        const AdminCredentials(
          email: 'admin@salahny.com',
          password: 'admin123',
        ),
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });
  });

  group('Admin dashboard loading', () {
    test('success: loads dashboard counters', () async {
      final service = AdminRoleService(_FakeAdminRoleRepository());

      final result = await service.loadDashboard();

      expect(result.isSuccess, isTrue);
      expect(result.data?.drivers, 2);
      expect(result.data?.workshops, 1);
      expect(result.data?.pendingApprovals, 2);
    });

    test('failure: handles invalid empty dashboard API response', () async {
      final service = AdminRoleService(
        _FakeAdminRoleRepository(dashboardResult: null),
      );

      final result = await service.loadDashboard();

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });
  });

  group('Monitor workshops', () {
    test('success: returns workshop list', () async {
      final service = AdminRoleService(_FakeAdminRoleRepository());

      final result = await service.monitorWorkshops();

      expect(result.isSuccess, isTrue);
      expect(result.data, hasLength(1));
      expect(result.data?.first.name, 'Cairo Auto Care');
    });

    test(
      'empty data: returns an empty workshop list without failure',
      () async {
        final service = AdminRoleService(
          _FakeAdminRoleRepository(workshopsResult: const []),
        );

        final result = await service.monitorWorkshops();

        expect(result.isSuccess, isTrue);
        expect(result.data, isEmpty);
      },
    );
  });

  group('Monitor bookings', () {
    test('success: returns booking list', () async {
      final service = AdminRoleService(_FakeAdminRoleRepository());

      final result = await service.monitorBookings();

      expect(result.isSuccess, isTrue);
      expect(result.data?.first.status, 'active');
      expect(result.data?.first.total, 450);
    });

    test('failure: handles failed bookings API response', () async {
      final service = AdminRoleService(
        _FakeAdminRoleRepository(throwOnFetchBookings: true),
      );

      final result = await service.monitorBookings();

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.failedResponse);
    });
  });

  group('Monitor chatbot data', () {
    test('success: returns chatbot metrics', () async {
      final service = AdminRoleService(_FakeAdminRoleRepository());

      final result = await service.monitorChatbotData();

      expect(result.isSuccess, isTrue);
      expect(result.data?.first.intent, 'diagnostics_help');
      expect(result.data?.first.failedAnswers, 1);
    });

    test('empty data: returns empty chatbot metrics without crash', () async {
      final service = AdminRoleService(
        _FakeAdminRoleRepository(chatbotResult: const []),
      );

      final result = await service.monitorChatbotData();

      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });
  });

  group('Accept / reject new workshop or driver registration', () {
    test('success: accepts a pending workshop registration', () async {
      final repo = _FakeAdminRoleRepository();
      final service = AdminRoleService(repo);

      final result = await service.decideRegistration(
        'workshop-1',
        AdminRegistrationDecision.accept,
      );

      expect(result.isSuccess, isTrue);
      expect(repo.decisions, {'workshop-1': AdminRegistrationDecision.accept});
    });

    test('success: rejects a pending driver registration', () async {
      final repo = _FakeAdminRoleRepository();
      final service = AdminRoleService(repo);

      final result = await service.decideRegistration(
        'driver-1',
        AdminRegistrationDecision.reject,
      );

      expect(result.isSuccess, isTrue);
      expect(repo.decisions, {'driver-1': AdminRegistrationDecision.reject});
    });

    test('invalid input: rejects empty registration id', () async {
      final repo = _FakeAdminRoleRepository();
      final service = AdminRoleService(repo);

      final result = await service.decideRegistration(
        '',
        AdminRegistrationDecision.accept,
      );

      expect(result.isFailure, isTrue);
      expect(result.failure?.type, AdminRoleErrorType.invalidInput);
      expect(repo.decisions, isEmpty);
    });
  });

  group('Update service or package prices', () {
    test('success: updates a valid service price', () async {
      final repo = _FakeAdminRoleRepository();
      final service = AdminRoleService(repo);

      final result = await service.updatePrice('service-1', 250);

      expect(result.isSuccess, isTrue);
      expect(repo.prices['service-1'], 250);
    });

    test('invalid input: rejects zero, negative, or infinite prices', () async {
      final repo = _FakeAdminRoleRepository();
      final service = AdminRoleService(repo);

      final zero = await service.updatePrice('package-1', 0);
      final negative = await service.updatePrice('package-1', -5);
      final infinite = await service.updatePrice('package-1', double.infinity);

      expect(zero.failure?.type, AdminRoleErrorType.invalidInput);
      expect(negative.failure?.type, AdminRoleErrorType.invalidInput);
      expect(infinite.failure?.type, AdminRoleErrorType.invalidInput);
      expect(repo.prices, isEmpty);
    });
  });

  group('Add / edit / delete services or packages', () {
    test('success: adds, edits, and deletes a package', () async {
      final repo = _FakeAdminRoleRepository();
      final service = AdminRoleService(repo);
      const item = AdminPricedItem(
        id: 'package-2',
        name: 'Gold Plan',
        price: 2700,
        type: 'package',
      );

      final add = await service.addPricedItem(item);
      final edit = await service.editPricedItem(
        const AdminPricedItem(
          id: 'package-2',
          name: 'Gold Plan Plus',
          price: 3000,
          type: 'package',
        ),
      );
      final delete = await service.deletePricedItem('package-2');

      expect(add.isSuccess, isTrue);
      expect(edit.isSuccess, isTrue);
      expect(delete.isSuccess, isTrue);
      expect(repo.deletedIds, contains('package-2'));
    });

    test(
      'invalid input: rejects empty item name and empty delete id',
      () async {
        final repo = _FakeAdminRoleRepository();
        final service = AdminRoleService(repo);

        final add = await service.addPricedItem(
          const AdminPricedItem(
            id: 'service-2',
            name: '',
            price: 150,
            type: 'service',
          ),
        );
        final delete = await service.deletePricedItem('');

        expect(add.failure?.type, AdminRoleErrorType.invalidInput);
        expect(delete.failure?.type, AdminRoleErrorType.invalidInput);
        expect(repo.items, isEmpty);
        expect(repo.deletedIds, isEmpty);
      },
    );
  });

  group('View platform activity without app crash', () {
    test('success: returns platform activity logs', () async {
      final service = AdminRoleService(_FakeAdminRoleRepository());

      final result = await service.viewPlatformActivity();

      expect(result.isSuccess, isTrue);
      expect(result.data?.first.action, 'login');
    });

    test('empty data: returns empty activity logs without failure', () async {
      final service = AdminRoleService(
        _FakeAdminRoleRepository(activityResult: const []),
      );

      final result = await service.viewPlatformActivity();

      expect(result.isSuccess, isTrue);
      expect(result.data, isEmpty);
    });
  });
}

class _FakeAdminRoleRepository implements AdminRoleRepository {
  _FakeAdminRoleRepository({
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
        id: 'workshop-1',
        name: 'Cairo Auto Care',
        status: 'pending',
      ),
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
        intent: 'diagnostics_help',
        conversations: 20,
        failedAnswers: 1,
      ),
    ],
    this.activityResult = const [
      AdminActivity(id: 'log-1', action: 'login', details: 'Admin logged in'),
    ],
    this.throwOnAuthenticate = false,
    this.throwOnFetchBookings = false,
  });

  final AdminSession? authenticateResult;
  final AdminDashboardSnapshot? dashboardResult;
  final List<AdminWorkshopSummary>? workshopsResult;
  final List<AdminBookingSummary>? bookingsResult;
  final List<AdminChatbotMetric>? chatbotResult;
  final List<AdminActivity>? activityResult;
  final bool throwOnAuthenticate;
  final bool throwOnFetchBookings;

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
    if (throwOnAuthenticate) throw StateError('network failed');
    return authenticateResult;
  }

  @override
  Future<AdminDashboardSnapshot?> fetchDashboard() async => dashboardResult;

  @override
  Future<List<AdminWorkshopSummary>?> fetchWorkshops() async => workshopsResult;

  @override
  Future<List<AdminBookingSummary>?> fetchBookings() async {
    if (throwOnFetchBookings) throw StateError('network failed');
    return bookingsResult;
  }

  @override
  Future<List<AdminChatbotMetric>?> fetchChatbotMetrics() async =>
      chatbotResult;

  @override
  Future<List<AdminActivity>?> fetchActivity() async => activityResult;

  @override
  Future<bool> decideRegistration(
    String requestId,
    AdminRegistrationDecision decision,
  ) async {
    decisions[requestId] = decision;
    return true;
  }

  @override
  Future<bool> updatePrice(String itemId, double price) async {
    prices[itemId] = price;
    return true;
  }

  @override
  Future<bool> addPricedItem(AdminPricedItem item) async {
    items[item.id] = item;
    return true;
  }

  @override
  Future<bool> editPricedItem(AdminPricedItem item) async {
    items[item.id] = item;
    return true;
  }

  @override
  Future<bool> deletePricedItem(String itemId) async {
    deletedIds.add(itemId);
    items.remove(itemId);
    return true;
  }
}
