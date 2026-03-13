import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  TaskStatistics? _statistics;
  bool _isLoading = false;
  String? _error;
  String? _statusFilter;
  String? _priorityFilter;

  List<Task> get tasks => _tasks;
  TaskStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get statusFilter => _statusFilter;
  String? get priorityFilter => _priorityFilter;

  Future<void> loadTasks({String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await TaskService.getTasks(
        status: _statusFilter,
        priority: _priorityFilter,
        search: search,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStatistics() async {
    try {
      _statistics = await TaskService.getStatistics();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createTask(Map<String, dynamic> data) async {
    try {
      final task = await TaskService.createTask(data);
      _tasks.insert(0, task);
      // Reload statistics after creation
      await loadStatistics();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(int id, Map<String, dynamic> data) async {
    try {
      final updatedTask = await TaskService.updateTask(id, data);
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        // Reload statistics after update (status/priority might have changed)
        await loadStatistics();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int id) async {
    try {
      await TaskService.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      // Reload statistics after deletion
      await loadStatistics();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeTask(int id) async {
    try {
      await TaskService.completeTask(id);
      // Reload both tasks and statistics
      await loadTasks();
      await loadStatistics();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    loadTasks();
  }

  void setPriorityFilter(String? priority) {
    _priorityFilter = priority;
    loadTasks();
  }

  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    loadTasks();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
