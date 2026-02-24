import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../providers/project_provider.dart';
import '../../config/theme.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _keyController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _keyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onNameChanged(String value) {
    if (_keyController.text.isEmpty || _keyController.text == _generateKey(_nameController.text.substring(0, _nameController.text.length > 1 ? _nameController.text.length - 1 : 0))) {
      _keyController.text = _generateKey(value);
    }
  }

  String _generateKey(String name) {
    return name
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]'), '')
        .substring(0, name.length > 5 ? 5 : name.length);
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = ref.read(projectServiceProvider);
      final project = await service.createProject(
        name: _nameController.text.trim(),
        key: _keyController.text.trim().toUpperCase(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      ref.invalidate(projectsProvider);

      if (mounted) {
        final boardId = project.boards?.isNotEmpty == true ? project.boards!.first.id : '';
        if (boardId.isNotEmpty) {
          context.go('/projects/${project.id}/board/$boardId');
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      String message = 'Failed to create project.';
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
                        onPressed: () => context.go('/'),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Create New Project',
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
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Project Name',
                      hintText: 'e.g., My Awesome Project',
                    ),
                    onChanged: _onNameChanged,
                    validator: (v) => v == null || v.isEmpty ? 'Project name is required' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _keyController,
                    decoration: const InputDecoration(
                      labelText: 'Project Key',
                      hintText: 'e.g., MAP',
                      helperText: 'Uppercase letters/numbers. Used in task IDs (e.g., MAP-1)',
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Project key is required';
                      if (v.length < 2) return 'Key must be at least 2 characters';
                      if (!RegExp(r'^[A-Z][A-Z0-9]*$').hasMatch(v.toUpperCase())) {
                        return 'Key must be uppercase letters/numbers starting with a letter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      hintText: 'Brief project description',
                    ),
                    maxLines: 3,
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
                        : const Text('Create Project'),
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
