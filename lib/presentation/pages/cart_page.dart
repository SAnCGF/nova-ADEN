import 'package:flutter/material.dart';
import 'package:nova_aden/core/repositories/sale_repository.dart';
import 'package:nova_aden/core/models/product.dart';
import 'package:nova_aden/core/models/cart_item.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cart;
  final double discount;
  
  const CartPage({
    super.key,
    required this.cart,
    this.discount = 0,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final SaleRepository _saleRepo = SaleRepository();
  final _customerController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isProcessing = false;
  bool _hasCustomer = false;
  
  double get _subtotal {
    return widget.cart.fold(0.0, (sum, item) => sum + (item.product.precioVenta * item.quantity));
  }
  
  double get _total {
    return _subtotal - widget.discount;
  }

  @override
  void dispose() {
    _customerController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _updateQuantity(int index, int quantity) {
    if (quantity <= 0) {
      setState(() => widget.cart.removeAt(index));
    } else {
      setState(() => widget.cart[index].quantity = quantity);
    }
  }

  void _removeItem(int index) {
    setState(() => widget.cart.removeAt(index));
  }

  void _showCustomerDialog() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('👤 Datos del Cliente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _customerController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Cliente *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Carnet de Identidad *',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono (opcional)',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              Text(
                '* Nombre y Carnet son obligatorios',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _customerController.clear();
              _idController.clear();
              _phoneController.clear();
              setState(() => _hasCustomer = false);
              Navigator.of(ctx).pop();
            },
            child: const Text('Limpiar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_customerController.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('El nombre del cliente es obligatorio')),
                );
                return;
              }
              if (_idController.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('El carnet de identidad es obligatorio')),
                );
                return;
              }
              setState(() => _hasCustomer = true);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A5F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeSale() async {
    if (widget.cart.isEmpty) {
      _showSnackBar('⚠️ El carrito está vacío', Colors.orange);
      return;
    }

    if (_customerController.text.isNotEmpty && !_hasCustomer) {
      _hasCustomer = true;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Venta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasCustomer && _customerController.text.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('👤 Cliente: ${_customerController.text}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (_idController.text.isNotEmpty) Text('🆔 Carnet: ${_idController.text}'),
                    if (_phoneController.text.isNotEmpty) Text('📱 ${_phoneController.text}'),
                  ],
                ),
              ),
              const Divider(),
            ],
            Text('📦 Productos: ${widget.cart.length}'),
            Text('💰 Total: \$${_total.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('¿Desea completar la venta?', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A5F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      final saleData = {
        'numero_venta': DateTime.now().millisecondsSinceEpoch.toString(),
        'fecha': DateTime.now().toIso8601String(),
        'total': _total,
        'estado': 'completed',
        'cliente': _hasCustomer ? _customerController.text : 'Cliente General',
        'identidad': _idController.text,
        'telefono': _phoneController.text,
      };

      final items = widget.cart.map((item) => {
        'producto_id': item.product.id,
        'nombre_producto': item.product.nombre,
        'cantidad': item.quantity,
        'precio_unitario': item.product.precioVenta,
        'subtotal': item.product.precioVenta * item.quantity,
        'descuento': 0.0,
        'total': item.product.precioVenta * item.quantity,
      }).toList();

      final saleId = await _saleRepo.registerSale(saleData, items, true);

      if (mounted) {
        if (saleId > 0) {
          _showSnackBar('✅ Venta registrada exitosamente', Colors.green);
          Navigator.of(context).pop(true);
        } else {
          _showSnackBar('❌ Error al registrar la venta', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('❌ Error: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Venta'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _hasCustomer ? Icons.check_circle : Icons.person_add,
              color: _hasCustomer ? Colors.green : Colors.white,
            ),
            onPressed: _showCustomerDialog,
            tooltip: _hasCustomer ? 'Editar cliente' : 'Agregar cliente',
          ),
        ],
      ),
      body: widget.cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Carrito vacío', style: TextStyle(fontSize: 20, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Agrega productos desde Punto de Venta', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                if (_hasCustomer && _customerController.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cliente: ${_customerController.text}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (_idController.text.isNotEmpty)
                                Text('🆔 ${_idController.text}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: _showCustomerDialog,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cart.length,
                    itemBuilder: (ctx, index) {
                      final item = widget.cart[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A5F).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.inventory_2, color: Color(0xFF1E3A5F)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.nombre,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${item.product.precioVenta.toStringAsFixed(2)} c/u',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: () => _updateQuantity(index, item.quantity - 1),
                                        iconSize: 24,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      SizedBox(
                                        width: 40,
                                        child: Text(
                                          '${item.quantity}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () => _updateQuantity(index, item.quantity + 1),
                                        iconSize: 24,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '\$${(item.product.precioVenta * item.quantity).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E3A5F),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                          Text('\$${_subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      if (widget.discount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Descuento:', style: TextStyle(fontSize: 16, color: Colors.red)),
                            Text('-\$${widget.discount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.red)),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Text(
                            '\$${_total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A5F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _completeSale,
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                )
                              : const Icon(Icons.payment, size: 24),
                          label: Text(
                            _isProcessing ? 'Procesando...' : 'COMPLETAR VENTA',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A5F),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
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
}
