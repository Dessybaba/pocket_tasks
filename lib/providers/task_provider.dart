import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/database_service.dart';

enum TaskFilter { all, active, completed }
enum TaskSort { dueDate, creationDate }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);
final taskSortProvider = StateProvider<TaskSort>((ref) => TaskSort.dueDate);

final tasksProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);

  Future<void> init() async {
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await DatabaseService.instance.getTasks();
      state = tasks;
      print('Loaded ${tasks.length} tasks into state');
    } catch (e) {
      print('Error loading tasks: $e');
      state = [];
      // Retry initialization once after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        final tasks = await DatabaseService.instance.getTasks();
        state = tasks;
        print('Retry succeeded: Loaded ${tasks.length} tasks into state');
      } catch (retryError) {
        print('Retry failed: $retryError');
        // Notify user of persistent failure
        throw Exception('Failed to load tasks. Please restart the app or check storage permissions.');
      }
    }
  }

  Future<void> refreshTasks() async {
    await _loadTasks();
  }

  Future<void> addTask(Task task) async {
    try {
      await DatabaseService.instance.insertTask(task);
      await _loadTasks();
      print('Added task, new state: $state');
    } catch (e) {
      print('Error adding task: $e');
      throw Exception('Failed to add task. Please try again.');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await DatabaseService.instance.updateTask(task);
      state = [
        for (final t in state)
          t.id == task.id ? task : t,
      ];
      print('Updated state: $state');
    } catch (e) {
      print('Error updating task: $e');
      throw Exception('Failed to update task. Please try again.');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await DatabaseService.instance.deleteTask(id);
      state = state.where((task) => task.id != id).toList();
      print('Deleted task, new state: $state');
    } catch (e) {
      print('Error deleting task: $e');
      throw Exception('Failed to delete task. Please try again.');
    }
  }
}