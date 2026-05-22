import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/dio_client.dart';
import '../models/habit.dart';
import 'dart:convert';

final habitsServiceProvider = Provider<HabitsService>((ref) {
  return HabitsService(dio: ref.read(dioProvider));
});

class HabitsService {
  final Dio dio;
  HabitsService({required this.dio});

  Future<List<Habit>> fetchHabits() async {
    final response = await dio.get('/habit/get');

    final dynamic rawData = response.data is String
        ? json.decode(response.data as String)
        : response.data;

    final List<dynamic> list = rawData is List
        ? rawData
        : (rawData['data'] ?? []);

    return list.map((j) => Habit.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<void> saveCheckboxChanges(List<Map<String, dynamic>> changes) async {
    await dio.post('/habit/notice', data: changes);
  }

  Future<Habit> createHabit(String title, String description) async {
    final resp = await dio.post(
      '/habit/create',
      data: {'title': title, 'description': description},
    );
    return Habit.fromJson(resp.data);
  }

  Future<void> updateHabitField(int habitId, String field, String value) async {
    await dio.post(
      '/habit/update/$habitId',
      data: {
        if (field == 'title') 'title': value,
        if (field == 'description') 'description': value,
      },
    );
  }

  Future<void> deleteHabit(int habitId) async {
    await dio.post('/habit/delete', data: {'habit_id': habitId});
  }

  // Сессии
  Future<Map<String, dynamic>> fetchSessionsData() async {
    final resp = await dio.get('/session/stopwatch-data');
    return resp.data;
  }

  Future<void> createSession(int habitId, int durationSeconds) async {
    await dio.post(
      '/session/create',
      data: {'habit_id': habitId, 'duration': durationSeconds},
    );
  }

  Future<void> deleteSession(int sessionId) async {
    await dio.post('/session/delete', data: {'session_id': sessionId});
  }
}
