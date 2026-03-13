import '../config/api_config.dart';
import '../models/task.dart';
import 'api_service.dart';

class TaskService {
  static Future<List<Task>> getTasks({String? status, String? priority, String? search}) async {
    String url = ApiConfig.tasksEndpoint;
    List<String> params = [];
    
    if (status != null) params.add('status=$status');
    if (priority != null) params.add('priority=$priority');
    if (search != null && search.isNotEmpty) params.add('search=$search');
    
    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }
    
    final response = await ApiService.get(url);
    final results = response['results'] ?? response;
    return (results as List).map((json) => Task.fromJson(json)).toList();
  }

  static Future<Task> getTask(int id) async {
    final response = await ApiService.get(ApiConfig.taskDetailEndpoint(id));
    return Task.fromJson(response);
  }

  static Future<Task> createTask(Map<String, dynamic> data) async {
    final response = await ApiService.post(ApiConfig.tasksEndpoint, data);
    return Task.fromJson(response);
  }

  static Future<Task> updateTask(int id, Map<String, dynamic> data) async {
    final response = await ApiService.put(ApiConfig.taskDetailEndpoint(id), data);
    return Task.fromJson(response);
  }

  static Future<void> deleteTask(int id) async {
    await ApiService.delete(ApiConfig.taskDetailEndpoint(id));
  }

  static Future<void> completeTask(int id) async {
    await ApiService.post(ApiConfig.taskCompleteEndpoint(id), {});
  }

  static Future<void> addComment(int taskId, String content) async {
    await ApiService.post(ApiConfig.taskCommentEndpoint(taskId), {'content': content});
  }

  static Future<TaskStatistics> getStatistics() async {
    final response = await ApiService.get(ApiConfig.taskStatisticsEndpoint);
    return TaskStatistics.fromJson(response);
  }
}
