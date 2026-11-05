import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_listapp/features/tasks/data/task_repository.dart';
import 'package:todo_listapp/features/tasks/domain/task.dart';

/// Filled in main.dart with the real SharedPreferences instance.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepository(ref.watch(sharedPrefsProvider)),
);

DateTime _today(int hour, int minute) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day, hour, minute);
}

List<Task> _sampleTasks() => [
      Task(id: 1, title: 'Review lecture notes', priority: Priority.medium, list: TaskList.school, dueAt: _today(9, 0)),
      Task(id: 2, title: 'Reply to client emails', priority: Priority.low, list: TaskList.work, dueAt: _today(11, 30)),
      Task(id: 3, title: 'Buy groceries', priority: Priority.low, list: TaskList.personal, dueAt: _today(17, 0)),
      Task(id: 4, title: 'Draft project proposal', notes: 'Keep it to two pages. Include timeline and budget summary.', priority: Priority.high, list: TaskList.work, dueAt: _today(20, 0)),
      Task(id: 5, title: 'Morning workout', priority: Priority.low, list: TaskList.personal, dueAt: _today(7, 0), isDone: true),
    ];

class TaskNotifier extends Notifier<List<Task>> {
  int _nextId = 1;

  @override
  List<Task> build() {
    final tasks = ref.read(taskRepositoryProvider).load() ?? _sampleTasks();
    _nextId = tasks.fold(0, (m, t) => t.id > m ? t.id : m) + 1;
    return tasks;
  }

  void _set(List<Task> tasks) {
    state = tasks;
    ref.read(taskRepositoryProvider).save(tasks);
  }

  void add(String title, Priority priority, TaskList list) {
    _set([...state, Task(id: _nextId++, title: title, priority: priority, list: list)]);
  }

  void toggle(int id) {
    _set([
      for (final t in state)
        if (t.id == id)
          t.isDone
              ? t.copyWith(isDone: false, clearCompletedAt: true)
              : t.copyWith(isDone: true, completedAt: DateTime.now())
        else
          t,
    ]);
  }

  void update(Task updated) {
    _set([
      for (final t in state)
        if (t.id == updated.id) updated else t,
    ]);
  }

  void remove(int id) {
    _set(state.where((t) => t.id != id).toList());
  }

  void restore(Task task) {
    if (state.any((t) => t.id == task.id)) return;
    _set([...state, task]);
  }
}

final tasksProvider = NotifierProvider<TaskNotifier, List<Task>>(TaskNotifier.new);

final taskProvider = Provider.family<Task?, int>((ref, id) {
  for (final t in ref.watch(tasksProvider)) {
    if (t.id == id) return t;
  }
  return null;
});

class FilterNotifier extends Notifier<TaskList?> {
  @override
  TaskList? build() => null;

  void select(TaskList? list) => state = list;
}

final filterProvider = NotifierProvider<FilterNotifier, TaskList?>(FilterNotifier.new);

final visibleTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(tasksProvider);
  final filter = ref.watch(filterProvider);
  return filter == null ? tasks : tasks.where((t) => t.list == filter).toList();
});