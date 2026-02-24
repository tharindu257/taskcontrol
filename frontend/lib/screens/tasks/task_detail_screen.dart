import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../services/api_service.dart';
import '../../config/theme.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/loading_widget.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _commentController = TextEditingController();
  final _taskService = TaskService();
  final _api = ApiService();
  bool _isPostingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String taskId, String status) async {
    try {
      await _taskService.updateTaskStatus(taskId, status);
      ref.invalidate(taskDetailProvider(widget.taskId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  Future<void> _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isPostingComment = true);
    try {
      await _api.post('/comments/task/${widget.taskId}', data: {'content': content});
      _commentController.clear();
      ref.invalidate(taskDetailProvider(widget.taskId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPostingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));

    return Scaffold(
      body: taskAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (task) => _buildContent(context, task),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Task task) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.key,
                  style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              StatusChip(status: task.status, onChanged: (s) => _updateStatus(task.id, s)),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            task.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Metadata row
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _metadataItem('Type', Chip(label: Text(task.type, style: const TextStyle(fontSize: 12)))),
              _metadataItem('Priority', PriorityBadge(priority: task.priority)),
              _metadataItem(
                'Assignee',
                task.assignee != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UserAvatar(name: task.assignee!.displayName, size: 24),
                          const SizedBox(width: 8),
                          Text(task.assignee!.displayName),
                        ],
                      )
                    : Text('Unassigned', style: TextStyle(color: Colors.grey[500])),
              ),
              if (task.dueDate != null)
                _metadataItem(
                  'Due Date',
                  Text(DateFormat('MMM d, yyyy').format(task.dueDate!)),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Description
          if (task.description != null && task.description!.isNotEmpty) ...[
            Text('Description', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(task.description!),
            ),
            const SizedBox(height: 24),
          ],

          // Labels
          if (task.labels != null && task.labels!.isNotEmpty) ...[
            Text('Labels', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: task.labels!.map((tl) {
                final label = tl.label;
                if (label == null) return const SizedBox();
                return Chip(
                  label: Text(label.name, style: const TextStyle(fontSize: 12, color: Colors.white)),
                  backgroundColor: _hexToColor(label.color),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Comments
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Comments (${task.comments?.length ?? 0})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          // Add comment
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isPostingComment ? null : _postComment,
                icon: _isPostingComment
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                color: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Comment list
          if (task.comments != null)
            ...task.comments!.map((comment) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            UserAvatar(name: comment.author?.displayName ?? 'User', size: 28),
                            const SizedBox(width: 8),
                            Text(
                              comment.author?.displayName ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              comment.createdAt != null
                                  ? DateFormat('MMM d, HH:mm').format(comment.createdAt!)
                                  : '',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                            if (comment.edited) ...[
                              const SizedBox(width: 4),
                              Text('(edited)', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(comment.content),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _metadataItem(String label, Widget value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        value,
      ],
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
