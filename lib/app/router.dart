import 'package:go_router/go_router.dart';
import 'package:todo_listapp/app/app_shell.dart';
import 'package:todo_listapp/features/lists/lists_screen.dart';
import 'package:todo_listapp/features/progress/progress_screen.dart';
import 'package:todo_listapp/features/tasks/presentation/edit_task_screen.dart';
import 'package:todo_listapp/features/tasks/presentation/task_detail_screen.dart';
import 'package:todo_listapp/features/tasks/presentation/today_screen.dart';

final router = GoRouter(
  initialLocation: '/today',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/today', builder: (context, state) => const TodayScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/lists', builder: (context, state) => const ListsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/progress', builder: (context, state) => const ProgressScreen()),
        ]),
      ],
    ),
    GoRoute(
      path: '/task/:id',
      builder: (context, state) =>
          TaskDetailScreen(taskId: int.parse(state.pathParameters['id']!)),
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) =>
              EditTaskScreen(taskId: int.parse(state.pathParameters['id']!)),
        ),
      ],
    ),
  ],
);