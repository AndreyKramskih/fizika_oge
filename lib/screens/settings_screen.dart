// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int tasksCount = 5;
  bool soundEnabled = true;
  // bool vibrationEnabled = true;
  bool examMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      tasksCount = prefs.getInt('tasks_count') ?? 5;
      soundEnabled = prefs.getBool('sound_enabled') ?? true;
      // vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      examMode = prefs.getBool('exam_mode') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasks_count', tasksCount);
    await prefs.setBool('sound_enabled', soundEnabled);
    // await prefs.setBool('vibration_enabled', vibrationEnabled);
    await prefs.setBool('exam_mode', examMode);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Настройки сохранены ✅'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Количество задач
            Card(
              color: colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Количество задач в варианте',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<int>(
                            value: tasksCount,
                            isExpanded: true,
                            items: [5, 10, 15, 20, 25].map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text('$value задач'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                tasksCount = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Рекомендуем: 5 задач для тренировки, 25 для экзамена',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Режим экзамена
            Card(
              color: colorScheme.surface,
              child: SwitchListTile(
                title: const Text('Режим экзамена'),
                subtitle: const Text(
                  '25 задач, ограничение по времени 180 мин',
                ),
                value: examMode,
                onChanged: (value) {
                  setState(() {
                    examMode = value;
                    if (examMode) {
                      tasksCount = 25; // Автоматически меняем количество
                    }
                  });
                },
                activeColor: Colors.orange,
                secondary: Icon(
                  examMode ? Icons.timer : Icons.timer_off,
                  color: examMode ? Colors.orange : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Звук
            // Card(
            //   color: colorScheme.surface,
            //   child: SwitchListTile(
            //     title: const Text('Звуковые эффекты'),
            //     subtitle: const Text('При правильном/неправильном ответе'),
            //     value: soundEnabled,
            //     onChanged: (value) {
            //       setState(() {
            //         soundEnabled = value;
            //       });
            //     },
            //     activeColor: Colors.blue,
            //     secondary: Icon(
            //       soundEnabled ? Icons.volume_up : Icons.volume_off,
            //       color: soundEnabled ? Colors.blue : Colors.grey,
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 12),

            // // Виброотклик
            // Card(
            //   color: colorScheme.surface,
            //   child: SwitchListTile(
            //     title: const Text('Виброотклик'),
            //     subtitle: const Text('При правильном/неправильном ответе'),
            //     value: vibrationEnabled,
            //     onChanged: (value) {
            //       setState(() {
            //         vibrationEnabled = value;
            //       });
            //     },
            //     activeColor: Colors.green,
            //     secondary: Icon(
            //       vibrationEnabled ? Icons.vibration : Icons.notifications_off,
            //       color: vibrationEnabled ? Colors.green : Colors.grey,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 12),

            // Кнопка сброса статистики
            Card(
              color: colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Сбросить статистику'),
                            content: const Text(
                              'Вы уверены? Это действие нельзя отменить.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Сбросить',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          // Сброс статистики
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('total_attempts');
                          await prefs.remove('total_correct');
                          await prefs.remove('total_wrong');
                          await prefs.remove('topic_stats');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Статистика сброшена'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Сбросить статистику'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
