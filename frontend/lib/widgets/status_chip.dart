import 'package:flutter/material.dart';
import '../config/theme.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final ValueChanged<String>? onChanged;

  const StatusChip({super.key, required this.status, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getStatusColor(status);
    final label = AppTheme.getStatusLabel(status);

    if (onChanged == null) {
      return _buildChip(color, label);
    }

    return PopupMenuButton<String>(
      onSelected: onChanged,
      child: _buildChip(color, label),
      itemBuilder: (context) => [
        _menuItem('TO_DO', 'To Do'),
        _menuItem('IN_PROGRESS', 'In Progress'),
        _menuItem('IN_REVIEW', 'In Review'),
        _menuItem('DONE', 'Done'),
      ],
    );
  }

  Widget _buildChip(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
          if (onChanged != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 16, color: color),
          ],
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, String label) {
    final color = AppTheme.getStatusColor(value);
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label),
          if (value == status) ...[
            const Spacer(),
            Icon(Icons.check, size: 16, color: color),
          ],
        ],
      ),
    );
  }
}
