import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

import '../state/session_log_service.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(sessionLogProvider);
    final dateMap = log.toDateMap();

    // Convert seconds to minutes for display intensity
    final values = <DateTime, int>{
      for (final e in dateMap.entries) DateTime(e.key.year, e.key.month, e.key.day): (e.value / 60).round(),
    };

    final color = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Calendar', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              Text('Minutes per day', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: HeatMap(
                startDate: DateTime(DateTime.now().year, 1, 1),
                endDate: DateTime(DateTime.now().year, 12, 31),
                showText: false,
                scrollable: true,
                colorMode: ColorMode.color,
                datasets: values,
                colorsets: {
                  1: color.withOpacity(0.15),
                  10: color.withOpacity(0.25),
                  20: color.withOpacity(0.35),
                  30: color.withOpacity(0.45),
                  45: color.withOpacity(0.60),
                  60: color.withOpacity(0.80),
                },
                onClick: (date) {},
              ),
            ),
          ),
          const SizedBox(height: 24),
          _Summary(values: values),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final Map<DateTime, int> values;
  const _Summary({required this.values});

  @override
  Widget build(BuildContext context) {
    final totalMinutes = values.values.fold<int>(0, (a, b) => a + b);
    final daysWithFocus = values.entries.where((e) => e.value > 0).length;
    final avgPerDay = daysWithFocus == 0 ? 0 : (totalMinutes / daysWithFocus).round();

    return Row(
      children: [
        Expanded(child: _StatTile(title: 'Total', value: '$totalMinutes min')),
        const SizedBox(width: 12),
        Expanded(child: _StatTile(title: 'Focused Days', value: '$daysWithFocus')),
        const SizedBox(width: 12),
        Expanded(child: _StatTile(title: 'Avg/Day', value: '$avgPerDay min')),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;

  const _StatTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}