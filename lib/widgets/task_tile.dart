import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pocket_tasks/screens/add_edit_task_screen.dart';
import 'package:pocket_tasks/screens/task_details_screen.dart';
import '../models/task.dart';
import '../providers/task_provider.dart' as taskProvider;


class TaskTile extends ConsumerWidget {
  final Task task;

  const TaskTile({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isOverdue = !task.isCompleted && (task.dueDate?.isBefore(DateTime.now()) ?? false);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Dismissible(
        key: Key(task.id),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) {
          ref.read(taskProvider.tasksProvider.notifier).deleteTask(task.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task "${task.title}" deleted'),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  ref.read(taskProvider.tasksProvider.notifier).addTask(task);
                },
              ),
            ),
          );
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isOverdue
                  ? theme.colorScheme.error.withOpacity(0.3)
                  : theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                ref.read(taskProvider.tasksProvider.notifier).updateTask(
                      task.copyWith(isCompleted: value ?? false),
                    );
              },
              activeColor: theme.colorScheme.primary,
            ),
            title: Text(
              task.title,
              style: theme.textTheme.titleMedium?.copyWith(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted
                    ? theme.colorScheme.onSurface.withOpacity(0.6)
                    : theme.colorScheme.onSurface,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Due: ${task.dueDate != null ? DateFormat('MMM dd, yyyy').format(task.dueDate!) : 'No due date'}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  task.isCompleted ? 'Done' : (isOverdue ? 'Missed' : 'Pending'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: task.isCompleted
                        ? theme.colorScheme.primary
                        : (isOverdue ? theme.colorScheme.error : theme.colorScheme.onSurface),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                  tooltip: 'Edit Task',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditTaskScreen(task: task),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: theme.colorScheme.error),
                  tooltip: 'Delete Task',
                  onPressed: () {
                    ref.read(taskProvider.tasksProvider.notifier).deleteTask(task.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Task "${task.title}" deleted'),
                        backgroundColor: theme.colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            ref.read(taskProvider.tasksProvider.notifier).addTask(task);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskDetailsScreen(task: task),
              ),
            ),
          ),
        ),
      ),
    );
  }
}