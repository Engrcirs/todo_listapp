import 'package:go_router/go_router.dart';
import 'package:todo_listapp/features/tasks/presentation/today_screen.dart';

final router = GoRouter(
  initialLocation: '/today',
  routes: [
    GoRoute(path: '/today', builder: (context, state) => const TodayScreen()),
  ],
);