import 'package:flutter/material.dart';
import 'package:nova_aden/core/models/backup.dart';
import 'package:nova_aden/core/repositories/settings_repository.dart';
import 'package:intl/intl.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  final SettingsRepository _repository = SettingsRepository();
  List<Backup> _backups = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() => _isLoading = true);
    _backups = await _repository.getBackups();
    setState(() => _isLoading = false);
  }

  Future<void> _createBackup() async {
    final type = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tipo de Respaldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Respaldo Manual'),
              subtitle: const Text('Crear respaldo ahora'),
              onTap: () => Navigator.pop(ctx, 'manual'),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Configurar Automático'),
              subtitle: const Text('Programar respaldos automáticos'),
              onTap: () => Navigator.pop(ctx, 'automatic'),
            ),
          ],
        ),
      ),
    );

    if (type == null) return;

    if (type == 'manual') {
      setState(() => _isLoading = true);
      final path = await _repository.createBackup(type: 'manual');
      setState(() => _isLoading = false);

      if (path.isNotEmpty && mounted) {
        _showSnackBar('✅ Respaldo creado exitosamente');
        _loadBackups();
        
        // Ofrecer compartir
        final share = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Compartir Respaldo'),
            content: const Text('¿Deseas compartir el respaldo por email, Telegram, etc.?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sí')),
            ],
          ),
        );
        
        if (share == true) {
          'Compartir: Usa el gestor de archivos de tu Android para compartir desde:
/storage/emulated/0/Android/data/com.novaaden.nova_aden/files/nova_aden_backups/';
        }
      } else {
        _showSnackBar('❌ Error al crear respaldo', isError: true);
      }
    } else {
      _showSnackBar('Función de respaldo automático en desarrollo');
    }
  }

  Future<void> _restoreBackup(Backup backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Restaurar Respaldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Archivo: ${backup.fileName}'),
            Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(backup.date)}'),
            const SizedBox(height: 16),
            const Text('⚠️ Esto reemplazará todos los datos actuales. ¿Estás seguro?', style: TextStyle(color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    final success = await _repository.restoreBackup(backup.path);
    setState(() => _isLoading = false);

    if (success && mounted) {
      _showSnackBar('✅ Datos restaurados exitosamente');
      _loadBackups();
    } else {
      _showSnackBar('❌ Error al restaurar respaldo', isError: true);
    }
  }

  Future<void> _deleteBackup(Backup backup) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Respaldo'),
        content: Text('¿Eliminar ${backup.fileName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await _repository.deleteBackup(backup.path);
    if (success && mounted) {
      _showSnackBar('✅ Respaldo eliminado');
      _loadBackups();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Respaldos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () async {
              if (success && mounted) {
                _showSnackBar('✅ Respaldo importado exitosamente');
                _loadBackups();
              }
            },
            tooltip: 'Importar Respaldo',
          ),
        ],
      ),
      body: Column(
        children: [
          // Botón crear respaldo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _createBackup,
              icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.backup),
              label: Text(_isLoading ? 'Creando...' : 'Crear Respaldo Ahora'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          
          // Lista de respaldos
          Expanded(
            child: _isLoading && _backups.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _backups.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('No hay respaldos', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            Text('Crea tu primer respaldo para proteger tus datos', style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _backups.length,
                        itemBuilder: (context, index) {
                          final backup = _backups[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: backup.type == 'automatic' ? Colors.blue : Colors.green,
                                child: Icon(backup.type == 'automatic' ? Icons.schedule : Icons.backup, color: Colors.white),
                              ),
                              title: Text(backup.fileName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat('dd/MM/yyyy HH:mm').format(backup.date)),
                                  Text('${backup.fileSizeFormatted} • ${backup.type == 'automatic' ? 'Automático' : 'Manual'}'),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'restore') _restoreBackup(backup);
                                  if (v == 'share') _repository.shareBackup(backup.path);
                                  if (v == 'delete') _deleteBackup(backup);
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(value: 'restore', child: Row(children: [Icon(Icons.restore, size: 18), SizedBox(width: 8), Text('Restaurar')])),
                                  const PopupMenuItem(value: 'share', child: Row(children: [Icon(Icons.share, size: 18), SizedBox(width: 8), Text('Compartir')])),
                                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: Colors.red))])),
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
