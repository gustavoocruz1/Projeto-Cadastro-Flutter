import 'dart:convert';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.date,
    required this.time,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? time,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'hour': time.hour,
      'minute': time.minute,
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      time: TimeOfDay(hour: json['hour'], minute: json['minute']),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String get formattedTime {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  bool isSameDay(DateTime other) {
    return date.year == other.year && 
           date.month == other.month && 
           date.day == other.day;
  }
}