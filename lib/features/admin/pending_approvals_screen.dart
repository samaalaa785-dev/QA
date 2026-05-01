import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/services/mock_data.dart';
import '../../shared/widgets/app_widgets.dart';
import '_admin_shared.dart';

class PendingApprovalsScreen extends StatelessWidget {
  const PendingApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) => const AdminShell(
        title: 'Pending Approvals',
        child: PendingApprovalsView(),
      );
}

class PendingApprovalsView extends StatefulWidget {
  const PendingApprovalsView({super.key});

  @override
  State<PendingApprovalsView> createState() => _PendingApprovalsViewState();
}

class _PendingApprovalsViewState extends State<PendingApprovalsView> {
  String _tab = 'Drivers';

  @override
  Widget build(BuildContext context) {
    final pendingDrivers = MockData.pendingDrivers;
    final pendingWorkshops = MockData.pendingWorkshops;
    final showingDrivers = _tab == 'Drivers';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AdminFilterPill(
                  label: 'Drivers (${pendingDrivers.length})',
                  selected: showingDrivers,
                  onTap: () => setState(() => _tab = 'Drivers'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AdminFilterPill(
                  label: 'Workshops (${pendingWorkshops.length})',
                  selected: !showingDrivers,
                  onTap: () => setState(() => _tab = 'Workshops'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (showingDrivers)
            ...pendingDrivers.map(
              (driver) => _ApprovalCard(
                title: driver.name,
                subtitle: '${driver.email}\n${driver.phone}',
                onApprove: () => setState(() => MockData.approveDriver(driver.id)),
                onReject: () => setState(() => MockData.rejectDriver(driver.id)),
              ),
            )
          else
            ...pendingWorkshops.map(
              (workshop) => _ApprovalCard(
                title: workshop.name,
                subtitle: '${workshop.specialty}\n${workshop.address}',
                onApprove: () =>
                    setState(() => MockData.approveWorkshop(workshop.id)),
                onReject: () =>
                    setState(() => MockData.rejectWorkshop(workshop.id)),
              ),
            ),
          if ((showingDrivers && pendingDrivers.isEmpty) ||
              (!showingDrivers && pendingWorkshops.isEmpty))
            const Padding(
              padding: EdgeInsets.only(top: 30),
              child: EmptyState(
                icon: 'OK',
                title: 'No pending approvals',
                sub: 'Everything in this queue has already been reviewed.',
              ),
            ),
        ],
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalCard({
    required this.title,
    required this.subtitle,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AdminSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AC.t1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AC.t3, height: 1.4),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AppBtn(
                    label: 'Approve',
                    small: true,
                    onTap: onApprove,
                    icon: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppBtn(
                    label: 'Reject',
                    small: true,
                    outline: true,
                    onTap: onReject,
                    icon: const Icon(Icons.close_rounded, color: AC.red, size: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
