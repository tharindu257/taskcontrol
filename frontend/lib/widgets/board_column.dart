import 'package:flutter/material.dart';
import '../models/task.dart';
import '../config/theme.dart';
import 'task_card.dart';

class BoardColumn extends StatelessWidget {
  final String status;
  final List<Task> tasks;
  final ValueChanged<Task>? onTaskTap;
  final void Function(Task task, int position)? onTaskDropped;

  const BoardColumn({
    super.key,
    required this.status,
    required this.tasks,
    this.onTaskTap,
    this.onTaskDropped,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getStatusColor(status);
    final label = AppTheme.getStatusLabel(status);

    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Task list with drag target
          Expanded(
            child: DragTarget<Task>(
              onWillAcceptWithDetails: (details) => true,
              onAcceptWithDetails: (details) {
                onTaskDropped?.call(details.data, tasks.length);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? color.withOpacity(0.05)
                        : Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                    border: candidateData.isNotEmpty
                        ? Border.all(color: color.withOpacity(0.3), width: 2)
                        : null,
                  ),
                  child: tasks.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'No tasks',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return LongPressDraggable<Task>(
                              data: task,
                              feedback: Material(
                                elevation: 4,
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 280,
                                  child: TaskCard(task: task),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: TaskCard(task: task),
                              ),
                              child: TaskCard(
                                task: task,
                                onTap: () => onTaskTap?.call(task),
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
