// lib/screens/calculator_screen.dart

import 'package:flutter/material.dart';
import 'dart:math';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double _firstNumber = 0;
  String _operator = '';
  bool _isNewNumber = true;
  bool _isResult = false;

  void _onNumberPressed(String number) {
    setState(() {
      if (_isResult) {
        _display = '0';
        _expression = '';
        _isResult = false;
        _isNewNumber = true;
      }

      if (_isNewNumber) {
        _display = number;
        _isNewNumber = false;
      } else {
        if (_display.length < 15) {
          _display += number;
        }
      }
    });
  }

  void _onOperatorPressed(String operator) {
    setState(() {
      _firstNumber = double.parse(_display);
      _operator = operator;
      _expression = '$_display $operator ';
      _isNewNumber = true;
      _isResult = false;
    });
  }

  void _onEqualsPressed() {
    setState(() {
      final secondNumber = double.parse(_display);
      double result = 0;

      switch (_operator) {
        case '+':
          result = _firstNumber + secondNumber;
          break;
        case '−':
          result = _firstNumber - secondNumber;
          break;
        case '×':
          result = _firstNumber * secondNumber;
          break;
        case '÷':
          if (secondNumber != 0) {
            result = _firstNumber / secondNumber;
          } else {
            _display = 'Ошибка';
            _expression = '';
            _isResult = true;
            return;
          }
          break;
        default:
          result = secondNumber;
      }

      _expression = '$_firstNumber $_operator $_display =';
      _display = _formatNumber(result);
      _isResult = true;
      _isNewNumber = true;
    });
  }

  String _formatNumber(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    String formatted = number.toString();
    if (formatted.length > 15) {
      return number.toStringAsFixed(6);
    }
    return formatted;
  }

  void _onClearPressed() {
    setState(() {
      _display = '0';
      _expression = '';
      _firstNumber = 0;
      _operator = '';
      _isNewNumber = true;
      _isResult = false;
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
        _isNewNumber = true;
      }
    });
  }

  void _onPercentPressed() {
    setState(() {
      final number = double.parse(_display);
      final result = number / 100;
      _display = _formatNumber(result);
      _isNewNumber = true;
    });
  }

  void _onSquareRootPressed() {
    setState(() {
      final number = double.parse(_display);
      if (number >= 0) {
        final result = sqrt(number);
        _display = _formatNumber(result);
        _expression = '√$_display';
        _isResult = true;
        _isNewNumber = true;
      } else {
        _display = 'Ошибка';
      }
    });
  }

  void _onSquarePressed() {
    setState(() {
      final number = double.parse(_display);
      final result = number * number;
      _display = _formatNumber(result);
      _expression = '${number}²';
      _isResult = true;
      _isNewNumber = true;
    });
  }

  Widget _buildButton(
    String text,
    Color color, {
    double flex = 1,
    Function? onPressed,
  }) {
    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: onPressed as void Function()? ?? () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(0, 60),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              // Копируем результат в буфер обмена
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Результат скопирован'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Копировать результат',
          ),
        ],
      ),
      body: Column(
        children: [
          // Дисплей
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _expression,
                  style: TextStyle(
                    fontSize: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  _display,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Кнопки калькулятора
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Первая строка
                  Row(
                    children: [
                      _buildButton(
                        'C',
                        Colors.red.shade400,
                        onPressed: _onClearPressed,
                      ),
                      _buildButton(
                        '⌫',
                        Colors.orange.shade400,
                        onPressed: _onDeletePressed,
                      ),
                      _buildButton(
                        '%',
                        Colors.grey.shade600,
                        onPressed: _onPercentPressed,
                      ),
                      _buildButton(
                        '÷',
                        Colors.orange.shade700,
                        onPressed: () => _onOperatorPressed('÷'),
                      ),
                    ],
                  ),
                  // Вторая строка
                  Row(
                    children: [
                      _buildButton(
                        '7',
                        Colors.grey.shade800,
                        onPressed: () => _onNumberPressed('7'),
                      ),
                      _buildButton(
                        '8',
                        Colors.grey.shade800,
                        onPressed: () => _onNumberPressed('8'),
                      ),
                      _buildButton(
                        '9',
                        Colors.grey.shade800,
                        onPressed: () => _onNumberPressed('9'),
                      ),
                      _buildButton(
                        '×',
                        Colors.orange.shade700,
                        onPressed: () => _onOperatorPressed('×'),
                      ),
                    ],
                  ),
                  // Третья строка
                  Row(
                    children: [
                      _buildButton(
                        '4',
                        Colors.grey.shade800,
                        onPressed: () => _onNumberPressed('4'),
                      ),
                      _buildButton(
                        '5',
                        Colors.grey.shade800,
                        onPressed: () => _onNumberPressed('5'),
                      ),
                      _buildButton(
                        '6',
                        Colors.grey.shade800,
                        onPressed: () => _onNumberPressed('6'),
                      ),
                      _buildButton(
                        '−',
                        Colors.orange.shade700,
                        onPressed: () => _onOperatorPressed('−'),
                      ),
                    ],
                  ),
                  // Четвертая строка
                  Row(
                    children: [
                      _buildButton(
                        '1',
                        Colors.grey.shade800,
                        onPressed: () => _onNumberPressed('1'),
                      ),
                      _buildButton(
                        '2',
                        Colors.grey.shade800,
                        onPressed: () => _onNumberPressed('2'),
                      ),
                      _buildButton(
                        '3',
                        Colors.grey.shade800,
                        onPressed: () => _onNumberPressed('3'),
                      ),
                      _buildButton(
                        '+',
                        Colors.orange.shade700,
                        onPressed: () => _onOperatorPressed('+'),
                      ),
                    ],
                  ),
                  // Пятая строка
                  Row(
                    children: [
                      _buildButton(
                        '√',
                        Colors.grey.shade600,
                        onPressed: _onSquareRootPressed,
                      ),
                      _buildButton(
                        'x²',
                        Colors.grey.shade600,
                        onPressed: _onSquarePressed,
                      ),
                      _buildButton(
                        '0',
                        Colors.grey.shade800,
                        flex: 2,
                        onPressed: () => _onNumberPressed('0'),
                      ),
                      _buildButton(
                        '=',
                        Colors.orange.shade700,
                        onPressed: _onEqualsPressed,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
