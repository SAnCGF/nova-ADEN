class AppSettings {
  String currency; // 'CUP' o 'MLC'
  double exchangeRate; // Tasa de cambio MLC a CUP
  bool autoBackup;
  String autoBackupFrequency; // 'daily', 'weekly', 'monthly'
  String lastBackupDate;
  String backupPath;
  bool showCostInReports;
  bool allowNegativeStock;
  int lowStockThreshold;

  AppSettings({
    this.currency = 'CUP',
    this.exchangeRate = 1.0,
    this.autoBackup = false,
    this.autoBackupFrequency = 'weekly',
    this.lastBackupDate = '',
    this.backupPath = '',
    this.showCostInReports = true,
    this.allowNegativeStock = false,
    this.lowStockThreshold = 5,
  });

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'exchange_rate': exchangeRate,
      'auto_backup': autoBackup ? 1 : 0,
      'auto_backup_frequency': autoBackupFrequency,
      'last_backup_date': lastBackupDate,
      'backup_path': backupPath,
      'show_cost_in_reports': showCostInReports ? 1 : 0,
      'allow_negative_stock': allowNegativeStock ? 1 : 0,
      'low_stock_threshold': lowStockThreshold,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      currency: map['currency'] ?? 'CUP',
      exchangeRate: map['exchange_rate'] ?? 1.0,
      autoBackup: map['auto_backup'] == 1,
      autoBackupFrequency: map['auto_backup_frequency'] ?? 'weekly',
      lastBackupDate: map['last_backup_date'] ?? '',
      backupPath: map['backup_path'] ?? '',
      showCostInReports: map['show_cost_in_reports'] == 1,
      allowNegativeStock: map['allow_negative_stock'] == 1,
      lowStockThreshold: map['low_stock_threshold'] ?? 5,
    );
  }

  String get currencySymbol => currency == 'CUP' ? '\$' : 'MLC';
}
