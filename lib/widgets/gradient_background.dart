import 'package:flutter/material.dart';

class GradientBackground extends StatefulWidget {
  const GradientBackground({super.key});

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 18))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final colorsA = [
      c.primary.withValues(alpha: 0.25),
      c.secondary.withValues(alpha: 0.20),
      c.surfaceContainerHighest.withValues(alpha: 0.05),
    ];
    final colorsB = [
      c.tertiary.withValues(alpha: 0.25),
      c.primary.withValues(alpha: 0.18),
      c.surfaceContainerHighest.withValues(alpha: 0.06),
    ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        final mix = List<Color>.generate(colorsA.length, (i) {
          final a = colorsA[i];
          final b = colorsB[i];
          return Color.lerp(a, b, t)!;
        });
        return IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.4 + t * 0.8, -0.6 + t * 0.6),
                radius: 1.2,
                colors: mix,
                stops: const [0.2, 0.6, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}