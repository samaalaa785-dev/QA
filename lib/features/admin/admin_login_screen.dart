import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_error_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/services/mock_data.dart';
import '../../shared/widgets/app_widgets.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'admin@salahny.com');
  final _passwordCtrl = TextEditingController(text: 'admin123');
  bool _loading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final ok = await AppErrorHandler.guard<bool>(
      context,
      () async {
        await Future.delayed(const Duration(milliseconds: 900));
        final valid = MockData.validateAdminCredentials(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
        if (!valid) {
          throw const AppException('Invalid Super Admin credentials');
        }
        await MockData.saveRole('admin');
        await MockData.saveToken(
          'admin_token_${DateTime.now().millisecondsSinceEpoch}',
        );
        return true;
      },
      fallbackMessage: 'Could not sign in as Super Admin.',
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok == true) {
      Navigator.pushNamedAndRemoveUntil(context, R.saDashboard, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AC.s2,
                      borderRadius: Rd.mdA,
                      border: Border.all(color: AC.border),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AC.t1,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                ACard(
                  glow: true,
                  glowColor: AC.gold,
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AC.goldGrad,
                          borderRadius: Rd.lgA,
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: AC.bg,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Super Admin Access',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AC.t1,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Private platform control panel',
                              style: TextStyle(fontSize: 12, color: AC.t3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                AppField(
                  label: 'Admin Email',
                  hint: 'admin@salahny.com',
                  ctrl: _emailCtrl,
                  keyboard: TextInputType.emailAddress,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return 'Enter the admin email';
                    if (!email.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppField(
                  label: 'Password',
                  hint: 'Enter password',
                  ctrl: _passwordCtrl,
                  obscure: !_showPassword,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Enter password' : null,
                  suffix: GestureDetector(
                    onTap: () => setState(() => _showPassword = !_showPassword),
                    child: Icon(
                      _showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AC.t3,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                AppBtn(
                  label: 'Access Admin Dashboard',
                  gold: true,
                  loading: _loading,
                  onTap: _submit,
                  icon: const Icon(
                    Icons.lock_open_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Only authorized platform owners can access this panel.',
                  style: TextStyle(fontSize: 12, color: AC.t3, height: 1.5),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
