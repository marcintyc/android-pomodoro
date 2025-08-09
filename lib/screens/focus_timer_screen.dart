import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/timer_controller.dart';
import '../state/settings.dart';
import '../state/session_log_service.dart';
import '../widgets/progress_ring.dart';
import 'dart:ui' show FontFeature;

class FocusTimerScreen extends ConsumerWidget {
  const FocusTimerScreen({super.key});

  String _labelFor(SessionType type) {
    switch (type) {
      case SessionType.focus:
        return 'Focus';
      case SessionType.shortBreak:
        return 'Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerControllerProvider);
    final settings = ref.watch(settingsControllerProvider);

    final todaySeconds = ref.watch(sessionLogProvider).focusedSecondsOn(DateTime.now());
    final todayMinutes = (todaySeconds / 60).floor();

    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Focus Vibe', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: colorScheme.primaryContainer.withOpacity(0.4)),
                  ),
                  child: Row(children: [
                    Icon(Icons.local_fire_department, color: colorScheme.primary, size: 18),
                    const SizedBox(width: 6),
                    Text('$todayMinutes min today'),
                  ]),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: ProgressRing(
                progress: timer.progress,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_labelFor(timer.sessionType), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.primary)),
                    const SizedBox(height: 12),
                    Text(
                      timer.timeLabel,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cycle ${timer.completedFocusSessions % settings.longBreakEvery + 1}/${settings.longBreakEvery}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PillButton(
                  icon: Icons.restart_alt,
                  label: 'Reset',
                  onTap: () => ref.read(timerControllerProvider.notifier).resetSession(),
                ),
                const SizedBox(width: 16),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16), shape: const StadiumBorder()),
                  onPressed: () {
                    final ctl = ref.read(timerControllerProvider.notifier);
                    timer.isRunning ? ctl.pause() : ctl.start();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(timer.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      const SizedBox(width: 8),
                      Text(timer.isRunning ? 'Pause' : 'Start'),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _PillButton(
                  icon: Icons.skip_next,
                  label: 'Skip',
                  onTap: () => ref.read(timerControllerProvider.notifier).skip(),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PillButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}