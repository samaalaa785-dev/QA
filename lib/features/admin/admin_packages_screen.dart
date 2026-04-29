// lib/features/admin/admin_packages_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_widgets.dart';

class AdminPackagesScreen extends StatefulWidget {
  const AdminPackagesScreen({super.key});
  @override
  State<AdminPackagesScreen> createState() => _AdminPackagesScreenState();
}

class _AdminPackagesScreenState extends State<AdminPackagesScreen> {
  late List<_PackageData> _packages;

  @override
  void initState() {
    super.initState();
    _packages = [
      _PackageData(
        id: 'p1', name: 'Standard Plan', price: 500,
        duration: '3 Months', color: AC.info,
        features: ['Oil Change (x1)', 'Car Wash (x2)', 'Basic Checkup (x1)'],
        subscribers: 124,
      ),
      _PackageData(
        id: 'p2', name: 'Premium Plan', price: 1600,
        duration: '1 Year', color: AC.red,
        features: ['Oil Change (x4)', 'Car Wash (x8)', 'Full Checkup (x2)', 'Tyre Rotation (x2)', 'Priority Support'],
        subscribers: 87,
      ),
      _PackageData(
        id: 'p3', name: 'Gold Plan', price: 2700,
        duration: '2 Years', color: AC.gold,
        features: ['Unlimited Oil Changes', 'Unlimited Car Wash', 'Full Checkup (x6)', 'Emergency Towing (x3)', 'AI Diagnostics', 'VIP Support 24/7'],
        subscribers: 45,
      ),
    ];
  }

  void _deletePackage(String id) {
    setState(() => _packages.removeWhere((p) => p.id == id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Package deleted'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AC.s2));
  }

  void _showEditSheet({_PackageData? existing}) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AC.s1,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PackageFormSheet(
        existing: existing,
        onSave: (pkg) {
          setState(() {
            if (existing != null) {
              final i = _packages.indexWhere((p) => p.id == existing.id);
              if (i != -1) _packages[i] = pkg;
            } else {
              _packages.add(pkg);
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: AC.s1,
        title: const Text('Packages', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800, color: AC.t1)),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () => _showEditSheet(),
              child: Container(width: 36, height: 36,
                decoration: BoxDecoration(gradient: AC.redGrad,
                    borderRadius: Rd.smA),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 20)),
            )),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AC.border)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: _packages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) => _PackageCard(
          pkg: _packages[i],
          onEdit: () => _showEditSheet(existing: _packages[i]),
          onDelete: () => _showDeleteDialog(_packages[i]),
        ),
      ),
    );
  }

  void _showDeleteDialog(_PackageData pkg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AC.s2,
        shape: RoundedRectangleBorder(borderRadius: Rd.lgA),
        title: const Text('Delete Package',
            style: TextStyle(color: AC.t1, fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to delete "${pkg.name}"?\nThis cannot be undone.',
            style: const TextStyle(color: AC.t2, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AC.t2))),
          TextButton(onPressed: () {
            Navigator.pop(context);
            _deletePackage(pkg.id);
          }, child: const Text('Delete', style: TextStyle(color: AC.error))),
        ],
      ),
    );
  }
}

// ── Package Card ──────────────────────────────────────────────────────────────
class _PackageCard extends StatelessWidget {
  final _PackageData pkg;
  final VoidCallback onEdit, onDelete;
  const _PackageCard({required this.pkg, required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ACard(
      padding: const EdgeInsets.all(18),
      glow: true, glowColor: pkg.color,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(
              color: pkg.color.withOpacity(0.15),
              borderRadius: Rd.mdA,
              border: Border.all(color: pkg.color.withOpacity(0.3)),
            ),
            child: Icon(Icons.inventory_2_rounded, color: pkg.color, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(pkg.name, style: const TextStyle(fontSize: 15,
                fontWeight: FontWeight.w800, color: AC.t1, letterSpacing: -0.3)),
            Row(children: [
              Icon(Icons.schedule_outlined, size: 12, color: pkg.color),
              const SizedBox(width: 4),
              Text(pkg.duration, style: TextStyle(fontSize: 11,
                  color: pkg.color, fontWeight: FontWeight.w600)),
            ]),
          ])),
          Text('${pkg.price} LE', style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w900, color: AC.gold)),
        ]),

        const SizedBox(height: 14),
        Container(height: 1, color: AC.border),
        const SizedBox(height: 14),

        // Features
        const Text('FEATURES', style: TextStyle(fontSize: 10,
            fontWeight: FontWeight.w800, color: AC.t3, letterSpacing: 1)),
        const SizedBox(height: 8),
        ...pkg.features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(children: [
            Icon(Icons.check_circle_rounded, size: 14, color: pkg.color),
            const SizedBox(width: 8),
            Text(f, style: const TextStyle(fontSize: 12, color: AC.t2)),
          ]),
        )),

        const SizedBox(height: 14),

        // Stats + actions
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: AC.info.withOpacity(0.12), borderRadius: Rd.fullA),
            child: Row(children: [
              const Icon(Icons.people_rounded, size: 12, color: AC.info),
              const SizedBox(width: 4),
              Text('${pkg.subscribers} subscribers',
                  style: const TextStyle(fontSize: 11,
                      color: AC.info, fontWeight: FontWeight.w600)),
            ])),
          const Spacer(),
          GestureDetector(onTap: onEdit,
            child: Container(padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: AC.s3, borderRadius: Rd.smA),
              child: const Text('Edit', style: TextStyle(fontSize: 12,
                  color: AC.t1, fontWeight: FontWeight.w700)))),
          const SizedBox(width: 8),
          GestureDetector(onTap: onDelete,
            child: Container(padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  color: AC.error.withOpacity(0.12), borderRadius: Rd.smA),
              child: const Text('Delete', style: TextStyle(fontSize: 12,
                  color: AC.error, fontWeight: FontWeight.w700)))),
        ]),
      ]),
    );
  }
}

// ── Package Form Sheet ────────────────────────────────────────────────────────
class _PackageFormSheet extends StatefulWidget {
  final _PackageData? existing;
  final void Function(_PackageData) onSave;
  const _PackageFormSheet({this.existing, required this.onSave});
  @override
  State<_PackageFormSheet> createState() => _PackageFormSheetState();
}

class _PackageFormSheetState extends State<_PackageFormSheet> {
  final _nameCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _duration = '3 Months';
  final List<TextEditingController> _featureCtrls = [];

  static const _durations = ['3 Months', '6 Months', '1 Year', '2 Years'];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameCtrl.text  = widget.existing!.name;
      _priceCtrl.text = widget.existing!.price.toString();
      _duration       = widget.existing!.duration;
      for (final f in widget.existing!.features) {
        _featureCtrls.add(TextEditingController(text: f));
      }
    } else {
      _featureCtrls.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _priceCtrl.dispose();
    for (final c in _featureCtrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20,
          MediaQuery.of(context).viewInsets.bottom + 28),
      child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AC.s3, borderRadius: Rd.fullA))),
          const SizedBox(height: 18),
          Text(widget.existing != null ? 'Edit Package' : 'New Package',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                  color: AC.t1)),
          const SizedBox(height: 20),

          // Name
          _FieldLabel('Package Name'),
          _DarkField(ctrl: _nameCtrl, hint: 'e.g. Standard Plan'),
          const SizedBox(height: 14),

          // Price
          _FieldLabel('Price (LE)'),
          _DarkField(ctrl: _priceCtrl, hint: 'e.g. 500', number: true),
          const SizedBox(height: 14),

          // Duration
          _FieldLabel('Duration'),
          Wrap(spacing: 8, children: _durations.map((d) => GestureDetector(
            onTap: () => setState(() => _duration = d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _duration == d ? AC.red.withOpacity(0.15) : AC.s3,
                borderRadius: Rd.fullA,
                border: Border.all(
                    color: _duration == d ? AC.red.withOpacity(0.5) : AC.border),
              ),
              child: Text(d, style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: _duration == d ? AC.red : AC.t2)),
            ),
          )).toList()),
          const SizedBox(height: 16),

          // Features
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const _FieldLabel('Features'),
            GestureDetector(
              onTap: () => setState(() =>
                  _featureCtrls.add(TextEditingController())),
              child: Container(padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AC.red.withOpacity(0.12),
                    borderRadius: Rd.fullA),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_rounded, size: 14, color: AC.red),
                  SizedBox(width: 4),
                  Text('Add', style: TextStyle(fontSize: 11,
                      color: AC.red, fontWeight: FontWeight.w700)),
                ])),
            ),
          ]),
          const SizedBox(height: 8),
          ...List.generate(_featureCtrls.length, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: _DarkField(ctrl: _featureCtrls[i],
                  hint: 'Feature description')),
              if (_featureCtrls.length > 1) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() {
                    _featureCtrls[i].dispose();
                    _featureCtrls.removeAt(i);
                  }),
                  child: Container(width: 36, height: 36,
                    decoration: BoxDecoration(
                        color: AC.error.withOpacity(0.12),
                        borderRadius: Rd.smA),
                    child: const Icon(Icons.remove_rounded,
                        color: AC.error, size: 18))),
              ],
            ]),
          )),

          const SizedBox(height: 20),
          SizedBox(width: double.infinity,
            child: AppBtn(
              label: widget.existing != null ? 'Save Changes' : 'Create Package',
              onTap: () {
                final name  = _nameCtrl.text.trim();
                final price = double.tryParse(_priceCtrl.text) ?? 0;
                if (name.isEmpty) return;
                final features = _featureCtrls
                    .map((c) => c.text.trim())
                    .where((f) => f.isNotEmpty)
                    .toList();
                widget.onSave(_PackageData(
                  id: widget.existing?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name, price: price, duration: _duration,
                  color: widget.existing?.color ?? AC.red,
                  features: features,
                  subscribers: widget.existing?.subscribers ?? 0,
                ));
                Navigator.pop(context);
              },
            )),
        ],
      )),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 12,
        color: AC.t2, fontWeight: FontWeight.w600)),
  );
}

class _DarkField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final bool number;
  const _DarkField({required this.ctrl, required this.hint, this.number = false});

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    keyboardType: number ? TextInputType.number : TextInputType.text,
    style: const TextStyle(color: AC.t1, fontSize: 14),
    decoration: InputDecoration(
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
    ),
  );
}

// ── Model ─────────────────────────────────────────────────────────────────────
class _PackageData {
  final String id, name, duration;
  final double price;
  final Color color;
  final List<String> features;
  final int subscribers;

  _PackageData({required this.id, required this.name, required this.price,
      required this.duration, required this.color, required this.features,
      required this.subscribers});
}
