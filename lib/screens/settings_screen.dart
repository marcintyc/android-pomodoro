import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _Section(title: 'Durations', children: [
            _NumberTile(
              label: 'Focus minutes',
              value: settings.workMinutes,
              onChanged: (v) => controller.update(workMinutes: v),
              min: 10,
              max: 120,
            ),
            _NumberTile(
              label: 'Short break minutes',
              value: settings.shortBreakMinutes,
              onChanged: (v) => controller.update(shortBreakMinutes: v),
              min: 3,
              max: 30,
            ),
            _NumberTile(
              label: 'Long break minutes',
              value: settings.longBreakMinutes,
              onChanged: (v) => controller.update(longBreakMinutes: v),
              min: 5,
              max: 60,
            ),
            _NumberTile(
              label: 'Long break every (focus cycles)',
              value: settings.longBreakEvery,
              onChanged: (v) => controller.update(longBreakEvery: v),
              min: 2,
              max: 10,
            ),
          ]),
          const SizedBox(height: 16),
          _Section(title: 'Behavior', children: [
            SwitchListTile.adaptive(
              value: settings.autoStartBreaks,
              onChanged: (v) => controller.update(autoStartBreaks: v),
              title: const Text('Auto-start breaks'),
              subtitle: const Text('Begin breaks automatically after focus sessions'),
            ),
            SwitchListTile.adaptive(
              value: settings.autoStartFocus,
              onChanged: (v) => controller.update(autoStartFocus: v),
              title: const Text('Auto-start focus'),
              subtitle: const Text('Begin focus automatically after breaks'),
            ),
          ]),
          const SizedBox(height: 24),
          Text('About', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Focus Vibe is an advanced Pomodoro timer with calendar tracking. Your data is stored locally in your browser.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 4.0),
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _NumberTile extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _NumberTile({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Slider(
        min: min.toDouble(),
        max: max.toDouble(),
        divisions: (max - min),
        value: value.clamp(min, max).toDouble(),
        label: '$value',
        onChanged: (v) => onChanged(v.round()),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        ),
        child: Text('$value min', style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}