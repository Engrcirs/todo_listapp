import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_listapp/features/tasks/data/task_repository.dart';
import 'package:todo_listapp/features/tasks/presentation/task_providers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<ProviderContainer> makeContainer() async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('add, toggle and remove a subtask', () async {
    final container = await makeContainer();
    final notifier = container.read(tasksProvider.notifier);

    notifier.addSubtask(1, 'Outline goals');
    notifier.addSubtask(1, 'Collect references');
    var subtasks = container.read(taskProvider(1))!.subtasks;
    expect(subtasks.length, 2);
    expect(subtasks.map((s) => s.id).toSet().length, 2);

    notifier.toggleSubtask(1, subtasks.first.id);
    subtasks = container.read(taskProvider(1))!.subtasks;
    expect(subtasks.first.isDone, isTrue);
    expect(subtasks.last.isDone, isFalse);

    notifier.removeSubtask(1, subtasks.first.id);
    expect(container.read(taskProvider(1))!.subtasks.length, 1);
  });

  test('subtasks are saved and loaded', () async {
    final container = await makeContainer();
    container.read(tasksProvider.notifier).addSubtask(2, 'Draft reply');

    final prefs = await SharedPreferences.getInstance();
    final loaded = TaskRepository(prefs).load()!;
    final task = loaded.firstWhere((t) => t.id == 2);
    expect(task.subtasks.single.title, 'Draft reply');
  });
}