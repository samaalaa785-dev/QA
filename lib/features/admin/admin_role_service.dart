enum AdminRoleErrorType { invalidInput, authenticationFailed, failedResponse }

class AdminRoleFailure {
  final AdminRoleErrorType type;
  final String message;

  const AdminRoleFailure(this.type, this.message);
}

class AdminRoleResult<T> {
  final T? data;
  final AdminRoleFailure? failure;

  const AdminRoleResult.success(this.data) : failure = null;
  const AdminRoleResult.failure(this.failure) : data = null;

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;
}

class AdminCredentials {
  final String email;
  final String password;

  const AdminCredentials({required this.email, required this.password});
}

class AdminSession {
  final String token;
  final String role;

  const AdminSession({required this.token, this.role = 'admin'});
}

class AdminDashboardSnapshot {
  final int drivers;
  final int workshops;
  final int bookings;
  final double revenue;
  final int pendingApprovals;

  const AdminDashboardSnapshot({
    required this.drivers,
    required this.workshops,
    required this.bookings,
    required this.revenue,
    required this.pendingApprovals,
  });
}

class AdminWorkshopSummary {
  final String id;
  final String name;
  final String status;
  final bool isVerified;

  const AdminWorkshopSummary({
    required this.id,
    required this.name,
    required this.status,
    this.isVerified = false,
  });
}

class AdminBookingSummary {
  final String id;
  final String driverName;
  final String workshopName;
  final String status;
  final double total;

  const AdminBookingSummary({
    required this.id,
    required this.driverName,
    required this.workshopName,
    required this.status,
    required this.total,
  });
}

class AdminChatbotMetric {
  final String intent;
  final int conversations;
  final int failedAnswers;

  const AdminChatbotMetric({
    required this.intent,
    required this.conversations,
    required this.failedAnswers,
  });
}

class AdminRegistrationRequest {
  final String id;
  final String role;
  final String applicantName;
  final String status;

  const AdminRegistrationRequest({
    required this.id,
    required this.role,
    required this.applicantName,
    this.status = 'pending',
  });
}

class AdminPricedItem {
  final String id;
  final String name;
  final double price;
  final String type;
  final bool isEnabled;

  const AdminPricedItem({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    this.isEnabled = true,
  });
}

class AdminActivity {
  final String id;
  final String action;
  final String details;

  const AdminActivity({
    required this.id,
    required this.action,
    required this.details,
  });
}

enum AdminRegistrationDecision { accept, reject }

abstract class AdminRoleRepository {
  Future<AdminSession?> authenticate(AdminCredentials credentials);
  Future<AdminDashboardSnapshot?> fetchDashboard();
  Future<List<AdminWorkshopSummary>?> fetchWorkshops();
  Future<List<AdminBookingSummary>?> fetchBookings();
  Future<List<AdminChatbotMetric>?> fetchChatbotMetrics();
  Future<List<AdminActivity>?> fetchActivity();
  Future<bool> decideRegistration(
    String requestId,
    AdminRegistrationDecision decision,
  );
  Future<bool> updatePrice(String itemId, double price);
  Future<bool> addPricedItem(AdminPricedItem item);
  Future<bool> editPricedItem(AdminPricedItem item);
  Future<bool> deletePricedItem(String itemId);
}

class AdminRoleService {
  final AdminRoleRepository _repository;

  const AdminRoleService(this._repository);

  Future<AdminRoleResult<AdminSession>> login(
    AdminCredentials credentials,
  ) async {
    final email = credentials.email.trim();
    if (email.isEmpty || credentials.password.isEmpty) {
      return const AdminRoleResult.failure(
        AdminRoleFailure(
          AdminRoleErrorType.invalidInput,
          'Admin email and password are required.',
        ),
      );
    }
    if (!email.contains('@')) {
      return const AdminRoleResult.failure(
        AdminRoleFailure(
          AdminRoleErrorType.invalidInput,
          'Admin email must be valid.',
        ),
      );
    }

    try {
      final session = await _repository.authenticate(
        AdminCredentials(email: email, password: credentials.password),
      );
      if (session == null || session.token.trim().isEmpty) {
        return const AdminRoleResult.failure(
          AdminRoleFailure(
            AdminRoleErrorType.authenticationFailed,
            'Invalid admin credentials.',
          ),
        );
      }
      return AdminRoleResult.success(session);
    } catch (_) {
      return const AdminRoleResult.failure(
        AdminRoleFailure(
          AdminRoleErrorType.failedResponse,
          'Admin authentication failed.',
        ),
      );
    }
  }

  Future<AdminRoleResult<AdminDashboardSnapshot>> loadDashboard() {
    return _loadRequired(
      _repository.fetchDashboard,
      'Admin dashboard could not be loaded.',
    );
  }

  Future<AdminRoleResult<List<AdminWorkshopSummary>>> monitorWorkshops() {
    return _loadList(
      _repository.fetchWorkshops,
      'Admin workshops could not be loaded.',
    );
  }

  Future<AdminRoleResult<List<AdminBookingSummary>>> monitorBookings() {
    return _loadList(
      _repository.fetchBookings,
      'Admin bookings could not be loaded.',
    );
  }

  Future<AdminRoleResult<List<AdminChatbotMetric>>> monitorChatbotData() {
    return _loadList(
      _repository.fetchChatbotMetrics,
      'Admin chatbot data could not be loaded.',
    );
  }

  Future<AdminRoleResult<List<AdminActivity>>> viewPlatformActivity() {
    return _loadList(
      _repository.fetchActivity,
      'Admin platform activity could not be loaded.',
    );
  }

  Future<AdminRoleResult<bool>> decideRegistration(
    String requestId,
    AdminRegistrationDecision decision,
  ) {
    if (requestId.trim().isEmpty) {
      return _invalidAction('Registration request id is required.');
    }
    return _runBoolAction(
      () => _repository.decideRegistration(requestId.trim(), decision),
      'Registration decision was not saved.',
    );
  }

  Future<AdminRoleResult<bool>> updatePrice(String itemId, double price) {
    if (itemId.trim().isEmpty) {
      return _invalidAction('Service or package id is required.');
    }
    if (!_isValidPrice(price)) {
      return _invalidAction('Service or package price must be greater than 0.');
    }
    return _runBoolAction(
      () => _repository.updatePrice(itemId.trim(), price),
      'Service or package price was not updated.',
    );
  }

  Future<AdminRoleResult<bool>> addPricedItem(AdminPricedItem item) async {
    final failure = _validatePricedItem(item);
    if (failure != null) return AdminRoleResult<bool>.failure(failure);
    return _runBoolAction(
      () => _repository.addPricedItem(_normalizedItem(item)),
      'Service or package was not added.',
    );
  }

  Future<AdminRoleResult<bool>> editPricedItem(AdminPricedItem item) async {
    final failure = _validatePricedItem(item);
    if (failure != null) return AdminRoleResult<bool>.failure(failure);
    return _runBoolAction(
      () => _repository.editPricedItem(_normalizedItem(item)),
      'Service or package was not updated.',
    );
  }

  Future<AdminRoleResult<bool>> deletePricedItem(String itemId) {
    if (itemId.trim().isEmpty) {
      return _invalidAction('Service or package id is required.');
    }
    return _runBoolAction(
      () => _repository.deletePricedItem(itemId.trim()),
      'Service or package was not deleted.',
    );
  }

  Future<AdminRoleResult<T>> _loadRequired<T>(
    Future<T?> Function() loader,
    String message,
  ) async {
    try {
      final data = await loader();
      if (data == null) {
        return AdminRoleResult.failure(
          AdminRoleFailure(AdminRoleErrorType.failedResponse, message),
        );
      }
      return AdminRoleResult.success(data);
    } catch (_) {
      return AdminRoleResult.failure(
        AdminRoleFailure(AdminRoleErrorType.failedResponse, message),
      );
    }
  }

  Future<AdminRoleResult<List<T>>> _loadList<T>(
    Future<List<T>?> Function() loader,
    String message,
  ) async {
    try {
      final data = await loader();
      if (data == null) {
        return AdminRoleResult.failure(
          AdminRoleFailure(AdminRoleErrorType.failedResponse, message),
        );
      }
      return AdminRoleResult.success(List<T>.unmodifiable(data));
    } catch (_) {
      return AdminRoleResult.failure(
        AdminRoleFailure(AdminRoleErrorType.failedResponse, message),
      );
    }
  }

  Future<AdminRoleResult<bool>> _runBoolAction(
    Future<bool> Function() action,
    String message,
  ) async {
    try {
      final saved = await action();
      if (!saved) {
        return AdminRoleResult.failure(
          AdminRoleFailure(AdminRoleErrorType.failedResponse, message),
        );
      }
      return const AdminRoleResult.success(true);
    } catch (_) {
      return AdminRoleResult.failure(
        AdminRoleFailure(AdminRoleErrorType.failedResponse, message),
      );
    }
  }

  Future<AdminRoleResult<bool>> _invalidAction(String message) async {
    return AdminRoleResult.failure(
      AdminRoleFailure(AdminRoleErrorType.invalidInput, message),
    );
  }

  AdminRoleFailure? _validatePricedItem(AdminPricedItem item) {
    if (item.id.trim().isEmpty) {
      return const AdminRoleFailure(
        AdminRoleErrorType.invalidInput,
        'Service or package id is required.',
      );
    }
    if (item.name.trim().isEmpty) {
      return const AdminRoleFailure(
        AdminRoleErrorType.invalidInput,
        'Service or package name is required.',
      );
    }
    if (item.type.trim().isEmpty) {
      return const AdminRoleFailure(
        AdminRoleErrorType.invalidInput,
        'Service or package type is required.',
      );
    }
    if (!_isValidPrice(item.price)) {
      return const AdminRoleFailure(
        AdminRoleErrorType.invalidInput,
        'Service or package price must be greater than 0.',
      );
    }
    return null;
  }

  AdminPricedItem _normalizedItem(AdminPricedItem item) {
    return AdminPricedItem(
      id: item.id.trim(),
      name: item.name.trim(),
      price: item.price,
      type: item.type.trim(),
      isEnabled: item.isEnabled,
    );
  }

  bool _isValidPrice(double price) => price.isFinite && price > 0;
}
