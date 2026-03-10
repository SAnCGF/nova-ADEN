class Currency {
  final String code;
  final String name;
  final String symbol;
  final double exchangeRate; // Respecto a moneda base
  final bool isDefault;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    this.exchangeRate = 1.0,
    this.isDefault = false,
  });

  static const Currency CUP = Currency(
    code: 'CUP',
    name: 'Peso Cubano',
    symbol: '\$',
    isDefault: true,
  );

  static const Currency USD = Currency(
    code: 'USD',
    name: 'Dólar Estadounidense',
    symbol: '\$',
    exchangeRate: 1.0,
  );

  static const Currency EUR = Currency(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    exchangeRate: 0.92,
  );

  static const List<Currency> available = [CUP, USD, EUR];

  double convert(double amount, Currency toCurrency) {
    if (code == toCurrency.code) return amount;
    return amount * (toCurrency.exchangeRate / exchangeRate);
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'exchange_rate': exchangeRate,
      'is_default': isDefault ? 1 : 0,
    };
  }

  factory Currency.fromMap(Map<String, dynamic> map) {
    return Currency(
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      symbol: map['symbol'] ?? '',
      exchangeRate: (map['exchange_rate'] ?? 1).toDouble(),
      isDefault: (map['is_default'] ?? 0) == 1,
    );
  }
}
