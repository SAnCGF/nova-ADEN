import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import '../../core/models/product.dart';
import '../../core/models/customer.dart';
import '../../core/models/sale.dart';
import '../../core/database/database_helper.dart';
import '../../core/repositories/product_repository.dart';
import '../../core/repositories/customer_repository.dart';
import '../../core/repositories/sale_repository.dart';
import 'paused_sales_page.dart';

class PosPage extends StatefulWidget {
  const PosPage({super.key});
  @override
  State<PosPage> createState() => _PosPageState();
}

class _PosPageState extends State<PosPage> {
  final _productRepo = ProductRepository();
  final _customerRepo = CustomerRepository();
  final _saleRepo = SaleRepository();
  
  List<CartItem> _cart = [];
  List<Product> _products = [];
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  bool _isLoading = true;
  final _searchController = TextEditingController();
  
  double _amountPaid = 0.0;
  String _selectedCurrency = 'CUP';
  bool _isCredit = false;
  String _creditNotes = '';
  final _pauseNameController = TextEditingController();

  @override
  void initState() { 
    super.initState(); 
    _loadData(); 
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _products = await _productRepo.getAllProducts();
    _customers = await _customerRepo.getAllCustomers();
    setState(() => _isLoading = false);
  }

  void _addToCart(Product product) {
    if (product.stockActual <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Sin stock'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() {
      final existing = _cart.indexWhere((c) => c.productoId == product.id);
      if (existing >= 0) {
        if (_cart[existing].cantidad < product.stockActual) {
          _cart[existing].cantidad++;
        }
      } else {
        _cart.add(CartItem(
          productoId: product.id!,
          nombre: product.nombre,
          precio: product.precioVenta,
          cantidad: 1,
          stockDisponible: product.stockActual,
        ));
      }
    });
  }

  void _increaseQuantity(int index) {
    if (index >= 0 && index < _cart.length) {
      final item = _cart[index];
      final product = _products.firstWhere((p) => p.id == item.productoId);
      if (item.cantidad < product.stockActual) {
        setState(() => item.cantidad++);
      }
    }
  }

  void _decreaseQuantity(int index) {
    if (index >= 0 && index < _cart.length) {
      setState(() {
        _cart[index].cantidad--;
        if (_cart[index].cantidad <= 0) _cart.removeAt(index);
      });
    }
  }

  void _removeFromCart(int index) => setState(() => _cart.removeAt(index));
  void _clearCart() => setState(() => _cart.clear());
  double get _total => _cart.fold(0.0, (sum, c) => sum + c.subtotal);

  Future<void> _pauseSale() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Agrega productos'), backgroundColor: Colors.orange),
      );
      return;
    }
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⏸️ Pausar Venta'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Nombre (ej: Mesa 1)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop('pause'),
            child: const Text('Pausar'),
          ),
        ],
      ),
    );
    if (name != null) {
      try {
        final db = await DatabaseHelper.instance.database;
        await db.insert('ventas_pausadas', {
          'nombre': name,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'cliente_id': _selectedCustomer?.id,
          'productos': jsonEncode(_cart.map((c) => c.toMap()).toList()),
          'total': _total,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Venta pausada'), backgroundColor: Colors.green),
        );
        _clearCart();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _resumeSale() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PausedSalesPage()),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _cart = (jsonDecode(result['productos'] as String) as List)
            .map((p) => CartItem.fromMap(p))
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Venta retomada'), backgroundColor: Colors.green),
      );
    }
  }

  // RF 52: Teclado numérico grande
  void _showNumericKeypad() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💵 Ingresar Monto',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('\$${_amountPaid.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2,
                children: [
                  for (var i = 1; i <= 9; i++)
                    ElevatedButton(
                      onPressed: () => setModalState(() {
                        _amountPaid =
                            double.parse('${(_amountPaid * 100).toInt()}$i') /
                                100;
                      }),
                      child: Text('$i', style: const TextStyle(fontSize: 24)),
                    ),
                  ElevatedButton(
                    onPressed: () => setModalState(() => _amountPaid = 0),
                    child: const Text('C',
                        style: TextStyle(fontSize: 24, color: Colors.red)),
                  ),
                  ElevatedButton(
                    onPressed: () => setModalState(() {
                      _amountPaid =
                          double.parse('${(_amountPaid * 100).toInt()}0') /
                              100;
                    }),
                    child: const Text('0', style: TextStyle(fontSize: 24)),
                  ),
                  ElevatedButton(
                    onPressed: () => setModalState(() {
                      _amountPaid = (_amountPaid * 100).toInt() ~/ 10 / 100;
                    }),
                    child: const Text('⌫', style: TextStyle(fontSize: 24)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('LISTO',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeSale() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Carrito vacío'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    if (!_isCredit && _amountPaid < _total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Pago insuficiente'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    try {
      final lines = _cart
          .map((c) => SaleLine(
                ventaId: 0,
                productoId: c.productoId,
                cantidad: c.cantidad,
                precioUnitario: c.precio,
                subtotal: c.subtotal,
              ))
          .toList();
      await _saleRepo.createSale(
        _selectedCustomer?.id,
        lines,
        _total,
        _isCredit ? _amountPaid : _total,
        _isCredit ? (_total - _amountPaid) : 0.0,
        _creditNotes,
        _selectedCurrency,
        1.0,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('✅ Venta: \$${_total.toStringAsFixed(2)}'),
            backgroundColor: Colors.green),
      );
      _clearCart();
      _amountPaid = 0.0;
      _isCredit = false;
      _creditNotes = '';
      _loadData();
      if (Navigator.canPop(context)) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('🛒 Carrito',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      _buildCustomerSection(setModalState),
                      _buildCartItems(setModalState),
                      _buildCurrencySection(setModalState),
                      _buildPaymentSection(setModalState),
                      _buildCreditSection(setModalState),
                      _buildTotalSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSection(Function setModalState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cliente:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add),
                label: const Text('Nuevo'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<Customer>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Cliente General')),
              ..._customers.map((c) => DropdownMenuItem(value: c, child: Text(c.nombre))),
            ],
            value: _selectedCustomer,
            onChanged: (v) => setModalState(() => _selectedCustomer = v),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(Function setModalState) {
    if (_cart.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text('Carrito vacío',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _cart.length,
      itemBuilder: (ctx, i) {
        final c = _cart[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text('${c.cantidad}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(c.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('\$${c.precio.toStringAsFixed(2)} c/u'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red, size: 28),
                  onPressed: () {
                    _decreaseQuantity(i);
                    setModalState(() {});
                  },
                ),
                Text('${c.cantidad}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green, size: 28),
                  onPressed: () {
                    _increaseQuantity(i);
                    setModalState(() {});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () {
                    _removeFromCart(i);
                    setModalState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencySection(Function setModalState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💱 Moneda', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(border: OutlineInputBorder()),
                value: _selectedCurrency,
                items: const [
                  DropdownMenuItem(value: 'CUP', child: Text('🇨🇺 CUP')),
                  DropdownMenuItem(value: 'MLC', child: Text('💳 MLC')),
                  DropdownMenuItem(value: 'USD', child: Text('🇺🇸 USD')),
                ],
                onChanged: (v) => setModalState(() => _selectedCurrency = v!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSection(Function setModalState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💵 Pago', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Monto pagado',
                      ),
                      controller: TextEditingController(
                          text: _amountPaid > 0
                              ? '\$${_amountPaid.toStringAsFixed(2)}'
                              : ''),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _showNumericKeypad,
                    icon: const Icon(Icons.keyboard),
                    label: const Text('Teclado'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditSection(Function setModalState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('⚠️ Marcar como Fiado',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Switch(
                    value: _isCredit,
                    onChanged: (v) => setModalState(() => _isCredit = v),
                  ),
                ],
              ),
              if (_isCredit) ...[
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Notas de crédito',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (v) => _creditNotes = v,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('\$${_total.toStringAsFixed(2)} ($_selectedCurrency)',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _cart.isEmpty ? null : _completeSale,
              icon: const Icon(Icons.check_circle, size: 24),
              label: const Text('CONFIRMAR VENTA',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto de Venta'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            onPressed: _resumeSale,
            tooltip: 'Retomar',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          if (_cart.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearCart,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar producto...',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _products
                        .where((p) => p.nombre
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()))
                        .length,
                    itemBuilder: (ctx, i) {
                      final p = _products
                          .where((prod) => prod.nombre
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase()))
                          .toList()[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                p.stockActual > 0 ? Colors.blue : Colors.grey,
                            child: Icon(Icons.inventory_2, color: Colors.white),
                          ),
                          title: Text(p.nombre,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Stock: ${p.stockActual}'),
                              Text('\$${p.precioVenta.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: p.stockActual > 0
                                ? () => _addToCart(p)
                                : null,
                            child: const Text('Agregar'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_cart.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${_cart.length} productos',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                              Text('Total: \$${_total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.pause_circle, size: 32),
                          onPressed: _pauseSale,
                          tooltip: 'Pausar',
                        ),
                        SizedBox(
                          width: 180,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _showCartBottomSheet,
                            icon: const Icon(Icons.shopping_cart, size: 20),
                            label: const Text('VER CARRITO',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pauseNameController.dispose();
    super.dispose();
  }
}

class CartItem {
  final int productoId;
  final String nombre;
  final double precio;
  int cantidad;
  final int stockDisponible;

  CartItem({
    required this.productoId,
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.stockDisponible,
  });

  double get subtotal => precio * cantidad;

  Map<String, dynamic> toMap() => {
        'productoId': productoId,
        'nombre': nombre,
        'precio': precio,
        'cantidad': cantidad,
        'stockDisponible': stockDisponible,
      };

  factory CartItem.fromMap(Map<String, dynamic> map) => CartItem(
        productoId: map['productoId'] as int,
        nombre: map['nombre'] as String,
        precio: (map['precio'] as num).toDouble(),
        cantidad: map['cantidad'] as int,
        stockDisponible: map['stockDisponible'] as int,
      );
}
