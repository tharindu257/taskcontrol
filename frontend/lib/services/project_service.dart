import '../models/project.dart';
import 'api_service.dart';

class ProjectService {
  final _api = ApiService();

  Future<List<Project>> getProjects() async {
    final response = await _api.get('/projects');
    final list = response['data'] as List;
    return list.map((json) => Project.fromJson(json)).toList();
  }

  Future<Project> getProject(String id) async {
    final response = await _api.get('/projects/$id');
    return Project.fromJson(response['data']);
  }

  Future<Project> createProject({
    required String name,
    required String key,
    String? description,
  }) async {
    final response = await _api.post('/projects', data: {
      'name': name,
      'key': key,
      if (description != null) 'description': description,
    });
    return Project.fromJson(response['data']);
  }

  Future<Project> updateProject(String id, {String? name, String? description}) async {
    final response = await _api.put('/projects/$id', data: {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
    });
    return Project.fromJson(response['data']);
  }

  Future<void> deleteProject(String id) async {
    await _api.delete('/projects/$id');
  }
}
