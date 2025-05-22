// widgets/task_card.dart
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'add_task_form.dart';

// Helper to get color based on priority
Color _getPriorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'Urgente':
      return Colors.red.shade300;
    case 'alta':
      return Colors.orange.shade300;
    case 'média': // Corrected from 'media'
      return Colors.yellow.shade300;
    case 'baixa':
      return Colors.blue.shade300;
    default:
      return Colors.grey.shade300;
  }
}

// Helper to get icon based on status
IconData _getStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'pendente':
      return Icons.pending_actions_outlined;
    case 'em progresso':
      return Icons.directions_run; // Or Icons.sync for 'in progress'
    case 'concluída':
      return Icons.check_circle_outline;
    default:
      return Icons.help_outline;
  }
}

class TaskCardWidget extends StatelessWidget {
  final Task task;
  final VoidCallback onTaskDeleted;
  final Function(Task) onTaskUpdated; // Callback to pass the updated task

  const TaskCardWidget({
    super.key,
    required this.task,
    required this.onTaskDeleted,
    required this.onTaskUpdated,
  });

  void _showEditTaskForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Assuming AddTaskFormWidget can also handle editing if an existing task is passed
        return AddTaskFormWidget(
          userEmail:
              "dummy@example.com", // This needs to be passed correctly if needed by the form
          onTaskAdded: (updatedTask) {
            // Renaming for clarity, it's an update here
            onTaskUpdated(updatedTask);
          },
          existingTask: task, // Pass the current task to prefill the form
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine text color based on card background for contrast
    Color priorityColor = _getPriorityColor(task.prioridade);
    // bool isDarkPriority = priorityColor.computeLuminance() < 0.5;
    // Color textColor = isDarkPriority ? Colors.white : Colors.black87;
    Color textColor = Colors.black87; // Defaulting to black for simplicity

    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        // width: 300, // Fixed width, or make it responsive
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          // Gradient or solid color based on your design
          // border: Border.all(color: Colors.grey.shade300),
          color: Colors.white, // Base color of the card
          border: Border(
            left: BorderSide(
              color: _getPriorityColor(task.prioridade),
              width: 5,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Important for GridView height
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: textColor),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditTaskForm(context);
                    } else if (value == 'delete') {
                      // Show confirmation dialog before deleting
                      showDialog(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              title: const Text('Confirmar Exclusão'),
                              content: Text(
                                'Tem certeza que deseja excluir a tarefa "${task.titulo}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    onTaskDeleted();
                                  },
                                  child: const Text(
                                    'Excluir',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Editar'),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            title: Text(
                              'Excluir',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (task.descricao.isNotEmpty)
              Text(
                task.descricao,
                style: TextStyle(
                  fontSize: 14.0,
                  color: textColor.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Icon(
                  _getStatusIcon(task.status),
                  size: 18,
                  color: textColor.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  task.status,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: textColor.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  'Concluir até: ${task.dataConclusao}', // Format date if needed
                  style: TextStyle(
                    fontSize: 13.0,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getPriorityColor(task.prioridade).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                task.prioridade,
                style: TextStyle(
                  color: _getPriorityColor(
                    task.prioridade,
                  ).darken(0.3), // Make text darker for better contrast
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
            // Add more details or actions as needed
          ],
        ),
      ),
    );
  }
}

// Extension to darken a color (for text contrast on light backgrounds)
extension ColorUtils on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
