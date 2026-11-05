import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_listapp/app/format.dart';
import 'package:todo_listapp/features/tasks/domain/task.dart';
import 'package:todo_listapp/features/tasks/presentation/task_providers.dart';

const _red = Color(0xFFB42318);

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final int taskId;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Task task) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this task?'),
        content: Text('"${task.title}" will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep task'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _red,
              minimumSize: const Size(100, 44),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final notifier = ref.read(tasksProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    notifier.remove(task.id);
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        action: SnackBarAction(label: 'Undo', onPressed: () => notifier.restore(task)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskProvider(taskId));
    if (task == null) return const Scaffold();
    final notifier = ref.read(tasksProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More options',
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  context.push('/task/${task.id}/edit');
                case 'toggle':
                  notifier.toggle(task.id);
                case 'delete':
                  _confirmDelete(context, ref, task);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit task')),
              PopupMenuItem(
                value: 'toggle',
                child: Text(task.isDone ? 'Mark not done' : 'Mark complete'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete task', style: TextStyle(color: _red)),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F1EE),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(task.list.label, style: const TextStyle(fontSize: 12, color: Color(0xFF0B5A53))),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        decoration: task.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(icon: Icons.calendar_today_outlined, label: 'Due', value: formatDue(context, task.dueAt)),
                    _InfoRow(icon: Icons.flag_outlined, label: 'Priority', value: task.priority.label),
                    _InfoRow(icon: Icons.list_alt_outlined, label: 'List', value: task.list.label),
                    const SizedBox(height: 20),
                    const Text('NOTES', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4B5A54))),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE1E7E2)),
                      ),
                      child: Text(
                        task.notes.isEmpty ? 'No notes yet.' : task.notes,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: () => notifier.toggle(task.id),
                    child: Text(task.isDone ? 'Mark not done' : 'Mark complete'),
                  ),
                  TextButton(
                    onPressed: () => _confirmDelete(context, ref, task),
                    child: const Text('Delete task', style: TextStyle(color: _red)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE1E7E2))),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4B5A54)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF4B5A54)))),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}