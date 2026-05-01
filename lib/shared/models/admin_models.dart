enum AdminAccountStatus {
  pending('Pending'),
  active('Active'),
  suspended('Suspended'),
  rejected('Rejected');

  final String label;
  const AdminAccountStatus(this.label);
}

enum AdminBookingStatus {
  pending('Pending'),
  active('Active'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;
  const AdminBookingStatus(this.label);
}

class SuperAdminUser {
  final String name;
  final String email;
  const SuperAdminUser({required this.name, required this.email});
}

class DriverUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final AdminAccountStatus status;
  final int totalBookings;
  final double walletBalance;

  const DriverUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.status = AdminAccountStatus.active,
    this.totalBookings = 0,
    this.walletBalance = 0,
  });

  DriverUser copyWith({AdminAccountStatus? status}) => DriverUser(
        id: id,
        name: name,
        email: email,
        phone: phone,
        status: status ?? this.status,
        totalBookings: totalBookings,
        walletBalance: walletBalance,
      );
}

class WorkshopUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String specialty;
  final String address;
  final AdminAccountStatus status;
  final bool isVerified;
  final int totalJobs;
  final double revenue;

  const WorkshopUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.address,
    this.status = AdminAccountStatus.active,
    this.isVerified = false,
    this.totalJobs = 0,
    this.revenue = 0,
  });

  WorkshopUser copyWith({
    AdminAccountStatus? status,
    bool? isVerified,
  }) =>
      WorkshopUser(
        id: id,
        name: name,
        email: email,
        phone: phone,
        specialty: specialty,
        address: address,
        status: status ?? this.status,
        isVerified: isVerified ?? this.isVerified,
        totalJobs: totalJobs,
        revenue: revenue,
      );
}

class AdminBooking {
  final String id;
  final String serviceName;
  final String driverName;
  final String workshopName;
  final AdminBookingStatus status;
  final double total;
  final String date;
  final String time;
  final String paymentMethod;

  const AdminBooking({
    required this.id,
    required this.serviceName,
    required this.driverName,
    required this.workshopName,
    required this.status,
    required this.total,
    required this.date,
    required this.time,
    required this.paymentMethod,
  });

  AdminBooking copyWith({AdminBookingStatus? status}) => AdminBooking(
        id: id,
        serviceName: serviceName,
        driverName: driverName,
        workshopName: workshopName,
        status: status ?? this.status,
        total: total,
        date: date,
        time: time,
        paymentMethod: paymentMethod,
      );
}

class ManagedService {
  final String id;
  final String name;
  final String category;
  final String description;
  final String emoji;
  final double price;
  final int durationMins;
  final bool isPopular;
  final bool isEnabled;

  const ManagedService({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.emoji,
    required this.price,
    required this.durationMins,
    this.isPopular = false,
    this.isEnabled = true,
  });

  ManagedService copyWith({bool? isEnabled}) => ManagedService(
        id: id,
        name: name,
        category: category,
        description: description,
        emoji: emoji,
        price: price,
        durationMins: durationMins,
        isPopular: isPopular,
        isEnabled: isEnabled ?? this.isEnabled,
      );
}

class ManagedPackage {
  final String id;
  final String name;
  final String tagline;
  final String duration;
  final double price;
  final double originalPrice;
  final List<String> features;
  final bool isPopular;
  final bool isEnabled;

  const ManagedPackage({
    required this.id,
    required this.name,
    required this.tagline,
    required this.duration,
    required this.price,
    required this.originalPrice,
    required this.features,
    this.isPopular = false,
    this.isEnabled = true,
  });

  ManagedPackage copyWith({bool? isEnabled}) => ManagedPackage(
        id: id,
        name: name,
        tagline: tagline,
        duration: duration,
        price: price,
        originalPrice: originalPrice,
        features: features,
        isPopular: isPopular,
        isEnabled: isEnabled ?? this.isEnabled,
      );
}

class AdminActivityLog {
  final String id;
  final String actor;
  final String action;
  final String target;
  final String details;
  final DateTime timestamp;

  const AdminActivityLog({
    required this.id,
    required this.actor,
    required this.action,
    required this.target,
    required this.details,
    required this.timestamp,
  });
}

class AdminSettingsData {
  final String privacyPolicy;
  final String aboutContent;
  final String announcementTitle;
  final String announcementBody;
  final bool notificationsEnabled;

  const AdminSettingsData({
    required this.privacyPolicy,
    required this.aboutContent,
    required this.announcementTitle,
    required this.announcementBody,
    required this.notificationsEnabled,
  });
}
