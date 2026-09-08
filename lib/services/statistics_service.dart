// lib/services/statistics_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StatisticsService {
  static const String KEY_TOTAL_ATTEMPTS = 'total_attempts';
  static const String KEY_TOTAL_CORRECT = 'total_correct';
  static const String KEY_TOTAL_WRONG = 'total_wrong';
  static const String KEY_TOPIC_STATS = 'topic_stats';

  static Future<void> saveResult(
    int correct,
    int wrong,
    Map<String, int> topicResults,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      int totalAttempts = prefs.getInt(KEY_TOTAL_ATTEMPTS) ?? 0;
      int totalCorrect = prefs.getInt(KEY_TOTAL_CORRECT) ?? 0;
      int totalWrong = prefs.getInt(KEY_TOTAL_WRONG) ?? 0;

      await prefs.setInt(KEY_TOTAL_ATTEMPTS, totalAttempts + 1);
      await prefs.setInt(KEY_TOTAL_CORRECT, totalCorrect + correct);
      await prefs.setInt(KEY_TOTAL_WRONG, totalWrong + wrong);

      // Загружаем существующую статистику по темам
      Map<String, int> topicStats = {};
      String? saved = prefs.getString(KEY_TOPIC_STATS);
      if (saved != null && saved.isNotEmpty) {
        try {
          // Используем JSON для безопасного сохранения
          Map<String, dynamic> decoded = jsonDecode(saved);
          topicStats = decoded.map((key, value) => MapEntry(key, value as int));
        } catch (e) {
          topicStats = {};
        }
      }

      // Добавляем новые результаты
      for (var entry in topicResults.entries) {
        topicStats[entry.key] = (topicStats[entry.key] ?? 0) + entry.value;
      }

      // Сохраняем как JSON
      await prefs.setString(KEY_TOPIC_STATS, jsonEncode(topicStats));
    } catch (e) {
      print('Ошибка сохранения статистики: $e');
    }
  }

  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      int totalAttempts = prefs.getInt(KEY_TOTAL_ATTEMPTS) ?? 0;
      int totalCorrect = prefs.getInt(KEY_TOTAL_CORRECT) ?? 0;
      int totalWrong = prefs.getInt(KEY_TOTAL_WRONG) ?? 0;

      Map<String, int> topicStats = {};
      String? saved = prefs.getString(KEY_TOPIC_STATS);
      if (saved != null && saved.isNotEmpty) {
        try {
          Map<String, dynamic> decoded = jsonDecode(saved);
          topicStats = decoded.map((key, value) => MapEntry(key, value as int));
        } catch (e) {
          topicStats = {};
        }
      }

      return {
        'totalAttempts': totalAttempts,
        'totalCorrect': totalCorrect,
        'totalWrong': totalWrong,
        'topicStats': topicStats,
      };
    } catch (e) {
      print('Ошибка загрузки статистики: $e');
      return {
        'totalAttempts': 0,
        'totalCorrect': 0,
        'totalWrong': 0,
        'topicStats': {},
      };
    }
  }

  // Добавляем метод для сброса статистики (для отладки)
  static Future<void> clearStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(KEY_TOTAL_ATTEMPTS);
      await prefs.remove(KEY_TOTAL_CORRECT);
      await prefs.remove(KEY_TOTAL_WRONG);
      await prefs.remove(KEY_TOPIC_STATS);
    } catch (e) {
      print('Ошибка очистки статистики: $e');
    }
  }

  static Future<int> getTodaySolved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String today = DateTime.now().toString().substring(0, 10);
      return prefs.getInt('solved_$today') ?? 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<void> incrementTodaySolved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String today = DateTime.now().toString().substring(0, 10);
      int current = prefs.getInt('solved_$today') ?? 0;
      await prefs.setInt('solved_$today', current + 1);
    } catch (e) {
      print('Ошибка сохранения: $e');
    }
  }
}
