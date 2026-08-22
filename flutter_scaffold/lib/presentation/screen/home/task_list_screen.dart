import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../controllers/task_controller.dart';
import '../../../../domain/entities/task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          taskController.setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                taskController.setSearchQuery(value);
              },
            ),
          ),
        ),
      ),
      body: Obx(() {
        final taskController = Get.find<TaskController>();

        if (taskController.isLoading.value && taskController.tasks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (taskController.error.value.isNotEmpty && taskController.tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${taskController.error.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    taskController.clearError();
                    taskController.loadTasks();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (taskController.tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No tasks yet',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add a task',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => taskController.loadTasks(),
          child: Column(
            children: [
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: taskController.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskController.tasks[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50,
                          child: FadeInAnimation(
                            child: _buildTaskCard(context, task),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (taskController.totalPages.value > 1)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: taskController.currentPage.value > 1
                            ? taskController.previousPage
                            : null,
                      ),
                      Text(
                        'Page ${taskController.currentPage.value} of ${taskController.totalPages.value}',
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: taskController.currentPage.value <
                                taskController.totalPages.value
                            ? taskController.nextPage
                            : null,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    final taskController = Get.find<TaskController>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isComplete,
          onChanged: (_) {
            taskController.toggleTaskComplete(task.id);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration: task.isComplete
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: task.isComplete ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              Text(
                task.description,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            Row(
              children: [
                _buildPriorityChip(task.priority),
                const SizedBox(width: 4),
                if (task.dueDate != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: task.isOverdue ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${task.dueDate!.day}/${task.dueDate!.month}',
                    style: TextStyle(
                      fontSize: 10,
                      color: task.isOverdue ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
                const Spacer(),
                if (task.isDeleted)
                  const Text(
                    'Deleted',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => _deleteTask(context, task.id),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (task.status == TaskStatus.IN_PROGRESS)
              const Icon(
                Icons.hourglass_top,
                size: 16,
                color: Colors.orange,
              ),
            if (task.status == TaskStatus.COMPLETED)
              const Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.green,
              ),
          ],
        ),
        onTap: () {
          _showTaskDetailDialog(context, task);
        },
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    Color color;
    switch (priority) {
      case TaskPriority.HIGH:
        color = Colors.red;
        break;
      case TaskPriority.MEDIUM:
        color = Colors.orange;
        break;
      case TaskPriority.LOW:
        color = Colors.green;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        priority.name,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _deleteTask(BuildContext context, String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              final success = await Get.find<TaskController>().deleteTask(id);
              if (success) {
                Get.snackbar(
                  'Success',
                  'Task deleted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showTaskDetailDialog(BuildContext context, Task task) {
    final taskController = Get.find<TaskController>();
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    var selectedStatus = task.status;
    var selectedPriority = task.priority;
    var selectedDueDate = task.dueDate;

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Task'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TaskStatus>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: TaskStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setDialogState(() => selectedStatus = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TaskPriority>(
                    value: selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: TaskPriority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setDialogState(() => selectedPriority = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    title: Text(
                      selectedDueDate == null
                          ? 'No Due Date'
                          : 'Due: ${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDueDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setDialogState(() => selectedDueDate = date);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          if (task.isDeleted)
            TextButton(
              onPressed: () async {
                Get.back();
                final success =
                    await Get.find<TaskController>().restoreTask(task.id);
                if (success) {
                  Get.snackbar(
                    'Success',
                    'Task restored successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                }
              },
              child: const Text('Restore'),
            ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() {
            final taskController = Get.find<TaskController>();
            return ElevatedButton(
              onPressed: taskController.isLoading.value
                  ? null
                  : () async {
                      final success = await taskController.updateTask(
                        id: task.id,
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                        status: selectedStatus,
                        priority: selectedPriority,
                        dueDate: selectedDueDate,
                      );

                      if (success) {
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Task updated successfully',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } else {
                        Get.snackbar(
                          'Error',
                          taskController.error.value,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
              child: taskController.isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save'),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final taskController = Get.find<TaskController>();

    Get.dialog(
      AlertDialog(
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Status:'),
            DropdownButtonFormField<TaskStatus?>(
              value: taskController.filterStatus.value,
              hint: const Text('All Statuses'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Statuses'),
                ),
                ...TaskStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name),
                  );
                }),
              ],
              onChanged: (value) {
                taskController.setFilterStatus(value);
                Get.back();
              },
            ),
            const SizedBox(height: 16),
            const Text('Priority:'),
            DropdownButtonFormField<TaskPriority?>(
              value: taskController.filterPriority.value,
              hint: const Text('All Priorities'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Priorities'),
                ),
                ...TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.name),
                  );
                }),
              ],
              onChanged: (value) {
                taskController.setFilterPriority(value);
                Get.back();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              taskController.clearFilters();
              Get.back();
            },
            child: const Text('Clear Filters'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}