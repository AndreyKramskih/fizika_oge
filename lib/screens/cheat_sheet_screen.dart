// lib/screens/cheat_sheet_screen.dart

import 'package:flutter/material.dart';
import '../data/formulas_data.dart';

class CheatSheetScreen extends StatefulWidget {
  const CheatSheetScreen({super.key});

  @override
  State<CheatSheetScreen> createState() => _CheatSheetScreenState();
}

class _CheatSheetScreenState extends State<CheatSheetScreen> {
  String selectedTopic = 'Все темы';
  List<String> get topics => ['Все темы', ...FormulasData.getTopics()];

  List<Formula> get filteredFormulas {
    if (selectedTopic == 'Все темы') {
      return FormulasData.allFormulas;
    }
    return FormulasData.getFormulasByTopic(selectedTopic);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Шпаргалка по формулам'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              // Показываем количество формул
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Всего формул: ${FormulasData.allFormulas.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            tooltip: 'Всего формул',
          ),
        ],
      ),
      body: Column(
        children: [
          // Фильтр по темам
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
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
                },
                style: TextStyle(color: colorScheme.onSurface),
                icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
              ),
            ),
          ),

          // Список формул
          Expanded(
            child: filteredFormulas.isEmpty
                ? Center(
                    child: Text(
                      'Нет формул по выбранной теме',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredFormulas.length,
                    itemBuilder: (context, index) {
                      final formula = filteredFormulas[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
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
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      formula.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.green.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      formula.topic,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.green.shade900.withOpacity(0.3)
                                      : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.green.shade700
                                        : Colors.green.shade200,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    formula.formula,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.green.shade200
                                          : Colors.green.shade800,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      formula.description,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colorScheme.onSurfaceVariant,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
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
    );
  }
}
