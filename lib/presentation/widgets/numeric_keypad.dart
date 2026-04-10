import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onConfirm;

  const NumericKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onBackspace,
    required this.onClear,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: _buildRow(['7', '8', '9'])),
        Row(children: _buildRow(['4', '5', '6'])),
        Row(children: _buildRow(['1', '2', '3'])),
        Row(children: [
          _buildKey('C', Colors.red, onClear),
          _buildKey('0', Colors.blue, () => onNumberPressed('0')),
          _buildKey('⌫', Colors.orange, onBackspace),
        ]),
        ElevatedButton(
          onPressed: onConfirm,
          child: const Text('Confirmar', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
        ),
      ],
    );
  }

  List<Widget> _buildRow(List<String> numbers) {
    return numbers.map((n) => _buildKey(n, Colors.blue, () => onNumberPressed(n))).toList();
  }

  Widget _buildKey(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: onTap,
          child: Text(label, style: const TextStyle(fontSize: 24)),
          style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(60, 60)),
        ),
      ),
    );
  }
}
