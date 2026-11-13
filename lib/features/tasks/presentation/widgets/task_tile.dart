import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_listapp/features/tasks/domain/task.dart';
import 'package:todo_listapp/features/tasks/presentation/task_providers.dart';
import 'package:todo_listapp/app/format.dart';
Color priorityColor(Priority p) => switch (p) {
      Priority.low => const Color(0xFF5B6A64),
      Priority.medium => const Color(0xFFB45309),
      Priority.high => const Color(0xFFB42318),
    };

class TaskTile extends ConsumerWidget {
  const TaskTile({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(tasksProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
      final dueText = task.dueAt == null ? 'No due date' : formatDue(context, task.dueAt);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        notifier.remove(task.id);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text('Task deleted'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => notifier.restore(task),
              ),
            ),
          );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFB42318),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1E7E2)),
        ),
        child: Row(
          children: [
            Checkbox(
              value: task.isDone,
              shape: const CircleBorder(),
              onChanged: (_) => notifier.toggle(task.id),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                      color: task.isDone ? const Color(0xFF4B5A54) : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(dueText, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5A54))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F1EE),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(task.list.label, style: const TextStyle(fontSize: 12, color: Color(0xFF0B5A53))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Semantics(
              label: '${task.priority.label} priority',
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: priorityColor(task.priority), shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}