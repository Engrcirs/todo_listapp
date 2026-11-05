import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_listapp/features/tasks/domain/task.dart';
import 'package:todo_listapp/features/tasks/presentation/task_providers.dart';
import 'package:todo_listapp/features/tasks/presentation/widgets/task_tile.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    final done = tasks.where((t) => t.isDone).length;
    final remaining = tasks.length - done;
    final percent = tasks.isEmpty ? 0 : (done * 100 / tasks.length).round();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const Text('Progress', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$percent%', style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w700)),
                  const Text('of your tasks are done', style: TextStyle(color: Colors.white, fontSize: 15)),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: tasks.isEmpty ? 0 : done / tasks.length,
                      minHeight: 8,
                      backgroundColor: Colors.white30,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _Stat(label: 'Done', value: done)),
                const SizedBox(width: 12),
                Expanded(child: _Stat(label: 'Remaining', value: remaining)),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'REMAINING BY PRIORITY',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4B5A54)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE1E7E2)),
              ),
              child: Column(
                children: [
                  for (final p in Priority.values.reversed)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: priorityColor(p), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(p.label, style: const TextStyle(fontSize: 15))),
                          Text(
                            '${tasks.where((t) => !t.isDone && t.priority == p).length}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'The 7-day chart and streak will appear once tasks are saved in the database.',
              style: TextStyle(fontSize: 13, color: Color(0xFF4B5A54)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E7E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5A54))),
        ],
      ),
    );
  }
}