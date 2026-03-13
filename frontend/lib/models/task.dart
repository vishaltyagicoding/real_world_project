import 'user.dart';

class Task {
  final int id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final User user;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOverdue;
  final List<TaskComment> comments;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.user,
    this.dueDate,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.isOverdue,
    this.comments = const [],
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      status: json['status'] as String,
      priority: json['priority'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isOverdue: (json['is_overdue'] as bool?) ?? false,
      comments: (json['comments'] as List?)
              ?.map((c) => TaskComment.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'due_date': dueDate?.toIso8601String(),
    };
  }
}

class TaskComment {
  final int id;
  final User user;
  final String content;
  final DateTime createdAt;

  TaskComment({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      id: json['id'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class TaskStatistics {
  final int total;
  final int pending;
  final int inProgress;
  final int completed;
  final int cancelled;
  final int overdue;

  TaskStatistics({
    required this.total,
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.cancelled,
    required this.overdue,
  });

  factory TaskStatistics.fromJson(Map<String, dynamic> json) {
    return TaskStatistics(
      total: (json['total'] as int?) ?? 0,
      pending: (json['pending'] as int?) ?? 0,
      inProgress: (json['in_progress'] as int?) ?? 0,
      completed: (json['completed'] as int?) ?? 0,
      cancelled: (json['cancelled'] as int?) ?? 0,
      overdue: (json['overdue'] as int?) ?? 0,
    );
  }
}
