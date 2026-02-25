class AppSettings {
  String currency;
  double exchangeRate;
  String companyName;
  String rnc;
  String address;
  String phone;

  AppSettings({
    this.currency = 'CUP',
    this.exchangeRate = 1.0,
    this.companyName = '',
    this.rnc = '',
    this.address = '',
    this.phone = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'exchangeRate': exchangeRate,
      'companyName': companyName,
      'rnc': rnc,
      'address': address,
      'phone': phone,
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
    );
  }
}
