import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();

  void _sendFeedback() async {
    if (_messageController.text.isEmpty) {
      _showSnackBar('⚠️ Escribe tu mensaje', Colors.orange);
      return;
    }

    final subject = _subjectController.text.isEmpty 
        ? 'Feedback Nova ADEN' 
        : _subjectController.text;
    
    final body = '''
Mensaje: ${_messageController.text}
Email: ${_emailController.text.isEmpty ? 'No proporcionado' : _emailController.text}
Fecha: ${DateTime.now().toString()}
    ''';

    await Share.shareUri(
      Uri(
        scheme: 'mailto',
        path: 'soporte@nova-aden.com',
        query: 'subject=$subject&body=$body',
      ),
    );

    if (mounted) {
      _showSnackBar('✅ Gracias por tu feedback', Colors.green);
      Navigator.of(context).pop();
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Asunto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Tu Email (opcional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Mensaje',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _sendFeedback,
                icon: const Icon(Icons.send),
                label: const Text('ENVIAR FEEDBACK'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
