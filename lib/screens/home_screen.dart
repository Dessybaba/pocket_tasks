import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart' as taskProvider;
import '../providers/theme_provider.dart';
import '../widgets/task_tile.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Initializing tasks in HomeScreen');
      ref.read(taskProvider.tasksProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider.tasksProvider);
    final filter = ref.watch(taskProvider.taskFilterProvider);
    final sort = ref.watch(taskProvider.taskSortProvider);
    final themeMode = ref.watch(themeProvider);
    final theme = Theme.of(context);

    List<Task> filteredTasks = tasks.where((task) {
      switch (filter) {
        case taskProvider.TaskFilter.active:
          return !task.isCompleted;
        case taskProvider.TaskFilter.completed:
          return task.isCompleted;
        case taskProvider.TaskFilter.all:
        default:
          return true;
      }
    }).toList();

    filteredTasks.sort((a, b) {
      if (sort == taskProvider.TaskSort.dueDate) {
        return (a.dueDate ?? DateTime.now()).compareTo(b.dueDate ?? DateTime.now());
      }
      return (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now());
    });

    print('Rendering HomeScreen with ${filteredTasks.length} tasks');

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.brightness == Brightness.dark
                  ? [Colors.blueGrey.shade900, Colors.blueGrey.shade700]
                  : [Colors.blue.shade600, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Pocket Tasks',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            key: const Key('theme_toggle_button'),
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              ref.read(themeProvider.notifier).update((state) =>
                  state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
          PopupMenuButton<taskProvider.TaskFilter>(
            key: const Key('filter_menu'),
            tooltip: 'Filter Tasks',
            icon: Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) => ref.read(taskProvider.taskFilterProvider.notifier).state = value,
            itemBuilder: (context) => taskProvider.TaskFilter.values
                .map((filter) => PopupMenuItem(
                      value: filter,
                      child: Text(
                        filter.toString().split('.').last.capitalize(),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ))
                .toList(),
          ),
          PopupMenuButton<taskProvider.TaskSort>(
            key: const Key('sort_menu'),
            tooltip: 'Sort Tasks',
            icon: Icon(Icons.sort, color: Colors.white),
            onSelected: (value) => ref.read(taskProvider.taskSortProvider.notifier).state = value,
            itemBuilder: (context) => taskProvider.TaskSort.values
                .map((sort) => PopupMenuItem(
                      value: sort,
                      child: Text(
                        'Sort by ${sort.toString().split('.').last.capitalize()}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          print('Refreshing tasks');
          await ref.read(taskProvider.tasksProvider.notifier).refreshTasks();
        },
        child: filteredTasks.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 80,
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      filter == taskProvider.TaskFilter.all
                          ? 'No tasks yet. Add one!'
                          : filter == taskProvider.TaskFilter.active
                              ? 'No active tasks.'
                              : 'No completed tasks.',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Add Your First Task'),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return Hero(
                    tag: 'task-${task.id}',
                    child: TaskTile(task: task),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('add_task_button'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddEditTaskScreen(),
            settings: const RouteSettings(name: 'AddEditTaskScreen'),
          ),
        ),
        tooltip: 'Add Task',
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        heroTag: 'fab',
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}