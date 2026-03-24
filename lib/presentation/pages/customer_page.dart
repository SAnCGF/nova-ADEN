import 'package:flutter/material.dart';
import '../../core/models/customer.dart';
import '../../core/repositories/customer_repository.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final CustomerRepository _repo = CustomerRepository();
  List<Customer> _customers = [];
  bool _isLoading = true;
  
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _ciController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _ciController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    _customers = await _repo.getAllCustomers();
    setState(() => _isLoading = false);
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final customer = Customer(
      nombre: _nombreController.text.trim(),
      carnetIdentidad: _ciController.text.trim(),
      telefono: _telefonoController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      direccion: _direccionController.text.trim().isEmpty ? null : _direccionController.text.trim(),
    );

    try {
      await _repo.createCustomer(customer);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Cliente registrado')),
      );
      _clearForm();
      _loadCustomers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }

  void _clearForm() {
    _nombreController.clear();
    _ciController.clear();
    _telefonoController.clear();
    _emailController.clear();
    _direccionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(children: [
              // Formulario
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(children: [
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(labelText: 'Nombre *', border: OutlineInputBorder()),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _ciController,
                        decoration: const InputDecoration(labelText: 'Carnet de Identidad *', border: OutlineInputBorder()),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _telefonoController,
                        decoration: const InputDecoration(labelText: 'Teléfono *', border: OutlineInputBorder()),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _direccionController,
                        decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveCustomer,
                            icon: const Icon(Icons.save),
                            label: const Text('Registrar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _clearForm,
                          icon: const Icon(Icons.clear),
                          label: const Text('Limpiar'),
                        ),
                      ]),
                    ]),
                  ),
                ),
              ),
              // Lista
              Expanded(
                child: _customers.isEmpty
                    ? const Center(child: Text('No hay clientes registrados'))
                    : ListView.builder(
                        itemCount: _customers.length,
                        itemBuilder: (ctx, i) {
                          final c = _customers[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.person)),
                              title: Text(c.nombre),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CI: ${c.carnetIdentidad}'),
                                  Text('📞 ${c.telefono}'),
                                  if (c.email != null) Text('✉️ ${c.email}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ]),
    );
  }
}
