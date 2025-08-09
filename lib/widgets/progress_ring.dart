import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0..1
  final Widget center;

  const ProgressRing({super.key, required this.progress, required this.center});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 280,
      width: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.25), blurRadius: 40, spreadRadius: 6),
                BoxShadow(color: color.withOpacity(0.15), blurRadius: 80, spreadRadius: 16),
              ],
              gradient: RadialGradient(colors: [color.withOpacity(0.14), Colors.transparent], radius: 0.9),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 350),
            builder: (_, value, __) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 14,
                strokeCap: StrokeCap.round,
                color: color,
                backgroundColor: color.withOpacity(0.15),
              );
            },
          ),
          Center(child: center),
        ],
      ),
    );
  }
}