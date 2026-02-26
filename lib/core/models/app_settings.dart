class AppSettings {
  String currency;
  double exchangeRate;
  String companyName;
  String rnc;
  String address;
  String phone;
  bool showCostInReports;
  bool allowNegativeStock;
  int lowStockThreshold;

  AppSettings({
    this.currency = 'CUP',
    this.exchangeRate = 1.0,
    this.companyName = '',
    this.rnc = '',
    this.address = '',
    this.phone = '',
    this.showCostInReports = true,
    this.allowNegativeStock = false,
    this.lowStockThreshold = 5,
  });

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'exchangeRate': exchangeRate,
      'companyName': companyName,
      'rnc': rnc,
      'address': address,
      'phone': phone,
      'showCostInReports': showCostInReports,
      'allowNegativeStock': allowNegativeStock,
      'lowStockThreshold': lowStockThreshold,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      currency: map['currency'] ?? 'CUP',
      exchangeRate: (map['exchangeRate'] ?? 1.0).toDouble(),
      companyName: map['companyName'] ?? '',
      rnc: map['rnc'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      showCostInReports: map['showCostInReports'] ?? true,
      allowNegativeStock: map['allowNegativeStock'] ?? false,
      lowStockThreshold: map['lowStockThreshold'] ?? 5,
    );
  }
}
