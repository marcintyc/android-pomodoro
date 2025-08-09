import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:focus_vibe_pomodoro/state/settings.dart';
import 'package:focus_vibe_pomodoro/state/session_log_service.dart';

enum SessionType { focus, shortBreak, longBreak }

@immutable
class TimerState {
  final SessionType sessionType;
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final int completedFocusSessions;

  const TimerState({
    required this.sessionType,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isRunning,
    required this.completedFocusSessions,
  });

  double get progress => totalSeconds == 0 ? 0 : 1 - (remainingSeconds / totalSeconds);

  String get timeLabel {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        .toString();
  }

  TimerState copyWith({
    SessionType? sessionType,
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
    int? completedFocusSessions,
  }) {
    return TimerState(
      sessionType: sessionType ?? this.sessionType,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      completedFocusSessions: completedFocusSessions ?? this.completedFocusSessions,
    );
  }

  factory TimerState.initial(PomodoroSettings settings) => TimerState(
        sessionType: SessionType.focus,
        totalSeconds: settings.workMinutes * 60,
        remainingSeconds: settings.workMinutes * 60,
        isRunning: false,
        completedFocusSessions: 0,
      );
}

class TimerController extends StateNotifier<TimerState> {
  final Ref ref;
  Timer? _ticker;

  TimerController(this.ref) : super(TimerState.initial(ref.read(settingsControllerProvider)));

  PomodoroSettings get _settings => ref.read(settingsControllerProvider);

  void start() {
    if (state.isRunning) return;
    _ticker?.cancel();
    state = state.copyWith(isRunning: true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void pause() {
    if (!state.isRunning) return;
    _ticker?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void resetSession() {
    _ticker?.cancel();
    final total = _durationFor(state.sessionType);
    state = state.copyWith(
      totalSeconds: total,
      remainingSeconds: total,
      isRunning: false,
    );
  }

  void skip() {
    _completeCurrentSession(countAsFocus: false);
  }

  Future<void> _onTick() async {
    final nextRemaining = state.remainingSeconds - 1;
    if (nextRemaining > 0) {
      state = state.copyWith(remainingSeconds: nextRemaining);
      return;
    }

    // Session finished
    await _completeCurrentSession(countAsFocus: true);
  }

  Future<void> _completeCurrentSession({required bool countAsFocus}) async {
    _ticker?.cancel();
    final wasFocus = state.sessionType == SessionType.focus;

    if (wasFocus && countAsFocus) {
      final focusedSeconds = state.totalSeconds;
      await ref.read(sessionLogProvider.notifier).addFocusedSeconds(focusedSeconds);
    }

    // Determine next session type
    final next = _nextSessionType(wasFocus: wasFocus);
    final nextTotal = _durationFor(next);
    final completed = wasFocus ? state.completedFocusSessions + 1 : state.completedFocusSessions;

    state = state.copyWith(
      sessionType: next,
      totalSeconds: nextTotal,
      remainingSeconds: nextTotal,
      isRunning: false,
      completedFocusSessions: completed,
    );

    final autoStart = () {
      switch (next) {
        case SessionType.focus:
          return _settings.autoStartFocus;
        case SessionType.shortBreak:
        case SessionType.longBreak:
          return _settings.autoStartBreaks;
      }
    }();

    if (autoStart) start();
  }

  int _durationFor(SessionType type) {
    switch (type) {
      case SessionType.focus:
        return _settings.workMinutes * 60;
      case SessionType.shortBreak:
        return _settings.shortBreakMinutes * 60;
      case SessionType.longBreak:
        return _settings.longBreakMinutes * 60;
    }
  }

  SessionType _nextSessionType({required bool wasFocus}) {
    if (wasFocus) {
      if (state.completedFocusSessions > 0 &&
          state.completedFocusSessions % _settings.longBreakEvery == 0) {
        return SessionType.longBreak;
      }
      return SessionType.shortBreak;
    } else {
      return SessionType.focus;
    }
  }

  void onSettingsChanged() {
    // When settings change, recalculate current totals if not running
    if (!state.isRunning) {
      final total = _durationFor(state.sessionType);
      final remaining = total;
      state = state.copyWith(totalSeconds: total, remainingSeconds: remaining);
    }
  }
}

final timerControllerProvider = StateNotifierProvider<TimerController, TimerState>((ref) {
  final controller = TimerController(ref);
  ref.listen(settingsControllerProvider, (_, __) => controller.onSettingsChanged());
  return controller;
});