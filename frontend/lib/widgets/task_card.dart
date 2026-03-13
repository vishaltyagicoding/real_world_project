import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../screens/task_form_screen.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  Color _getPriorityColor() {
    switch (task.priority) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.deepOrange;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor() {
    switch (task.status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                          value: 'complete', child: Text('Mark Complete')),
                      const PopupMenuItem(
                          value: 'delete', child: Text('Delete')),
                    ],
                    onSelected: (value) async {
                      final taskProvider =
                          Provider.of<TaskProvider>(context, listen: false);
                      if (value == 'edit') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => TaskFormScreen(task: task)),
                        );
                      } else if (value == 'complete') {
                        // Show loading indicator
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Marking task as complete...'),
                            duration: Duration(seconds: 1),
                          ),
                        );

                        final success =
                            await taskProvider.completeTask(task.id);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success
                                  ? 'Task marked as complete!'
                                  : 'Failed to complete task'),
                              backgroundColor:
                                  success ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Task'),
                            content: const Text('Are you sure?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          // Show loading indicator
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Deleting task...'),
                              duration: Duration(seconds: 1),
                            ),
                          );

                          final success =
                              await taskProvider.deleteTask(task.id);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Task deleted successfully!'
                                    : 'Failed to delete task'),
                                backgroundColor:
                                    success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(task.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text(task.status.replaceAll('_', ' ').toUpperCase()),
                    backgroundColor: _getStatusColor().withValues(alpha: 0.2),
                    labelStyle:
                        TextStyle(color: _getStatusColor(), fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(task.priority.toUpperCase()),
                    backgroundColor: _getPriorityColor().withValues(alpha: 0.2),
                    labelStyle:
                        TextStyle(color: _getPriorityColor(), fontSize: 12),
                  ),
                  if (task.isOverdue) ...[
                    const SizedBox(width: 8),
                    const Chip(
                      label: Text('OVERDUE'),
                      backgroundColor: Colors.red,
                      labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ],
              ),
              if (task.dueDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
