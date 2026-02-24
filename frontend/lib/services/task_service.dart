import '../models/task.dart';
import 'api_service.dart';

class TaskService {
  final _api = ApiService();

  Future<List<Task>> getTasks(String projectId, {
    String? status,
    String? priority,
    String? assigneeId,
    String? search,
  }) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    if (priority != null) params['priority'] = priority;
    if (assigneeId != null) params['assigneeId'] = assigneeId;
    if (search != null) params['search'] = search;

    final response = await _api.get('/projects/$projectId/tasks', queryParams: params);
    final list = response['data'] as List;
    return list.map((json) => Task.fromJson(json)).toList();
  }

  Future<Task> getTask(String taskId) async {
    final response = await _api.get('/tasks/$taskId');
    return Task.fromJson(response['data']);
  }

  Future<Task> createTask(String projectId, {
    required String title,
    required String boardId,
    String? description,
    String? type,
    String? priority,
    String? assigneeId,
    String? dueDate,
  }) async {
    final response = await _api.post('/projects/$projectId/tasks', data: {
      'title': title,
      'boardId': boardId,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (priority != null) 'priority': priority,
      if (assigneeId != null) 'assigneeId': assigneeId,
      if (dueDate != null) 'dueDate': dueDate,
    });
    return Task.fromJson(response['data']);
  }

  Future<Task> updateTask(String taskId, Map<String, dynamic> data) async {
    final response = await _api.put('/tasks/$taskId', data: data);
    return Task.fromJson(response['data']);
  }

  Future<Task> updateTaskStatus(String taskId, String status) async {
    final response = await _api.patch('/tasks/$taskId/status', data: {'status': status});
    return Task.fromJson(response['data']);
  }

  Future<Task> moveTask(String taskId, {String? status, required int position}) async {
    final response = await _api.patch('/tasks/$taskId/move', data: {
      if (status != null) 'status': status,
      'position': position,
    });
    return Task.fromJson(response['data']);
  }

  Future<void> deleteTask(String taskId) async {
    await _api.delete('/tasks/$taskId');
  }
}
