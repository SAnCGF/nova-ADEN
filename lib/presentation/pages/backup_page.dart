import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/repositories/settings_repository.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final SettingsRepository _repository = SettingsRepository();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Respaldos'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _repository.getBackups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final backups = snapshot.data ?? [];
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ubicación de Respaldos',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Android/data/com.novaaden.nova_aden/archivos/nova_aden_backups/',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.backup),
                              label: const Text('Crear Respaldo'),
                              onPressed: _crearRespaldo,
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.restore),
                              label: const Text('Restaurar'),
                              onPressed: _restaurarRespaldo,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: backups.isEmpty
                    ? const Center(child: Text('No hay respaldos disponibles'))
                    : ListView.builder(
                        itemCount: backups.length,
                        itemBuilder: (context, index) {
                          final backup = backups[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.folder),
                              title: Text(backup['nombre'] ?? 'Respaldo'),
                              subtitle: Text(backup['fecha'] ?? ''),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.share),
                                    onPressed: () => _compartirRespaldo(backup['path']),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _eliminarRespaldo(backup['path']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _crearRespaldo() async {
    setState(() => _isLoading = true);
    final exito = await _repository.crearRespaldo();
    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exito ? '✅ Respaldo creado' : '❌ Error al crear respaldo'),
          backgroundColor: exito ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _restaurarRespaldo() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restaurar Respaldo'),
        content: const Text('¿Estás seguro? Los datos actuales se perderán.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Restaurar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      setState(() => _isLoading = true);
      final exito = await _repository.restaurarRespaldo();
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exito ? '✅ Respaldo restaurado' : '❌ Error al restaurar'),
            backgroundColor: exito ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _compartirRespaldo(String path) async {
    await _repository.shareBackup(path);
  }

  Future<void> _eliminarRespaldo(String path) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Respaldo'),
        content: const Text('¿Estás seguro de eliminar este respaldo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      setState(() => _isLoading = true);
      final exito = await _repository.deleteBackup(path);
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exito ? '✅ Respaldo eliminado' : '❌ Error al eliminar'),
            backgroundColor: exito ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
