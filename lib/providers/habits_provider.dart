import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../services/habits_service.dart';

class SessionState {
  final int? activeHabitId;
  final bool isRunning;
  final DateTime? startTime;
  final int accumulatedSeconds;

  const SessionState({
    this.activeHabitId,
    this.isRunning = false,
    this.startTime,
    this.accumulatedSeconds = 0,
  });

  SessionState copyWith({
    int? activeHabitId,
    bool? isRunning,
    DateTime? startTime,
    int? accumulatedSeconds,
  }) {
    return SessionState(
      activeHabitId: activeHabitId ?? this.activeHabitId,
      isRunning: isRunning ?? this.isRunning,
      startTime: startTime ?? this.startTime,
      accumulatedSeconds: accumulatedSeconds ?? this.accumulatedSeconds,
    );
  }
}

class HabitsNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
  final HabitsService _service;
  SessionState sessionState = const SessionState();

  HabitsNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> loadHabits() async {
    state = const AsyncValue.loading();
    try {
      final habits = await _service.fetchHabits();
      state = AsyncValue.data(habits);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveChanges(List<Map<String, dynamic>> changes) async {
    try {
      await _service.saveCheckboxChanges(changes);
      await loadHabits(); 
    } catch (e) {
      // ошибку обработать както потом
    }
  }

  void startSession(int habitId) {
    sessionState = SessionState(
      activeHabitId: habitId,
      isRunning: true,
      startTime: DateTime.now(),
      accumulatedSeconds: sessionState.activeHabitId == habitId
          ? sessionState.accumulatedSeconds
          : 0,
    );
  }

  void pauseSession() {
    if (!sessionState.isRunning) return;
    final now = DateTime.now();
    final additional = now.difference(sessionState.startTime!).inSeconds;
    sessionState = sessionState.copyWith(
      isRunning: false,
      accumulatedSeconds: sessionState.accumulatedSeconds + additional,
      startTime: null,
    );
  }

  Future<void> stopAndSaveSession() async {
    if (sessionState.activeHabitId == null) return;
    final totalSeconds = sessionState.isRunning
        ? sessionState.accumulatedSeconds +
              DateTime.now().difference(sessionState.startTime!).inSeconds
        : sessionState.accumulatedSeconds;
    await _service.createSession(sessionState.activeHabitId!, totalSeconds);
    sessionState = const SessionState();
    await loadHabits();
  }

  int get totalSessionSecondsToday {
    // заглушка пока
    return 0;
  }
}

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<List<Habit>>>((ref) {
      return HabitsNotifier(ref.read(habitsServiceProvider));
    });
