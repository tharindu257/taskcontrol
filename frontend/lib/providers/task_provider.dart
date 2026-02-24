import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/task_service.dart';

final taskServiceProvider = Provider((ref) => TaskService());

final taskDetailProvider = FutureProvider.family<Task, String>((ref, taskId) async {
  final service = ref.read(taskServiceProvider);
  return service.getTask(taskId);
});
