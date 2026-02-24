import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../services/project_service.dart';

final projectServiceProvider = Provider((ref) => ProjectService());

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final service = ref.read(projectServiceProvider);
  return service.getProjects();
});

final projectDetailProvider = FutureProvider.family<Project, String>((ref, projectId) async {
  final service = ref.read(projectServiceProvider);
  return service.getProject(projectId);
});
