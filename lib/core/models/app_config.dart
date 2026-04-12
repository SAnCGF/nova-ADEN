class AppConfig {
  final int? id;
  final String key;
  final dynamic value;
  final DateTime updatedAt;

  AppConfig({this.id, required this.key, required this.value, required this.updatedAt});

  Map<String, dynamic> toMap() => {'id': id, 'key': key, 'value': value, 'updated_at': updatedAt.toIso8601String()};
  factory AppConfig.fromMap(Map<String, dynamic> m) => AppConfig(id: m['id'], key: m['key'], value: m['value'], updatedAt: DateTime.parse(m['updated_at']));
}
