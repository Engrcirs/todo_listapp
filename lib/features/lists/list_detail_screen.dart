import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_listapp/features/tasks/domain/task.dart';
import 'package:todo_listapp/features/tasks/presentation/task_providers.dart';
import 'package:todo_listapp/features/tasks/presentation/widgets/task_tile.dart';

class ListDetailScreen extends ConsumerWidget {
  const ListDetailScreen({super.key, required this.list});

  final TaskList list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider).where((t) => t.list == list).toList();
    final todo = tasks.where((t) => !t.isDone).toList();
    final done = tasks.where((t) => t.isDone).toList();

    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4B5A54))),
        );

    Widget tile(Task t) => GestureDetector(
          onTap: () => context.push('/task/${t.id}'),
          child: TaskTile(task: t),
        );

    return Scaffold(
      appBar: AppBar(title: Text(list.label), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: tasks.isEmpty
            ? const Center(child: Text('No tasks in this list yet.', style: TextStyle(color: Color(0xFF4B5A54))))
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  if (todo.isNotEmpty) ...[label('TO DO · ${todo.length}'), ...todo.map(tile)],
                  if (done.isNotEmpty) ...[label('DONE · ${done.length}'), ...done.map(tile)],
                ],
              ),
      ),
    );
  }
}