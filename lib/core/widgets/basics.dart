import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

/// Clean White Theme Reusable Components

/// Pressable widget with smooth scale and opacity feedback
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const Pressable({super.key, required this.child, required this.onTap});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _down ? 0.985 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedOpacity(
            opacity: _down ? 0.75 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: widget.child,
          ),
        ),
      );
}

/// Primary Button
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const PrimaryButton(
    this.label, {
    super.key,
    this.icon = Icons.arrow_forward_rounded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: cs.onPrimary, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Secondary Button
class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const SecondaryButton(
    this.label, {
    super.key,
    this.icon = Icons.arrow_forward_rounded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: cs.onSurface, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Flush List Item Card Row
class FlushListRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badgeText;
  final IconData icon;
  final VoidCallback onTap;

  const FlushListRow({
    super.key,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.icon = Icons.insert_drive_file_outlined,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: cs.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Text(
                            badgeText!,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Minimalist Stat Display Component
class StatDisplay extends StatelessWidget {
  final num value;
  final String label;
  final IconData icon;

  const StatDisplay({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, color: cs.primary, size: 20),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.toDouble()),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => Text(
            v.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: cs.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

/// Section Header Widget
class SectionHeading extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeading({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
            color: cs.onSurface,
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
          ),
      ],
    );
  }
}

/// App Bar Header
class AppHeader extends StatelessWidget {
  final VoidCallback? onHelp;

  const AppHeader({super.key, this.onHelp});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'CLUSTERLAB',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'ENGINE READY',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF10B981), letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (onHelp != null)
            IconButton(
              tooltip: 'Help',
              onPressed: onHelp,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.info_outline_rounded, size: 20),
              color: cs.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}

/// Underline Search Input
class UnderlineField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const UnderlineField({
    super.key,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      onChanged: onChanged,
      style: TextStyle(fontSize: 14, color: cs.onSurface),
      cursorColor: cs.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
        prefixIcon: Icon(Icons.search, size: 18, color: cs.onSurfaceVariant),
        isDense: true,
        filled: true,
        fillColor: cs.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
      ),
    );
  }
}

/// Bottom Navigation Bar
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border(top: BorderSide(color: cs.outlineVariant, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: cs.surfaceContainer,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined, size: 20),
            activeIcon: Icon(Icons.grid_view_rounded, size: 20),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart_outlined, size: 20),
            activeIcon: Icon(Icons.table_chart_rounded, size: 20),
            label: 'Datasets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hub_outlined, size: 20),
            activeIcon: Icon(Icons.hub, size: 20),
            label: 'Analyze',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined, size: 20),
            activeIcon: Icon(Icons.history_rounded, size: 20),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

/// CustomPainter for 2D Scatter Plot
class ClusterScatterPainter extends CustomPainter {
  final List<Offset> points;
  final List<int> labels;
  final double progress;
  final BuildContext context;

  ClusterScatterPainter(this.points, this.labels, this.progress, this.context);

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 24.0;
    final w = size.width - pad * 2;
    final h = size.height - pad * 2;

    final cs = Theme.of(context).colorScheme;

    // Grid lines
    final grid = Paint()
      ..color = cs.outlineVariant
      ..strokeWidth = 1.0;

    for (var i = 0; i <= 4; i++) {
      final dx = pad + w * i / 4;
      final dy = pad + h * i / 4;
      canvas.drawLine(Offset(dx, pad), Offset(dx, pad + h), grid);
      canvas.drawLine(Offset(pad, dy), Offset(pad + w, dy), grid);
    }

    final clusterColors = [
      const Color(0xFF4F46E5), // Indigo
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEC4899), // Rose
      const Color(0xFF06B6D4), // Cyan
    ];

    for (var i = 0; i < points.length; i++) {
      final t = ((progress * 1.4) - i / points.length * 0.4).clamp(0.0, 1.0);
      if (t == 0) continue;

      final c = Offset(pad + points[i].dx * w, pad + (1 - points[i].dy) * h);
      final r = 5.5 * Curves.easeOutCubic.transform(t);

      final color = clusterColors[labels[i] % clusterColors.length];
      final fill = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(c, r, fill);
    }
  }

  @override
  bool shouldRepaint(covariant ClusterScatterPainter old) =>
      old.progress != progress || old.points != points || old.labels != labels;
}

/// HatchBar Widget
class HatchBar extends StatelessWidget {
  final List<double> percentages;

  const HatchBar({super.key, required this.percentages});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final clusterColors = [
      const Color(0xFF4F46E5), // Indigo
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEC4899), // Rose
      const Color(0xFF06B6D4), // Cyan
    ];

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Row(
          children: List.generate(percentages.length, (index) {
            final p = percentages[index];
            final color = clusterColors[index % clusterColors.length];
            return Expanded(
              flex: (p * 100).toInt().clamp(1, 10000),
              child: Container(
                margin: const EdgeInsets.only(right: 2),
                color: color,
              ),
            );
          }),
        ),
      ),
    );
  }
}
