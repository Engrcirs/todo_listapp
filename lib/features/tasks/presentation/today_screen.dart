import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_listapp/features/tasks/domain/task.dart';
import 'package:todo_listapp/features/tasks/presentation/add_task_sheet.dart';
import 'package:todo_listapp/features/tasks/presentation/task_providers.dart';
import 'package:todo_listapp/features/tasks/presentation/widgets/task_tile.dart';

const _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(tasksProvider);
    final visible = ref.watch(visibleTasksProvider);
    final filter = ref.watch(filterProvider);

    final todo = visible.where((t) => !t.isDone).toList();
    final done = visible.where((t) => t.isDone).toList();
    final doneCount = all.where((t) => t.isDone).length;
    final now = DateTime.now();
    final dateText = '${_days[now.weekday - 1]}, ${_months[now.month - 1]} ${now.day}';

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add task',
        onPressed: () => showAddTaskSheet(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            Text(dateText, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5A54))),
            const Text('Today', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            _ProgressCard(done: doneCount, total: all.length),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(label: 'All', selected: filter == null, onTap: () => ref.read(filterProvider.notifier).select(null)),
                  for (final l in TaskList.values)
                    _FilterChip(label: l.label, selected: filter == l, onTap: () => ref.read(filterProvider.notifier).select(l)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (visible.isEmpty)
              const _EmptyState()
            else ...[
              if (todo.isNotEmpty) ...[
                _SectionLabel('TO DO · ${todo.length}'),
                for (final t in todo) TaskTile(task: t),
              ],
              if (done.isNotEmpty) ...[
                _SectionLabel('DONE · ${done.length}'),
                for (final t in done) TaskTile(task: t),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily progress', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
              Text('$done of $total done', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 8,
              backgroundColor: Colors.white30,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(color: selected ? Colors.white : null),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF4B5A54))),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, size: 56, color: Color(0xFF0F766E)),
          SizedBox(height: 16),
          Text('All clear for today', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Text('You have no tasks. Tap + to add one.', style: TextStyle(color: Color(0xFF4B5A54))),
        ],
      ),
    );
  }
}