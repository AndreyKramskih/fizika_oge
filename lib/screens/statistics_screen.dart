// lib/screens/statistics_screen.dart

import 'package:flutter/material.dart';
import '../services/statistics_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, dynamic> stats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      isLoading = true;
    });
    final data = await StatisticsService.getStatistics();
    setState(() {
      stats = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Моя статистика'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
            tooltip: 'Обновить',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Очистить статистику'),
                  content: const Text(
                    'Вы уверены, что хотите удалить всю статистику? Это действие нельзя отменить.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Отмена',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Удалить',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await StatisticsService.clearStatistics();
                await _loadStats();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Статистика очищена'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            tooltip: 'Очистить статистику',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    color: colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Общая статистика',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Попыток',
                                stats['totalAttempts']?.toString() ?? '0',
                                Colors.blue,
                                colorScheme,
                              ),
                              _buildStatItem(
                                'Правильно',
                                stats['totalCorrect']?.toString() ?? '0',
                                Colors.green,
                                colorScheme,
                              ),
                              _buildStatItem(
                                'Неправильно',
                                stats['totalWrong']?.toString() ?? '0',
                                Colors.red,
                                colorScheme,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value:
                                (stats['totalCorrect'] ?? 0) > 0 ||
                                    (stats['totalWrong'] ?? 0) > 0
                                ? (stats['totalCorrect'] ?? 0) /
                                      ((stats['totalCorrect'] ?? 0) +
                                          (stats['totalWrong'] ?? 0))
                                : 0,
                            backgroundColor: Colors.red.withOpacity(0.2),
                            color: Colors.green,
                            minHeight: 8,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Точность: ${(stats['totalCorrect'] ?? 0) > 0 || (stats['totalWrong'] ?? 0) > 0 ? (((stats['totalCorrect'] ?? 0) / ((stats['totalCorrect'] ?? 0) + (stats['totalWrong'] ?? 0))) * 100).toStringAsFixed(0) : 0}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      color: colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'По темам',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child:
                                  (stats['topicStats'] as Map<String, int>?)
                                          ?.isEmpty ??
                                      true
                                  ? Center(
                                      child: Text(
                                        'Нет данных',
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount:
                                          (stats['topicStats'] as Map).length,
                                      itemBuilder: (context, index) {
                                        final entry =
                                            (stats['topicStats']
                                                    as Map<String, int>)
                                                .entries
                                                .toList()[index];
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                colorScheme.primaryContainer,
                                            child: Text(
                                              entry.value.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme
                                                    .onPrimaryContainer,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            entry.key,
                                            style: TextStyle(
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          trailing: Text(
                                            '${entry.value} правильно',
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
