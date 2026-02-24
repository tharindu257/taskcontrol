import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/api_service.dart';

final boardTasksProvider = FutureProvider.family<BoardData, String>((ref, boardId) async {
  final api = ApiService();
  final response = await api.get('/boards/$boardId');
  final data = response['data'];

  final tasks = (data['tasks'] as List).map((t) => Task.fromJson(t)).toList();

  return BoardData(
    id: data['id'],
    name: data['name'],
    projectId: data['projectId'],
    tasks: tasks,
  );
});

class BoardData {
  final String id;
  final String name;
  final String projectId;
  final List<Task> tasks;

  BoardData({
    required this.id,
    required this.name,
    required this.projectId,
    required this.tasks,
  });

  List<Task> getTasksByStatus(String status) {
    return tasks.where((t) => t.status == status).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }
}
