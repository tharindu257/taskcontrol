import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/board_provider.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../config/theme.dart';
import '../../widgets/task_card.dart';
import '../../widgets/board_column.dart';
import '../../widgets/loading_widget.dart';

class BoardScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String boardId;

  const BoardScreen({
    super.key,
    required this.projectId,
    required this.boardId,
  });

  @override
  ConsumerState<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends ConsumerState<BoardScreen> {
  final _taskService = TaskService();
  final _statuses = ['TO_DO', 'IN_PROGRESS', 'IN_REVIEW', 'DONE'];

  Future<void> _onTaskDropped(Task task, String newStatus, int position) async {
    try {
      await _taskService.moveTask(
        task.id,
        status: newStatus != task.status ? newStatus : null,
        position: position,
      );
      ref.invalidate(boardTasksProvider(widget.boardId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to move task: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final boardAsync = ref.watch(boardTasksProvider(widget.boardId));

    return Scaffold(
      body: boardAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('Failed to load board', style: TextStyle(color: Colors.grey[600])),
              TextButton(
                onPressed: () => ref.invalidate(boardTasksProvider(widget.boardId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (boardData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Board header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go('/'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        boardData.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => ref.invalidate(boardTasksProvider(widget.boardId)),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.go(
                        '/projects/${widget.projectId}/tasks/create?boardId=${widget.boardId}',
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Task'),
                    ),
                  ],
                ),
              ),

              // Board columns
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _statuses.length,
                  itemBuilder: (context, index) {
                    final status = _statuses[index];
                    final tasks = boardData.getTasksByStatus(status);

                    return BoardColumn(
                      status: status,
                      tasks: tasks,
                      onTaskTap: (task) => context.go('/tasks/${task.id}'),
                      onTaskDropped: (task, position) => _onTaskDropped(task, status, position),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
