import 'package:flutter/material.dart';

class NumericKeyboard extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback? onBackspace;
  final VoidCallback? onClear;

  const NumericKeyboard({
    super.key,
    required this.onNumberPressed,
    this.onBackspace,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              _buildKey('1', () => onNumberPressed('1')),
              _buildKey('2', () => onNumberPressed('2')),
              _buildKey('3', () => onNumberPressed('3')),
            ],
          ),
          Row(
            children: [
              _buildKey('4', () => onNumberPressed('4')),
              _buildKey('5', () => onNumberPressed('5')),
              _buildKey('6', () => onNumberPressed('6')),
            ],
          ),
          Row(
            children: [
              _buildKey('7', () => onNumberPressed('7')),
              _buildKey('8', () => onNumberPressed('8')),
              _buildKey('9', () => onNumberPressed('9')),
            ],
          ),
          Row(
            children: [
              _buildKey('C', () => onClear?.call(), color: Colors.red),
              _buildKey('0', () => onNumberPressed('0')),
              _buildKeyIcon(Icons.backspace_outlined, () => onBackspace?.call(), color: Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String value, VoidCallback onPressed, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.white,
            foregroundColor: color == Colors.red ? Colors.white : Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyIcon(IconData icon, VoidCallback onPressed, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.white,
            foregroundColor: color == Colors.orange ? Colors.white : Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Icon(icon, size: 28),
        ),
      ),
    );
  }
}
