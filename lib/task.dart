import 'dart:convert';

class Task {
  final String id;
  String title;
  String? notes;
  DateTime? due;
  bool done;
  int priority; // 0=low,1=med,2=high
  String? category;

  Task({
    required this.id,
    required this.title,
    this.notes,
    this.due,
    this.done = false,
    this.priority = 0,
    this.category,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        notes: json['notes'] as String?,
        due: json['due'] != null ? DateTime.parse(json['due'] as String) : null,
        done: json['done'] as bool? ?? false,
        priority: json['priority'] as int? ?? 0,
        category: json['category'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'due': due?.toIso8601String(),
        'done': done,
        'priority': priority,
        'category': category,
      };

  static String encodeList(List<Task> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<Task> decodeList(String source) {
    final data = jsonDecode(source) as List<dynamic>;
    return data.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }
}
