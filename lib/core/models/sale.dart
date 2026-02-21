class Sale {
  final int? id;
  final String saleNumber;
  final DateTime date;
  final double subtotal;
  final double discount;
  final double total;
  final double paid;
  final double change;
  final bool isPartialPayment;
  final String? customerName;
  final String? customerPhone;
  final String status; // 'completed', 'pending', 'cancelled'
  final DateTime createdAt;

  Sale({
    this.id,
    required this.saleNumber,
    required this.date,
    required this.subtotal,
    this.discount = 0,
    required this.total,
    required this.paid,
    required this.change,
    this.isPartialPayment = false,
    this.customerName,
    this.customerPhone,
    this.status = 'completed',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_number': saleNumber,
      'date': date.toIso8601String(),
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'paid': paid,
      'change': change,
      'is_partial_payment': isPartialPayment ? 1 : 0,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      saleNumber: map['sale_number'],
      date: DateTime.parse(map['date']),
      subtotal: map['subtotal'],
      discount: map['discount'],
      total: map['total'],
      paid: map['paid'],
      change: map['change'],
      isPartialPayment: map['is_partial_payment'] == 1,
      customerName: map['customer_name'],
      customerPhone: map['customer_phone'],
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Sale copyWith({
    int? id,
    String? saleNumber,
    DateTime? date,
    double? subtotal,
    double? discount,
    double? total,
    double? paid,
    double? change,
    bool? isPartialPayment,
    String? customerName,
    String? customerPhone,
    String? status,
  }) {
    return Sale(
      id: id ?? this.id,
      saleNumber: saleNumber ?? this.saleNumber,
      date: date ?? this.date,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paid: paid ?? this.paid,
      change: change ?? this.change,
      isPartialPayment: isPartialPayment ?? this.isPartialPayment,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
