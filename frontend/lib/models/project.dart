import 'user.dart';

class Project {
  final String id;
  final String key;
  final String name;
  final String? description;
  final String ownerId;
  final User? owner;
  final String visibility;
  final int taskCount;
  final int memberCount;
  final List<ProjectMember>? members;
  final List<Board>? boards;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Project({
    required this.id,
    required this.key,
    required this.name,
    this.description,
    required this.ownerId,
    this.owner,
    this.visibility = 'PRIVATE',
    this.taskCount = 0,
    this.memberCount = 0,
    this.members,
    this.boards,
    this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['ownerId'] as String,
      owner: json['owner'] != null ? User.fromJson(json['owner']) : null,
      visibility: json['visibility'] as String? ?? 'PRIVATE',
      taskCount: json['_count']?['tasks'] as int? ?? 0,
      memberCount: json['_count']?['members'] as int? ?? 0,
      members: json['members'] != null
          ? (json['members'] as List).map((m) => ProjectMember.fromJson(m)).toList()
          : null,
      boards: json['boards'] != null
          ? (json['boards'] as List).map((b) => Board.fromJson(b)).toList()
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

class ProjectMember {
  final String id;
  final String projectId;
  final String userId;
  final User? user;
  final String role;
  final DateTime? joinedAt;

  ProjectMember({
    required this.id,
    required this.projectId,
    required this.userId,
    this.user,
    this.role = 'MEMBER',
    this.joinedAt,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      userId: json['userId'] as String,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      role: json['role'] as String? ?? 'MEMBER',
      joinedAt: json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : null,
    );
  }
}

class Board {
  final String id;
  final String projectId;
  final String name;
  final String type;

  Board({
    required this.id,
    required this.projectId,
    required this.name,
    this.type = 'KANBAN',
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'KANBAN',
    );
  }
}
