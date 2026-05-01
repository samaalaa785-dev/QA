import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ACard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool glow;
  final Color? glowColor;

  const ACard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.glow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AC.s1,
        borderRadius: Rd.mdA,
        border: Border.all(color: AC.border),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: (glowColor ?? AC.red).withOpacity(0.18),
                  blurRadius: 18,
                ),
              ]
            : null,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(onTap: onTap, borderRadius: Rd.mdA, child: card);
  }
}

class AppBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool gold;
  final bool outline;
  final bool loading;
  final bool small;
  final Widget? icon;

  const AppBtn({
    super.key,
    required this.label,
    this.onTap,
    this.gold = false,
    this.outline = false,
    this.loading = false,
    this.small = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final fg = outline ? (gold ? AC.gold : AC.red) : Colors.white;
    return SizedBox(
      height: small ? 40 : 50,
      child: OutlinedButton(
        onPressed: loading ? null : onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: outline ? Colors.transparent : (gold ? AC.gold : AC.red),
          foregroundColor: fg,
          side: BorderSide(color: gold ? AC.gold : AC.red),
          shape: RoundedRectangleBorder(borderRadius: Rd.mdA),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: small ? 12 : 14,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class AppField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController ctrl;
  final TextInputType? keyboard;
  final bool obscure;
  final int maxLines;
  final String? Function(String?)? validator;
  final Widget? suffix;

  const AppField({
    super.key,
    required this.label,
    required this.hint,
    required this.ctrl,
    this.keyboard,
    this.obscure = false,
    this.maxLines = 1,
    this.validator,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      keyboardType: keyboard,
      obscureText: obscure,
      maxLines: obscure ? 1 : maxLines,
      style: const TextStyle(color: AC.t1),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffix,
      ),
    );
  }
}

class SAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;

  const SAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AC.bg,
      elevation: 0,
      automaticallyImplyLeading: showBack,
      iconTheme: const IconThemeData(color: AC.t1),
      title: Text(
        title,
        style: const TextStyle(color: AC.t1, fontWeight: FontWeight.w800),
      ),
      actions: actions,
    );
  }
}

class SecHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SecHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AC.t1,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class GoldBadge extends StatelessWidget {
  final String label;
  const GoldBadge(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AC.gold, borderRadius: Rd.fullA),
      child: Text(
        label,
        style: const TextStyle(
          color: AC.bg,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  const StatusChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AC.s2,
        borderRadius: Rd.fullA,
        border: Border.all(color: AC.border),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AC.t2, fontSize: 11),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String sub;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: AC.t1)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(color: AC.t3)),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: AC.t3))),
        Text(value, style: const TextStyle(color: AC.t1)),
      ],
    );
  }
}
