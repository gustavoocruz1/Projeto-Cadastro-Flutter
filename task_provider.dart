import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) => task.isSameDay(date)).toList()
      ..sort((a, b) {
        final aMinutes = a.time.hour * 60 + a.time.minute;
        final bMinutes = b.time.hour * 60 + b.time.minute;
        return aMinutes.compareTo(bMinutes);
      });
  }

  List<Task> get incompleteTasks => 
      _tasks.where((task) => !task.isCompleted).toList();

  List<Task> get completedTasks => 
      _tasks.where((task) => task.isCompleted).toList();

  Set<DateTime> get datesWithTasks {
    return _tasks.map((task) => DateTime(
      task.date.year, 
      task.date.month, 
      task.date.day
    )).toSet();
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void removeTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    _saveTasks();
    notifyListeners();
  }

  void toggleTaskCompletion(String taskId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted
      );
      _saveTasks();
      notifyListeners();
    }
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('tasks');
      
      if (tasksJson != null) {
        final List<dynamic> decoded = jsonDecode(tasksJson);
        _tasks = decoded.map((json) => Task.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = jsonEncode(_tasks.map((task) => task.toJson()).toList());
      await prefs.setString('tasks', tasksJson);
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }
}