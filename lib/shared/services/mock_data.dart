import '../models/admin_models.dart';

class MockData {
  static String _password = 'admin123';
  static String? savedRole;
  static String? savedToken;

  static const superAdmin = SuperAdminUser(
    name: 'Salahny Super Admin',
    email: 'admin@salahny.com',
  );

  static final drivers = <DriverUser>[
    const DriverUser(
      id: 'driver-1',
      name: 'Mariam Yasser',
      email: 'mariam@example.com',
      phone: '01012345678',
      totalBookings: 4,
      walletBalance: 250,
    ),
    const DriverUser(
      id: 'driver-2',
      name: 'Ahmed Ali',
      email: 'ahmed@example.com',
      phone: '01098765432',
      status: AdminAccountStatus.pending,
    ),
  ];

  static final adminWorkshops = <WorkshopUser>[
    const WorkshopUser(
      id: 'workshop-1',
      name: 'Cairo Auto Care',
      email: 'care@example.com',
      phone: '01111111111',
      specialty: 'Engine',
      address: 'Nasr City',
      status: AdminAccountStatus.pending,
      totalJobs: 8,
      revenue: 1250,
    ),
    const WorkshopUser(
      id: 'workshop-2',
      name: 'Alex Garage',
      email: 'alex@example.com',
      phone: '01222222222',
      specialty: 'Tyres',
      address: 'Alexandria',
      isVerified: true,
      totalJobs: 12,
      revenue: 2100,
    ),
  ];

  static final adminBookings = <AdminBooking>[
    const AdminBooking(
      id: 'booking-1',
      serviceName: 'Oil Change',
      driverName: 'Mariam',
      workshopName: 'Cairo Auto Care',
      status: AdminBookingStatus.active,
      total: 450,
      date: '2026-05-01',
      time: '10:00',
      paymentMethod: 'Cash',
    ),
  ];

  static final managedServices = <ManagedService>[
    const ManagedService(
      id: 'service-1',
      name: 'Oil Change',
      category: 'Maintenance',
      description: 'Replace engine oil and inspect filters.',
      emoji: 'S',
      price: 150,
      durationMins: 45,
    ),
  ];

  static final managedPackages = <ManagedPackage>[
    const ManagedPackage(
      id: 'package-1',
      name: 'Gold',
      tagline: 'Priority diagnostics and service discounts.',
      duration: 'month',
      price: 500,
      originalPrice: 650,
      features: ['Priority booking', 'Diagnostics report', '10% service discount'],
    ),
  ];

  static final activityLogs = <AdminActivityLog>[
    AdminActivityLog(
      id: 'log-1',
      actor: superAdmin.email,
      action: 'login',
      target: 'self',
      details: 'Admin logged in',
      timestamp: DateTime(2026, 5, 1, 10),
    ),
  ];

  static AdminSettingsData adminSettings = const AdminSettingsData(
    privacyPolicy: 'Default privacy policy.',
    aboutContent: 'Salahny connects drivers with workshops.',
    announcementTitle: 'Welcome',
    announcementBody: 'Platform is running normally.',
    notificationsEnabled: true,
  );

  static List<DriverUser> get pendingDrivers =>
      drivers.where((item) => item.status == AdminAccountStatus.pending).toList();
  static List<WorkshopUser> get pendingWorkshops => adminWorkshops
      .where((item) => item.status == AdminAccountStatus.pending)
      .toList();
  static int get pendingApprovalsCount =>
      pendingDrivers.length + pendingWorkshops.length;
  static double get totalRevenue =>
      adminBookings.fold(0, (sum, booking) => sum + booking.total);

  static bool validateAdminCredentials(String email, String password) =>
      email == superAdmin.email && password == _password;
  static Future<void> saveRole(String role) async => savedRole = role;
  static Future<void> saveToken(String token) async => savedToken = token;
  static Future<void> logout() async {
    savedRole = null;
    savedToken = null;
  }

  static Future<void> changeAdminPassword(String password) async {
    _password = password;
  }

  static void updateAdminSettings(AdminSettingsData settings) {
    adminSettings = settings;
  }

  static void _replaceDriver(String id, DriverUser Function(DriverUser) update) {
    final index = drivers.indexWhere((item) => item.id == id);
    if (index != -1) drivers[index] = update(drivers[index]);
  }

  static void _replaceWorkshop(
      String id, WorkshopUser Function(WorkshopUser) update) {
    final index = adminWorkshops.indexWhere((item) => item.id == id);
    if (index != -1) adminWorkshops[index] = update(adminWorkshops[index]);
  }

  static void approveDriver(String id) =>
      _replaceDriver(id, (item) => item.copyWith(status: AdminAccountStatus.active));
  static void rejectDriver(String id) =>
      _replaceDriver(id, (item) => item.copyWith(status: AdminAccountStatus.rejected));
  static void suspendDriver(String id) => _replaceDriver(
      id, (item) => item.copyWith(status: AdminAccountStatus.suspended));
  static void activateDriver(String id) =>
      _replaceDriver(id, (item) => item.copyWith(status: AdminAccountStatus.active));
  static void deleteDriver(String id) => drivers.removeWhere((item) => item.id == id);

  static void approveWorkshop(String id) => _replaceWorkshop(
      id, (item) => item.copyWith(status: AdminAccountStatus.active, isVerified: true));
  static void rejectWorkshop(String id) => _replaceWorkshop(
      id, (item) => item.copyWith(status: AdminAccountStatus.rejected));
  static void verifyWorkshop(String id) =>
      _replaceWorkshop(id, (item) => item.copyWith(isVerified: true));
  static void suspendWorkshop(String id) => _replaceWorkshop(
      id, (item) => item.copyWith(status: AdminAccountStatus.suspended));
  static void activateWorkshop(String id) => _replaceWorkshop(
      id, (item) => item.copyWith(status: AdminAccountStatus.active));
  static void deleteWorkshop(String id) =>
      adminWorkshops.removeWhere((item) => item.id == id);

  static AdminBooking? bookingById(String id) {
    for (final booking in adminBookings) {
      if (booking.id == id) return booking;
    }
    return null;
  }

  static void updateBookingStatus(String id, AdminBookingStatus status) {
    final index = adminBookings.indexWhere((item) => item.id == id);
    if (index != -1) adminBookings[index] = adminBookings[index].copyWith(status: status);
  }

  static void addService(ManagedService service) => managedServices.add(service);
  static void updateService(ManagedService service) {
    final index = managedServices.indexWhere((item) => item.id == service.id);
    if (index != -1) managedServices[index] = service;
  }
  static void toggleService(String id) {
    final index = managedServices.indexWhere((item) => item.id == id);
    if (index != -1) {
      managedServices[index] =
          managedServices[index].copyWith(isEnabled: !managedServices[index].isEnabled);
    }
  }
  static void deleteService(String id) =>
      managedServices.removeWhere((item) => item.id == id);

  static void addPackage(ManagedPackage pkg) => managedPackages.add(pkg);
  static void updatePackage(ManagedPackage pkg) {
    final index = managedPackages.indexWhere((item) => item.id == pkg.id);
    if (index != -1) managedPackages[index] = pkg;
  }
  static void togglePackage(String id) {
    final index = managedPackages.indexWhere((item) => item.id == id);
    if (index != -1) {
      managedPackages[index] =
          managedPackages[index].copyWith(isEnabled: !managedPackages[index].isEnabled);
    }
  }
  static void deletePackage(String id) =>
      managedPackages.removeWhere((item) => item.id == id);
}
