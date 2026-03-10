import 'package:flutter/material.dart';
import 'package:nova_aden/core/models/supplier.dart';
import 'package:nova_aden/core/repositories/supplier_repository.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  final SupplierRepository _repository = SupplierRepository();
  List<Supplier> _suppliers = [];
  bool _isLoading = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isEditing = false;
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadSuppliers() async {
    setState(() => _isLoading = true);
    try {
      _suppliers = await _repository.getAllSuppliers();
    } catch (e) {
      _showMessage('Error cargando proveedores: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _addressController.clear();
    _editingId = null;
    _isEditing = false;
  }

  Future<void> _saveSupplier() async {
    if (_nameController.text.trim().isEmpty) {
      _showMessage('Nombre requerido');
      return;
    }

    final supplier = Supplier(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
    );

    try {
      if (_isEditing && _editingId != null) {
        await _repository.updateSupplier(_editingId!, supplier);
        _showMessage('Proveedor actualizado');
      } else {
        await _repository.createSupplier(supplier);
        _showMessage('Proveedor creado');
      }
      _loadSuppliers();
      _clearForm();
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  void _editSupplier(Supplier supplier) {
    setState(() {
      _isEditing = true;
      _editingId = supplier.id;
      _nameController.text = supplier.name;
      _phoneController.text = supplier.phone ?? "";
      _emailController.text = supplier.email ?? "";
      _addressController.text = supplier.address ?? "";
    });
  }

  void _deleteSupplier(Supplier supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Proveedor'),
        content: Text('¿Seguro que deseas eliminar "${supplier.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _repository.deleteSupplier(supplier.id!);
        _loadSuppliers();
        _showMessage('Proveedor eliminado');
      } catch (e) {
        _showMessage('Error al eliminar: $e');
      }
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proveedores'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: ElevatedButton.icon(onPressed: _saveSupplier, icon: Icon(_isEditing ? Icons.save : Icons.add), label: Text(_isEditing ? 'Actualizar' : 'Registrar'))),
                      if (_isEditing) const SizedBox(width: 8),
                      if (_isEditing) Expanded(child: OutlinedButton.icon(onPressed: _clearForm, icon: const Icon(Icons.clear), label: const Text('Cancelar'))),
                    ]),
                  ]),
                ),
              ),
              Expanded(
                child: _suppliers.isEmpty
                    ? const Center(child: Text('No hay proveedores registrados'))
                    : ListView.builder(
                        itemCount: _suppliers.length,
                        itemBuilder: (ctx, index) {
                          final supplier = _suppliers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.business)),
                              title: Text(supplier.name),
                              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                if ((supplier.phone ?? "").isNotEmpty) Text('📞 ${supplier.phone}'),
                                if ((supplier.email ?? "").isNotEmpty) Text('✉️ ${supplier.email}'),
                                if ((supplier.address ?? "").isNotEmpty) Text('📍 ${supplier.address}'),
                              ]),
                              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editSupplier(supplier)),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteSupplier(supplier)),
                              ]),
                            ),
                          );
                        },
                      ),
              ),
            ]),
      floatingActionButton: FloatingActionButton.extended(onPressed: _clearForm, icon: const Icon(Icons.refresh), label: const Text('Nuevo')),
    );
  }
}
