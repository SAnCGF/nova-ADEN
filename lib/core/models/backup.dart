class Backup {
  final String id;
  final String fileName;
  final DateTime date;
  final int productsCount;
  final int salesCount;
  final int purchasesCount;
  final double fileSize;
  final String path;
  final String type; // 'manual' o 'automatic'

  Backup({
    required this.id,
    required this.fileName,
    required this.date,
    required this.productsCount,
    required this.salesCount,
    required this.purchasesCount,
    required this.fileSize,
    required this.path,
    this.type = 'manual',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_name': fileName,
      'date': date.toIso8601String(),
      'products_count': productsCount,
      'sales_count': salesCount,
      'purchases_count': purchasesCount,
      'file_size': fileSize,
      'path': path,
      'type': type,
    };
  }

  factory Backup.fromMap(Map<String, dynamic> map) {
    return Backup(
      id: map['id'],
      fileName: map['file_name'],
      date: DateTime.parse(map['date']),
      productsCount: map['products_count'],
      salesCount: map['sales_count'],
      purchasesCount: map['purchases_count'],
      fileSize: map['file_size'],
      path: map['path'],
      type: map['type'] ?? 'manual',
    );
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) return '${fileSize.toStringAsFixed(0)} B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
