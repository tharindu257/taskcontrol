import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/projects/projects_screen.dart';
import '../screens/projects/create_project_screen.dart';
import '../screens/board/board_screen.dart';
import '../screens/tasks/task_detail_screen.dart';
import '../screens/tasks/create_task_screen.dart';
import '../screens/profile/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute =
          state.matchedLocation == '/login' || state.matchedLocation == '/register';

      // While checking auth, stay on current route
      if (isLoading) return null;

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const ProjectsScreen(),
          ),
          GoRoute(
            path: '/projects/create',
            builder: (context, state) => const CreateProjectScreen(),
          ),
          GoRoute(
            path: '/projects/:projectId/board/:boardId',
            builder: (context, state) => BoardScreen(
              projectId: state.pathParameters['projectId']!,
              boardId: state.pathParameters['boardId']!,
            ),
          ),
          GoRoute(
            path: '/tasks/:taskId',
            builder: (context, state) => TaskDetailScreen(
              taskId: state.pathParameters['taskId']!,
            ),
          ),
          GoRoute(
            path: '/projects/:projectId/tasks/create',
            builder: (context, state) => CreateTaskScreen(
              projectId: state.pathParameters['projectId']!,
              boardId: state.uri.queryParameters['boardId'],
            ),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
