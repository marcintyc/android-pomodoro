import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kWorkMinutes = 'settings.workMinutes';
const _kShortBreakMinutes = 'settings.shortBreakMinutes';
const _kLongBreakMinutes = 'settings.longBreakMinutes';
const _kLongBreakEvery = 'settings.longBreakEvery';
const _kAutoStartBreaks = 'settings.autoStartBreaks';
const _kAutoStartFocus = 'settings.autoStartFocus';

@immutable
class PomodoroSettings {
  final int workMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int longBreakEvery; // number of focus sessions before long break
  final bool autoStartBreaks;
  final bool autoStartFocus;

  const PomodoroSettings({
    required this.workMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.longBreakEvery,
    required this.autoStartBreaks,
    required this.autoStartFocus,
  });

  factory PomodoroSettings.defaults() => const PomodoroSettings(
        workMinutes: 25,
        shortBreakMinutes: 5,
        longBreakMinutes: 15,
        longBreakEvery: 4,
        autoStartBreaks: true,
        autoStartFocus: false,
      );

  PomodoroSettings copyWith({
    int? workMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? longBreakEvery,
    bool? autoStartBreaks,
    bool? autoStartFocus,
  }) {
    return PomodoroSettings(
      workMinutes: workMinutes ?? this.workMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      longBreakEvery: longBreakEvery ?? this.longBreakEvery,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartFocus: autoStartFocus ?? this.autoStartFocus,
    );
  }
}

class SettingsController extends StateNotifier<PomodoroSettings> {
  SettingsController() : super(PomodoroSettings.defaults());

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      workMinutes: prefs.getInt(_kWorkMinutes) ?? state.workMinutes,
      shortBreakMinutes: prefs.getInt(_kShortBreakMinutes) ?? state.shortBreakMinutes,
      longBreakMinutes: prefs.getInt(_kLongBreakMinutes) ?? state.longBreakMinutes,
      longBreakEvery: prefs.getInt(_kLongBreakEvery) ?? state.longBreakEvery,
      autoStartBreaks: prefs.getBool(_kAutoStartBreaks) ?? state.autoStartBreaks,
      autoStartFocus: prefs.getBool(_kAutoStartFocus) ?? state.autoStartFocus,
    );
    _initialized = true;
  }

  Future<void> init() async {
    await _ensureInitialized();
  }

  Future<void> update({
    int? workMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? longBreakEvery,
    bool? autoStartBreaks,
    bool? autoStartFocus,
  }) async {
    await _ensureInitialized();
    final next = state.copyWith(
      workMinutes: workMinutes,
      shortBreakMinutes: shortBreakMinutes,
      longBreakMinutes: longBreakMinutes,
      longBreakEvery: longBreakEvery,
      autoStartBreaks: autoStartBreaks,
      autoStartFocus: autoStartFocus,
    );
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kWorkMinutes, next.workMinutes);
    await prefs.setInt(_kShortBreakMinutes, next.shortBreakMinutes);
    await prefs.setInt(_kLongBreakMinutes, next.longBreakMinutes);
    await prefs.setInt(_kLongBreakEvery, next.longBreakEvery);
    await prefs.setBool(_kAutoStartBreaks, next.autoStartBreaks);
    await prefs.setBool(_kAutoStartFocus, next.autoStartFocus);
  }
}

final settingsControllerProvider = StateNotifierProvider<SettingsController, PomodoroSettings>((ref) {
  final controller = SettingsController();
  controller.init();
  return controller;
});