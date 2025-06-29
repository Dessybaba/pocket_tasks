enum TaskFilter { all, active, completed }
enum TaskSort { dueDate, creationDate }

class Task {
  final String id;
  final String title;
  final String note;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.note = '',
    this.dueDate,
    this.createdAt,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? note,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      note: map['note'] ?? '',
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      isCompleted: map['isCompleted'] == 1,
    );
  }
}