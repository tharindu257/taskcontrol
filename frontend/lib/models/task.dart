import 'user.dart';
import 'comment.dart';
import 'label.dart';

class Task {
  final String id;
  final String projectId;
  final String boardId;
  final String key;
  final String title;
  final String? description;
  final String type;
  final String status;
  final String priority;
  final String creatorId;
  final User? creator;
  final String? assigneeId;
  final User? assignee;
  final DateTime? dueDate;
  final int position;
  final List<TaskLabel>? labels;
  final List<Comment>? comments;
  final int commentCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.projectId,
    required this.boardId,
    required this.key,
    required this.title,
    this.description,
    this.type = 'TASK',
    this.status = 'TO_DO',
    this.priority = 'MEDIUM',
    required this.creatorId,
    this.creator,
    this.assigneeId,
    this.assignee,
    this.dueDate,
    this.position = 0,
    this.labels,
    this.comments,
    this.commentCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      boardId: json['boardId'] as String,
      key: json['key'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'TASK',
      status: json['status'] as String? ?? 'TO_DO',
      priority: json['priority'] as String? ?? 'MEDIUM',
      creatorId: json['creatorId'] as String,
      creator: json['creator'] != null ? User.fromJson(json['creator']) : null,
      assigneeId: json['assigneeId'] as String?,
      assignee: json['assignee'] != null ? User.fromJson(json['assignee']) : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      position: json['position'] as int? ?? 0,
      labels: json['labels'] != null
          ? (json['labels'] as List).map((l) => TaskLabel.fromJson(l)).toList()
          : null,
      comments: json['comments'] != null
          ? (json['comments'] as List).map((c) => Comment.fromJson(c)).toList()
          : null,
      commentCount: json['_count']?['comments'] as int? ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Task copyWith({
    String? status,
    String? priority,
    String? assigneeId,
    int? position,
  }) {
    return Task(
      id: id,
      projectId: projectId,
      boardId: boardId,
      key: key,
      title: title,
      description: description,
      type: type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      creatorId: creatorId,
      creator: creator,
      assigneeId: assigneeId ?? this.assigneeId,
      assignee: assignee,
      dueDate: dueDate,
      position: position ?? this.position,
      labels: labels,
      comments: comments,
      commentCount: commentCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
