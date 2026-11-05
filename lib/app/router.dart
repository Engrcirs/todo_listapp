import 'package:go_router/go_router.dart';
import 'package:todo_listapp/features/tasks/presentation/edit_task_screen.dart';
import 'package:todo_listapp/features/tasks/presentation/task_detail_screen.dart';
import 'package:todo_listapp/features/tasks/presentation/today_screen.dart';

final router = GoRouter(
  initialLocation: '/today',
  routes: [
    GoRoute(path: '/today', builder: (context, state) => const TodayScreen()),
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