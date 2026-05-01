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
      title: 'Salahny',
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
      initialRoute: R.splash,
      routes: {
        R.splash: (_) => const SplashScreen(),
        R.roleSelect: (_) => const RoleSelectionScreen(),
        R.driverHome: (_) => const RoleHomeScreen(
              title: 'Driver',
              icon: Icons.drive_eta_rounded,
              accent: AC.info,
            ),
        R.workshopHome: (_) => const RoleHomeScreen(
              title: 'Workshop',
              icon: Icons.garage_rounded,
              accent: AC.gold,
            ),
        R.aiHome: (_) => const RoleHomeScreen(
              title: 'AI Diagnostics',
              icon: Icons.smart_toy_rounded,
              accent: AC.success,
            ),
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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, R.roleSelect);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AC.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.car_repair_rounded, color: AC.red, size: 64),
            SizedBox(height: 18),
            Text(
              'Salahny',
              style: TextStyle(
                color: AC.t1,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Smart vehicle service platform',
              style: TextStyle(color: AC.t3, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: AC.bg,
        elevation: 0,
        title: const Text(
          'Choose Role',
          style: TextStyle(color: AC.t1, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Continue as',
            style: TextStyle(
              color: AC.t1,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          RoleTile(
            title: 'Driver',
            subtitle: 'Book services, track requests, and manage vehicles',
            icon: Icons.drive_eta_rounded,
            color: AC.info,
            onTap: () => Navigator.pushNamed(context, R.driverHome),
          ),
          RoleTile(
            title: 'Workshop',
            subtitle: 'Manage bookings, jobs, diagnostics, and earnings',
            icon: Icons.garage_rounded,
            color: AC.gold,
            onTap: () => Navigator.pushNamed(context, R.workshopHome),
          ),
          RoleTile(
            title: 'AI Diagnostics',
            subtitle: 'Open diagnostic support and vehicle insights',
            icon: Icons.smart_toy_rounded,
            color: AC.success,
            onTap: () => Navigator.pushNamed(context, R.aiHome),
          ),
          RoleTile(
            title: 'Admin',
            subtitle: 'Access platform management and admin tests',
            icon: Icons.admin_panel_settings_rounded,
            color: AC.red,
            onTap: () => Navigator.pushNamed(context, R.saLogin),
          ),
        ],
      ),
    );
  }
}

class RoleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const RoleTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AC.s1,
        borderRadius: Rd.mdA,
        child: InkWell(
          onTap: onTap,
          borderRadius: Rd.mdA,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: Rd.mdA,
              border: Border.all(color: AC.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: Rd.mdA,
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AC.t1,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: AC.t3, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AC.t4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RoleHomeScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;

  const RoleHomeScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: AC.bg,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(color: AC.t1, fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: accent, size: 56),
            const SizedBox(height: 16),
            Text(
              '$title Home',
              style: const TextStyle(
                color: AC.t1,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Role selected successfully',
              style: TextStyle(color: AC.t3),
            ),
          ],
        ),
      ),
    );
  }
}
