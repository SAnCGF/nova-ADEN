class DailyNote {
  final int? id;
  final String content;
  final DateTime createdAt;
  final String? category;
  final bool isImportant;

  DailyNote({
    this.id,
    required this.content,
    DateTime? createdAt,
    this.category,
    this.isImportant = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'category': category,
      'is_important': isImportant ? 1 : 0,
    };
  }

  factory DailyNote.fromMap(Map<String, dynamic> map) {
    return DailyNote(
      id: map['id'],
      content: map['content'] ?? '',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      category: map['category'],
      isImportant: (map['is_important'] ?? 0) == 1,
    );
  }
}
