/// Task Data Model
/// Represents farming tasks
library;

enum TaskStatus { pending, completed, snoozed, overdue }

class TaskModel {
  final String id;
  final String title;
  final String cropName;
  final double fieldSize;
  final DateTime dueTime;
  final List<String> instructions;
  final String? quantity; // e.g., "10kg NPK" or "500L water"
  final String? videoUrl;
  final TaskStatus status;
  final DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.cropName,
    required this.fieldSize,
    required this.dueTime,
    required this.instructions,
    this.quantity,
    this.videoUrl,
    this.status = TaskStatus.pending,
    this.completedAt,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? cropName,
    double? fieldSize,
    DateTime? dueTime,
    List<String>? instructions,
    String? quantity,
    String? videoUrl,
    TaskStatus? status,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      cropName: cropName ?? this.cropName,
      fieldSize: fieldSize ?? this.fieldSize,
      dueTime: dueTime ?? this.dueTime,
      instructions: instructions ?? this.instructions,
      quantity: quantity ?? this.quantity,
      videoUrl: videoUrl ?? this.videoUrl,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  String get fieldSizeText => '$fieldSize acres';

  bool get isOverdue =>
      DateTime.now().isAfter(dueTime) && status == TaskStatus.pending;

  String get statusText {
    switch (status) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.snoozed:
        return 'Snoozed';
      case TaskStatus.overdue:
        return 'Overdue';
    }
  }
}
