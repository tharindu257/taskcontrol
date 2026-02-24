import 'package:flutter/material.dart';
import '../models/task.dart';
import '../config/theme.dart';
import 'priority_badge.dart';
import 'user_avatar.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Key and type
              Row(
                children: [
                  Text(
                    task.key,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  _typeIcon(task.type),
                ],
              ),
              const SizedBox(height: 6),

              // Title
              Text(
                task.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Labels
              if (task.labels != null && task.labels!.isNotEmpty) ...[
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: task.labels!.take(3).map((tl) {
                    final label = tl.label;
                    if (label == null) return const SizedBox();
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _hexToColor(label.color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        label.name,
                        style: TextStyle(fontSize: 10, color: _hexToColor(label.color)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],

              // Bottom row: priority, assignee, comments
              Row(
                children: [
                  PriorityBadge(priority: task.priority),
                  const Spacer(),
                  if (task.commentCount > 0) ...[
                    Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 2),
                    Text(
                      '${task.commentCount}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (task.assignee != null)
                    UserAvatar(name: task.assignee!.displayName, size: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeIcon(String type) {
    IconData icon;
    Color color;
    switch (type) {
      case 'BUG':
        icon = Icons.bug_report;
        color = AppTheme.errorColor;
        break;
      case 'FEATURE':
        icon = Icons.lightbulb_outline;
        color = AppTheme.successColor;
        break;
      case 'STORY':
        icon = Icons.auto_stories;
        color = AppTheme.primaryColor;
        break;
      default:
        icon = Icons.check_box_outlined;
        color = Colors.grey[600]!;
    }

    return Icon(icon, size: 16, color: color);
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
