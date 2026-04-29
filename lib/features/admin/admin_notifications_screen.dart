// lib/features/admin/admin_notifications_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_widgets.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});
  @override
  State<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final _titleCtrl   = TextEditingController();
  final _bodyCtrl    = TextEditingController();
  String _target     = 'All Users';
  bool   _sending    = false;

  static const _targets = ['All Users', 'Drivers Only', 'Workshops Only', 'Premium Users'];

  final List<_NotifData> _history = [
    _NotifData(title:'App Update Available', body:'Version 1.1 is now live.',
        target:'All Users', time:'Today 10:30 AM', reach:1248),
    _NotifData(title:'New Package Deal', body:'Get 20% off Gold Plan this weekend!',
        target:'Drivers Only', time:'Yesterday 3:00 PM', reach:892),
    _NotifData(title:'System Maintenance', body:'Brief downtime on Dec 25, 2–3 AM.',
        target:'All Users', time:'Dec 18, 2024', reach:1248),
    _NotifData(title:'New Feature: AI Diagnostics', body:'Try our new OBD fault prediction.',
        target:'Premium Users', time:'Dec 15, 2024', reach:132),
  ];

  Future<void> _send() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _history.insert(0, _NotifData(
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        target: _target,
        time: 'Just now',
        reach: _target == 'All Users' ? 1248 : 450,
      ));
      _titleCtrl.clear();
      _bodyCtrl.clear();
      _sending = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification sent successfully ✓'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AC.success));
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: AC.s1,
        title: const Text('Notifications', style: TextStyle(fontSize: 18,
            fontWeight: FontWeight.w800, color: AC.t1)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AC.border)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [

          // ── Compose card ──────────────────────────
          ACard(glow: true, glowColor: AC.red,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(children: [
                Container(width: 36, height: 36,
                  decoration: BoxDecoration(gradient: AC.redGrad,
                      borderRadius: Rd.smA),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 16)),
                const SizedBox(width: 10),
                const Text('Send Notification', style: TextStyle(fontSize: 15,
                    fontWeight: FontWeight.w800, color: AC.t1)),
              ]),
              const SizedBox(height: 16),

              // Target
              const Text('TARGET AUDIENCE', style: TextStyle(fontSize: 10,
                  fontWeight: FontWeight.w700, color: AC.t3, letterSpacing: 1)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                children: _targets.map((t) => GestureDetector(
                  onTap: () => setState(() => _target = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: _target == t
                          ? AC.red.withOpacity(0.15) : AC.s3,
                      borderRadius: Rd.fullA,
                      border: Border.all(color: _target == t
                          ? AC.red.withOpacity(0.5) : AC.border),
                    ),
                    child: Text(t, style: TextStyle(fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _target == t ? AC.red : AC.t2)),
                  ),
                )).toList()),

              const SizedBox(height: 14),

              // Title
              const Text('TITLE', style: TextStyle(fontSize: 10,
                  fontWeight: FontWeight.w700, color: AC.t3, letterSpacing: 1)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                style: const TextStyle(color: AC.t1, fontSize: 14),
                decoration: _inputDeco('e.g. New Feature Available'),
              ),
              const SizedBox(height: 12),

              // Body
              const Text('MESSAGE', style: TextStyle(fontSize: 10,
                  fontWeight: FontWeight.w700, color: AC.t3, letterSpacing: 1)),
              const SizedBox(height: 8),
              TextField(
                controller: _bodyCtrl,
                maxLines: 3,
                style: const TextStyle(color: AC.t1, fontSize: 14),
                decoration: _inputDeco('Write your message here...'),
              ),
              const SizedBox(height: 16),

              SizedBox(width: double.infinity,
                child: AppBtn(
                  label: _sending ? 'Sending...' : 'Send to $_target',
                  loading: _sending,
                  onTap: _sending ? null : _send,
                )),
            ])),

          const SizedBox(height: 24),

          // ── History ───────────────────────────────
          const Text('Sent History', style: TextStyle(fontSize: 15,
              fontWeight: FontWeight.w800, color: AC.t1, letterSpacing: -0.3)),
          const SizedBox(height: 12),

          ..._history.map((n) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _NotifRow(notif: n),
          )),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AC.t3, fontSize: 13),
    filled: true, fillColor: AC.s3,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: Rd.mdA,
        borderSide: const BorderSide(color: AC.border)),
    enabledBorder: OutlineInputBorder(borderRadius: Rd.mdA,
        borderSide: const BorderSide(color: AC.border)),
    focusedBorder: OutlineInputBorder(borderRadius: Rd.mdA,
        borderSide: const BorderSide(color: AC.red, width: 1.5)),
  );
}

class _NotifRow extends StatelessWidget {
  final _NotifData notif;
  const _NotifRow({required this.notif});
  @override
  Widget build(BuildContext context) => ACard(padding: const EdgeInsets.all(14),
    child: Row(children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(color: AC.red.withOpacity(0.12),
            borderRadius: Rd.mdA),
        child: const Icon(Icons.notifications_rounded,
            color: AC.red, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Text(notif.title, style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w700, color: AC.t1)),
        const SizedBox(height: 2),
        Text(notif.body, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AC.t2)),
        const SizedBox(height: 4),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(
              horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: AC.info.withOpacity(0.12),
                borderRadius: Rd.fullA),
            child: Text(notif.target, style: const TextStyle(fontSize: 9,
                fontWeight: FontWeight.w700, color: AC.info))),
          const SizedBox(width: 6),
          Text('${notif.reach} reached',
              style: const TextStyle(fontSize: 10, color: AC.t3)),
        ]),
      ])),
      Text(notif.time, style: const TextStyle(fontSize: 10, color: AC.t3)),
    ]),
  );
}

class _NotifData {
  final String title, body, target, time;
  final int reach;
  const _NotifData({required this.title, required this.body,
      required this.target, required this.time, required this.reach});
}
