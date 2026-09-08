// lib/main.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fizika_oge/data/tasks_data.dart';
import 'package:fizika_oge/models/task.dart';
import 'package:fizika_oge/providers/theme_provider.dart';
import 'package:fizika_oge/screens/statistics_screen.dart';
import 'package:fizika_oge/screens/cheat_sheet_screen.dart';
import 'package:fizika_oge/screens/settings_screen.dart';
import 'package:fizika_oge/services/statistics_service.dart';
import 'package:fizika_oge/services/feedback_service.dart';
import 'package:fizika_oge/screens/solutions_screen.dart';
import 'dart:async';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'ОГЭ Физика Тренажер',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: themeProvider.themeMode,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Task> currentVariant = [];
  Map<String, String> userAnswers = {};
  bool showResults = false;
  int correctCount = 0;

  String selectedTopic = 'Все темы';
  List<String> get topics => ['Все темы', ...TasksData.getTopics()];

  Timer? _timer;
  int elapsedSeconds = 0;
  bool isTimerRunning = false;

  int tasksPerVariant = 5;
  bool examMode = false;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadSavedState();
    FeedbackService.init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _saveState(); // Сохраняем при закрытии (может не успеть, но попытка не пытка)
    super.dispose();
  }

  // ✅ СОХРАНЕНИЕ В SHARED_PREFERENCES — вызывается при каждом изменении
  void _saveState() {
    try {
      SharedPreferences.getInstance().then((prefs) {
        if (currentVariant.isNotEmpty) {
          List<String> taskIds = currentVariant.map((t) => t.id).toList();
          prefs.setStringList('saved_task_ids', taskIds);
          prefs.setString('saved_answers', jsonEncode(userAnswers));
          prefs.setBool('saved_show_results', showResults);
          prefs.setString('saved_topic', selectedTopic);
          prefs.setInt('saved_elapsed_seconds', elapsedSeconds);
          prefs.setBool('saved_is_timer_running', isTimerRunning);
          // Не выводим логи, чтобы не засорять консоль
        } else {
          prefs.remove('saved_task_ids');
          prefs.remove('saved_answers');
          prefs.remove('saved_show_results');
          prefs.remove('saved_topic');
          prefs.remove('saved_elapsed_seconds');
          prefs.remove('saved_is_timer_running');
        }
      });
    } catch (e) {
      // Игнорируем ошибки
    }
  }

  // ✅ ЗАГРУЗКА
  Future<void> _loadSavedState() async {
    try {
      print('📂 ЗАГРУЗКА...');
      final prefs = await SharedPreferences.getInstance();

      List<String>? savedTaskIds = prefs.getStringList('saved_task_ids');

      if (savedTaskIds == null || savedTaskIds.isEmpty) {
        print('ℹ️ Нет сохраненных задач');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (TasksData.allTasks.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 100));
        await _loadSavedState();
        return;
      }

      List<Task> restoredTasks = [];
      for (String id in savedTaskIds) {
        try {
          final task = TasksData.allTasks.firstWhere((t) => t.id == id);
          restoredTasks.add(task);
        } catch (e) {
          print('⚠️ Задача с ID $id не найдена');
        }
      }

      if (restoredTasks.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String? savedAnswers = prefs.getString('saved_answers');
      Map<String, String> restoredAnswers = {};
      if (savedAnswers != null && savedAnswers.isNotEmpty) {
        try {
          Map<String, dynamic> decoded = jsonDecode(savedAnswers);
          restoredAnswers = decoded.map(
            (key, value) => MapEntry(key, value.toString()),
          );
        } catch (e) {}
      }

      bool restoredShowResults = prefs.getBool('saved_show_results') ?? false;
      String restoredTopic = prefs.getString('saved_topic') ?? 'Все темы';
      int restoredElapsedSeconds = prefs.getInt('saved_elapsed_seconds') ?? 0;
      bool restoredIsTimerRunning =
          prefs.getBool('saved_is_timer_running') ?? false;

      setState(() {
        currentVariant = restoredTasks;
        userAnswers = restoredAnswers;
        showResults = restoredShowResults;
        selectedTopic = restoredTopic;
        elapsedSeconds = restoredElapsedSeconds;
        isTimerRunning = restoredIsTimerRunning;
        _isLoading = false;

        if (isTimerRunning && !showResults) {
          _startTimerFromSaved();
        }
      });

      print('✅ ЗАГРУЖЕНО: ${restoredTasks.length} задач');
    } catch (e) {
      print('❌ Ошибка загрузки: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startTimerFromSaved() {
    if (isTimerRunning) return;
    setState(() {
      isTimerRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          elapsedSeconds++;
        });
      }
    });
  }

  void _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        tasksPerVariant = prefs.getInt('tasks_count') ?? 5;
        examMode = prefs.getBool('exam_mode') ?? false;
      });
    } catch (e) {}
  }

  void startTimer() {
    if (isTimerRunning) return;
    setState(() {
      isTimerRunning = true;
      elapsedSeconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          elapsedSeconds++;
        });
      }
    });
  }

  void stopTimer() {
    setState(() {
      isTimerRunning = false;
    });
    _timer?.cancel();
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void generateVariant() {
    stopTimer();

    setState(() {
      List<Task> pool;
      if (selectedTopic == 'Все темы') {
        pool = TasksData.allTasks;
      } else {
        pool = TasksData.getTasksByTopic(selectedTopic);
      }

      if (pool.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Нет задач по выбранной теме'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        return;
      }

      _loadSettings();

      final shuffled = List<Task>.from(pool)..shuffle();
      int count = examMode ? 25 : tasksPerVariant;
      if (shuffled.length < count) count = shuffled.length;
      currentVariant = shuffled.take(count).toList();
      userAnswers = {};
      showResults = false;
      correctCount = 0;
    });

    startTimer();
    _saveState(); // ✅ СОХРАНЯЕМ
  }

  void checkAnswers() {
    stopTimer();

    setState(() {
      showResults = true;
      correctCount = 0;
      Map<String, int> topicResults = {};

      for (var task in currentVariant) {
        final userAnswer = userAnswers[task.id]?.trim() ?? '';
        if (userAnswer == task.answer) {
          correctCount++;
          topicResults[task.topic] = (topicResults[task.topic] ?? 0) + 1;
        }
      }

      StatisticsService.saveResult(
        correctCount,
        currentVariant.length - correctCount,
        topicResults,
      );
    });

    _provideFeedback();
    _saveState(); // ✅ СОХРАНЯЕМ
  }

  void _provideFeedback() {
    int total = currentVariant.length;
    int correct = correctCount;

    if (correct == total) {
      FeedbackService.correctFeedback();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Отлично! Все задачи решены правильно!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      _clearSavedState();
    } else if (correct >= total * 0.6) {
      FeedbackService.correctFeedback();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Хороший результат! Правильно: $correct из $total'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
      _clearSavedState();
    } else if (correct > 0) {
      FeedbackService.wrongFeedback();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '📚 Нужно еще тренироваться! Правильно: $correct из $total',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      _clearSavedState();
    } else {
      FeedbackService.wrongFeedback();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '😅 Ни одного правильного ответа! Давайте повторим формулы в шпаргалке!',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      _clearSavedState();
    }
  }

  void _clearSavedState() {
    try {
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('saved_task_ids');
        prefs.remove('saved_answers');
        prefs.remove('saved_show_results');
        prefs.remove('saved_topic');
        prefs.remove('saved_elapsed_seconds');
        prefs.remove('saved_is_timer_running');
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Тренажер ОГЭ Физика'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Загрузка...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тренажер ОГЭ Физика'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Кнопка "Как решать"
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SolutionsScreen(),
                ),
              );
            },
            tooltip: 'Как решать',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ).then((_) => _loadSettings());
            },
            tooltip: 'Настройки',
          ),
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CheatSheetScreen(),
                ),
              );
            },
            tooltip: 'Шпаргалка',
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            tooltip: 'Сменить тему',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
            tooltip: 'Статистика',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: selectedTopic,
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: colorScheme.surface,
                items: topics.map((topic) {
                  return DropdownMenuItem(
                    value: topic,
                    child: Text(
                      topic,
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTopic = value!;
                  });
                  _saveState(); // ✅ СОХРАНЯЕМ
                },
                style: TextStyle(color: colorScheme.onSurface),
                icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: generateVariant,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Создать вариант'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (currentVariant.isNotEmpty && !showResults)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: checkAnswers,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Проверить'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                if (isTimerRunning || elapsedSeconds > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: elapsedSeconds > 60
                            ? Colors.red.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer,
                            size: 18,
                            color: elapsedSeconds > 60
                                ? Colors.red
                                : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formatTime(elapsedSeconds),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: elapsedSeconds > 60
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 15),

            if (currentVariant.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.primaryContainer),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Всего задач',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${currentVariant.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: colorScheme.outlineVariant,
                    ),
                    Column(
                      children: [
                        Text(
                          'Решено',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${userAnswers.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    if (showResults) ...[
                      Container(
                        width: 1,
                        height: 30,
                        color: colorScheme.outlineVariant,
                      ),
                      Column(
                        children: [
                          Text(
                            'Правильно',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '$correctCount/${currentVariant.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: correctCount == currentVariant.length
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 15),

            Expanded(
              child: currentVariant.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 80,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Нажмите "Создать вариант"',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'для начала тренировки',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withOpacity(
                                0.3,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Всего доступно ${TasksData.allTasks.length} задач',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: currentVariant.length,
                      itemBuilder: (context, index) {
                        final task = currentVariant[index];
                        final userAnswer = userAnswers[task.id] ?? '';
                        final isCorrect =
                            showResults && userAnswer.trim() == task.answer;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          color: colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: showResults
                                ? BorderSide(
                                    color: isCorrect
                                        ? Colors.green
                                        : Colors.red,
                                    width: 2,
                                  )
                                : BorderSide(
                                    color: colorScheme.outlineVariant,
                                    width: 0.5,
                                  ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: colorScheme.primaryContainer,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme
                                                    .onPrimaryContainer,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          task.topic,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceVariant,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Сложность: ${'⭐' * task.difficulty}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  task.question,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: 'Введите ответ...',
                                          hintStyle: TextStyle(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: colorScheme.outline,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: showResults
                                                  ? (isCorrect
                                                        ? Colors.green
                                                        : Colors.red)
                                                  : colorScheme.primary,
                                              width: 2,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: colorScheme.outline,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                          suffixIcon: showResults
                                              ? Icon(
                                                  isCorrect
                                                      ? Icons.check_circle
                                                      : Icons.cancel,
                                                  color: isCorrect
                                                      ? Colors.green
                                                      : Colors.red,
                                                )
                                              : null,
                                          fillColor: showResults
                                              ? (isCorrect
                                                    ? Colors.green.withOpacity(
                                                        0.1,
                                                      )
                                                    : Colors.red.withOpacity(
                                                        0.1,
                                                      ))
                                              : Colors.transparent,
                                          filled: showResults,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            userAnswers[task.id] = value;
                                          });
                                          _saveState(); // ✅ СОХРАНЯЕМ ПРИ ВВОДЕ
                                        },
                                        enabled: !showResults,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    if (showResults)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(
                                              0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Правильный ответ:',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                              Text(
                                                task.answer,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.green.shade800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (showResults && !isCorrect)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Ваш ответ: ${userAnswer.isEmpty ? '(не введен)' : userAnswer}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red.shade600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
