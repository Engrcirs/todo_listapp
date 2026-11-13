enum Priority { low, medium, high }

enum TaskList { work, personal, school }

extension PriorityLabel on Priority {
  String get label => switch (this) {
        Priority.low => 'Low',
        Priority.medium => 'Medium',
        Priority.high => 'High',
      };
}

extension TaskListLabel on TaskList {
  String get label => switch (this) {
        TaskList.work => 'Work',
        TaskList.personal => 'Personal',
        TaskList.school => 'School',
      };
}

class Subtask {
  const Subtask({required this.id, required this.title, this.isDone = false});

  final int id;
  final String title;
  final bool isDone;

  Subtask copyWith({bool? isDone}) =>
      Subtask(id: id, title: title, isDone: isDone ?? this.isDone);

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'isDone': isDone};

  factory Subtask.fromJson(Map<String, dynamic> j) => Subtask(
        id: j['id'] as int,
        title: j['title'] as String,
        isDone: j['isDone'] as bool,
      );
}

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.list,
    this.notes = '',
    this.dueAt,
    this.isDone = false,
    this.completedAt,
    this.subtasks = const [],
  });

  final int id;
  final String title;
  final String notes;
  final Priority priority;
  final TaskList list;
  final DateTime? dueAt;
  final bool isDone;
  final DateTime? completedAt;
  final List<Subtask> subtasks;

  Task copyWith({
    String? title,
    String? notes,
    Priority? priority,
    TaskList? list,
    DateTime? dueAt,
    bool? isDone,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    List<Subtask>? subtasks,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        notes: notes ?? this.notes,
        priority: priority ?? this.priority,
        list: list ?? this.list,
        dueAt: dueAt ?? this.dueAt,
        isDone: isDone ?? this.isDone,
        completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
        subtasks: subtasks ?? this.subtasks,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'priority': priority.name,
        'list': list.name,
        'dueAt': dueAt?.toIso8601String(),
        'isDone': isDone,
        'completedAt': completedAt?.toIso8601String(),
        'subtasks': [for (final s in subtasks) s.toJson()],
      };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'] as int,
        title: j['title'] as String,
        notes: (j['notes'] as String?) ?? '',
        priority: Priority.values.byName(j['priority'] as String),
        list: TaskList.values.byName(j['list'] as String),
        dueAt: j['dueAt'] == null ? null : DateTime.parse(j['dueAt'] as String),
        isDone: j['isDone'] as bool,
        completedAt: j['completedAt'] == null ? null : DateTime.parse(j['completedAt'] as String),
        subtasks: [
          for (final s in (j['subtasks'] as List<dynamic>? ?? const []))
            Subtask.fromJson(s as Map<String, dynamic>),
        ],
      );
}