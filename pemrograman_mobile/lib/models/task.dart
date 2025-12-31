import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final bool isDone;
  final DateTime? timestamp;

  Task({
    required this.id,
    required this.title,
    required this.isDone,
    this.timestamp,
  });

  // Convert Task to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'timestamp': timestamp ?? DateTime.now(),
    };
  }

  // Create Task from Map
  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      isDone: map['isDone'] ?? false,
      timestamp: map['timestamp'] != null 
          ? (map['timestamp'] as Timestamp).toDate()
          : null,
    );
  }

  // Copy with method untuk update task
  Task copyWith({
    String? id,
    String? title,
    bool? isDone,
    DateTime? timestamp,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}