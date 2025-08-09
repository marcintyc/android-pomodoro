import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLogKey = 'session_log.v1';

String _keyForDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(DateTime(dt.year, dt.month, dt.day));

@immutable
class SessionLogState {
  final Map<String, int> isoDateToFocusedSeconds;

  const SessionLogState({required this.isoDateToFocusedSeconds});

  factory SessionLogState.empty() => const SessionLogState(isoDateToFocusedSeconds: {});

  Map<DateTime, int> toDateMap() {
    return isoDateToFocusedSeconds.map((k, v) => MapEntry(DateTime.parse(k), v));
  }

  int focusedSecondsOn(DateTime day) {
    return isoDateToFocusedSeconds[_keyForDate(day)] ?? 0;
  }

  SessionLogState addFocus(DateTime day, int seconds) {
    final key = _keyForDate(day);
    final existing = isoDateToFocusedSeconds[key] ?? 0;
    final next = Map<String, int>.from(isoDateToFocusedSeconds);
    next[key] = existing + seconds;
    return SessionLogState(isoDateToFocusedSeconds: next);
  }

  String toJson() => jsonEncode(isoDateToFocusedSeconds);

  factory SessionLogState.fromJson(String jsonStr) {
    final dynamic decoded = jsonDecode(jsonStr);
    final map = <String, int>{};
    decoded.forEach((key, value) {
      map[key as String] = (value as num).toInt();
    });
    return SessionLogState(isoDateToFocusedSeconds: map);
  }
}

class SessionLogController extends StateNotifier<SessionLogState> {
  SessionLogController() : super(SessionLogState.empty());

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLogKey);
    if (raw != null && raw.isNotEmpty) {
      state = SessionLogState.fromJson(raw);
    }
    _initialized = true;
  }

  Future<void> init() async {
    await _ensureInitialized();
  }

  Future<void> addFocusedSeconds(int seconds, {DateTime? when}) async {
    await _ensureInitialized();
    final now = when ?? DateTime.now();
    state = state.addFocus(now, seconds);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLogKey, state.toJson());
  }
}

final sessionLogProvider = StateNotifierProvider<SessionLogController, SessionLogState>((ref) {
  final controller = SessionLogController();
  controller.init();
  return controller;
});