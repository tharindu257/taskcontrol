import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../services/task_service.dart';
import '../../providers/board_provider.dart';
import '../../config/theme.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String? boardId;

  const CreateTaskScreen({super.key, required this.projectId, this.boardId});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _taskService = TaskService();
  String _type = 'TASK';
  String _priority = 'MEDIUM';
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.boardId == null) {
      setState(() => _error = 'No board ID provided');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _taskService.createTask(
        widget.projectId,
        title: _titleController.text.trim(),
        boardId: widget.boardId!,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        type: _type,
        priority: _priority,
      );

      if (widget.boardId != null) {
        ref.invalidate(boardTasksProvider(widget.boardId!));
      }

      if (mounted) {
        context.go('/projects/${widget.projectId}/board/${widget.boardId}');
      }
    } catch (e) {
      String message = 'Failed to create task.';
      if (e is DioException && e.response?.data != null) {
        message = e.response?.data['message'] ?? message;
      }
      setState(() => _error = message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (widget.boardId != null) {
                            context.go('/projects/${widget.projectId}/board/${widget.boardId}');
                          } else {
                            context.go('/');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Create Task',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_error!, style: TextStyle(color: AppTheme.errorColor)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      hintText: 'What needs to be done?',
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      hintText: 'Add more details...',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    minLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Type dropdown
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: const [
                      DropdownMenuItem(value: 'TASK', child: Text('Task')),
                      DropdownMenuItem(value: 'BUG', child: Text('Bug')),
                      DropdownMenuItem(value: 'FEATURE', child: Text('Feature')),
                      DropdownMenuItem(value: 'STORY', child: Text('Story')),
                    ],
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                  const SizedBox(height: 16),

                  // Priority dropdown
                  DropdownButtonFormField<String>(
                    value: _priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'].map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppTheme.getPriorityColor(p),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(AppTheme.getPriorityLabel(p)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _priority = v!),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleCreate,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Create Task'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
