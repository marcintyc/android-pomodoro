import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/focus_timer_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'state/settings.dart';
import 'state/session_log_service.dart';
import 'widgets/gradient_background.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: FocusVibeApp()));
}

class FocusVibeApp extends ConsumerWidget {
  const FocusVibeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4), // refined purple seed
      brightness: Brightness.dark,
    );

    // Kick off async initializers
    ref.watch(settingsControllerProvider);
    ref.watch(sessionLogProvider);

    final textTheme = GoogleFonts.interTextTheme(Typography.whiteMountainView).copyWith(
      displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w800, letterSpacing: -1.0),
      displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700),
    );

    return MaterialApp(
      title: 'Focus Vibe Pomodoro',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        textTheme: textTheme,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.transparent,
          indicatorColor: colorScheme.primary.withValues(alpha: 0.20),
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        cardColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
      ),
      home: const _HomeShell(),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _index = 0;

  final _pages = const [
    FocusTimerScreen(),
    CalendarScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const GradientBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _pages[_index],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer), label: 'Focus'),
              NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendar'),
              NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune), label: 'Settings'),
            ],
          ),
        ),
      ],
    );
  }
}