class CreditSale {
  final int? id;
  final int saleId;
  final String customerName;
  final String customerIdentity;
  final String customerPhone;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final DateTime saleDate;
  final DateTime dueDate;
  final String status; // 'pending', 'partial', 'paid'
  final String? notes;

  CreditSale({
    this.id,
    required this.saleId,
    required this.customerName,
    required this.customerIdentity,
    required this.customerPhone,
    required this.totalAmount,
    this.paidAmount = 0.0,
    DateTime? saleDate,
    required this.dueDate,
    this.status = 'pending',
    this.notes,
  }) : saleDate = saleDate ?? DateTime.now(),
       pendingAmount = totalAmount - paidAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'customer_name': customerName,
      'customer_identity': customerIdentity,
      'customer_phone': customerPhone,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'pending_amount': pendingAmount,
      'sale_date': saleDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  factory CreditSale.fromMap(Map<String, dynamic> map) {
    return CreditSale(
      id: map['id'],
      saleId: map['sale_id'],
      customerName: map['customer_name'] ?? '',
      customerIdentity: map['customer_identity'] ?? '',
      customerPhone: map['customer_phone'] ?? '',
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      paidAmount: (map['paid_amount'] ?? 0).toDouble(),
      saleDate: map['sale_date'] != null ? DateTime.parse(map['sale_date']) : null,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : DateTime.now(),
      status: map['status'] ?? 'pending',
      notes: map['notes'],
    );
  }

  CreditSale copyWith({
    double? paidAmount,
    String? status,
  }) {
    final newPaid = paidAmount ?? this.paidAmount;
    return CreditSale(
      id: id,
      saleId: saleId,
      customerName: customerName,
      customerIdentity: customerIdentity,
      customerPhone: customerPhone,
      totalAmount: totalAmount,
      paidAmount: newPaid,
      saleDate: saleDate,
      dueDate: dueDate,
      status: status ?? (newPaid >= totalAmount ? 'paid' : newPaid > 0 ? 'partial' : 'pending'),
      notes: notes,
    );
  }
}
