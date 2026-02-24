import 'user.dart';

class Comment {
  final String id;
  final String taskId;
  final String authorId;
  final User? author;
  final String content;
  final bool edited;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Comment({
    required this.id,
    required this.taskId,
    required this.authorId,
    this.author,
    required this.content,
    this.edited = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      authorId: json['authorId'] as String,
      author: json['author'] != null ? User.fromJson(json['author']) : null,
      content: json['content'] as String,
      edited: json['edited'] as bool? ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
