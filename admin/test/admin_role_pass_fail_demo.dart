import 'package:flutter_test/flutter_test.dart';
import 'package:qa/features/admin/admin_role_service.dart';

void main() {
  test('PASS demo: valid admin credentials return admin session', () async {
    final service = AdminRoleService(_PassFailDemoRepository());

    final result = await service.login(
      const AdminCredentials(email: 'admin@salahny.com', password: 'admin123'),
    );

    expect(result.isSuccess, isTrue);
    expect(result.data?.role, 'admin');
  });

  test('FAIL demo: wrong expected token shows a failed test result', () async {
    final service = AdminRoleService(_PassFailDemoRepository());

    final result = await service.login(
      const AdminCredentials(email: 'admin@salahny.com', password: 'admin123'),
    );

    expect(result.data?.token, 'wrong-token');
  });
}

class _PassFailDemoRepository implements AdminRoleRepository {
  @override
  Future<AdminSession?> authenticate(AdminCredentials credentials) async {
    return const AdminSession(token: 'real-admin-token');
  }

  @override
  Future<AdminDashboardSnapshot?> fetchDashboard() async => null;

  @override
  Future<List<AdminWorkshopSummary>?> fetchWorkshops() async => const [];

  @override
  Future<List<AdminBookingSummary>?> fetchBookings() async => const [];

  @override
  Future<List<AdminChatbotMetric>?> fetchChatbotMetrics() async => const [];

  @override
  Future<List<AdminActivity>?> fetchActivity() async => const [];

  @override
  Future<bool> decideRegistration(
    String requestId,
    AdminRegistrationDecision decision,
  ) async {
    return true;
  }

  @override
  Future<bool> updatePrice(String itemId, double price) async => true;

  @override
  Future<bool> addPricedItem(AdminPricedItem item) async => true;

  @override
  Future<bool> editPricedItem(AdminPricedItem item) async => true;

  @override
  Future<bool> deletePricedItem(String itemId) async => true;
}
