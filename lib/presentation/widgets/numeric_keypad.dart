import 'package:flutter/material.dart';

class NumericKeypad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  const NumericKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onBackspace,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(children: _buildRow(['1', '2', '3'])),
          Row(children: _buildRow(['4', '5', '6'])),
          Row(children: _buildRow(['7', '8', '9'])),
          Row(children: [
            Expanded(child: _buildButton('0', onNumberPressed)),
            Expanded(child: _buildButton('.', onNumberPressed)),
            Expanded(child: IconButton(icon: const Icon(Icons.backspace, color: Colors.red), onPressed: onBackspace)),
          ]),
          Row(children: [Expanded(child: _buildButton('C', onClear, color: Colors.orange))]),
        ],
      ),
    );
  }

  List<Widget> _buildRow(List<String> numbers) {
    return numbers.map((n) => Expanded(child: _buildButton(n, onNumberPressed))).toList();
  }

  Widget _buildButton(String text, Function(String) onPressed, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: () => onPressed(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
