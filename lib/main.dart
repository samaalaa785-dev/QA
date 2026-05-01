import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/activity_logs_screen.dart';
import 'features/admin/admin_dashboard_screen.dart';
import 'features/admin/admin_login_screen.dart';
import 'features/admin/admin_settings_screen.dart';
import 'features/admin/bookings_management_screen.dart';
import 'features/admin/drivers_management_screen.dart';
import 'features/admin/packages_management_screen.dart';
import 'features/admin/pending_approvals_screen.dart';
import 'features/admin/services_management_screen.dart';
import 'features/admin/workshops_management_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salahny Admin',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AC.bg,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AC.s1,
          labelStyle: const TextStyle(color: AC.t3),
          hintStyle: const TextStyle(color: AC.t4),
          enabledBorder: OutlineInputBorder(
            borderRadius: Rd.mdA,
            borderSide: const BorderSide(color: AC.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: Rd.mdA,
            borderSide: const BorderSide(color: AC.red),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: Rd.mdA,
            borderSide: const BorderSide(color: AC.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: Rd.mdA,
            borderSide: const BorderSide(color: AC.red),
          ),
        ),
      ),
      initialRoute: R.saLogin,
      routes: {
        R.roleSelect: (_) => const AdminLoginScreen(),
        R.saLogin: (_) => const AdminLoginScreen(),
        R.saDashboard: (_) => const SuperAdminDashboardScreen(),
        R.saApprovals: (_) => const PendingApprovalsScreen(),
        R.saServices: (_) => const ServicesManagementScreen(),
        R.saDrivers: (_) => const DriversManagementScreen(),
        R.saWorkshops: (_) => const WorkshopsManagementScreen(),
        R.saBookings: (_) => const BookingsManagementScreen(),
        R.saPackages: (_) => const PackagesManagementScreen(),
        R.saLogs: (_) => const ActivityLogsScreen(),
        R.saSettings: (_) => const AdminSettingsScreen(),
      },
    );
  }
}
