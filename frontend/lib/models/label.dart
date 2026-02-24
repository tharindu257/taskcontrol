class Label {
  final String id;
  final String projectId;
  final String name;
  final String color;

  Label({
    required this.id,
    required this.projectId,
    required this.name,
    this.color = '#0052CC',
  });

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      color: json['color'] as String? ?? '#0052CC',
    );
  }
}

class TaskLabel {
  final String id;
  final String taskId;
  final String labelId;
  final Label? label;

  TaskLabel({
    required this.id,
    required this.taskId,
    required this.labelId,
    this.label,
  });

  factory TaskLabel.fromJson(Map<String, dynamic> json) {
    return TaskLabel(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      labelId: json['labelId'] as String,
      label: json['label'] != null ? Label.fromJson(json['label']) : null,
    );
  }
}
