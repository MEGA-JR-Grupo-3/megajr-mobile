// lib/widgets/task_card.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/task.dart';
import 'package:intl/intl.dart';
import '../pages/dashboard_page.dart' hide TaskPriority, TaskStatus;

class TaskCard extends StatefulWidget {
  final Task tarefa;
  final Function(int taskId) onTaskDeleted;
  final Function(Task updatedTask) onTaskUpdated;
  final bool isDraggable;
  final String firebaseIdToken;
  final TaskDisplaySize taskDisplaySize;
  final DueDateInfo Function(DateTime? date, BuildContext context)
  getDueDateStatus;
  final Color Function(TaskPriority priority, BuildContext context)
  getPriorityColor;

  const TaskCard({
    super.key,
    required this.tarefa,
    required this.onTaskDeleted,
    required this.onTaskUpdated,
    this.isDraggable = false,
    required this.firebaseIdToken,
    required this.taskDisplaySize,
    required this.getDueDateStatus,
    required this.getPriorityColor,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late Task _currentTask;
  bool _isDeleting = false;
  bool _isUpdatingStatus = false;
  bool _isSavingEdit = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  TaskPriority? _selectedPriority;
  DateTime? _selectedDate;
  bool _isEditing = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.tarefa;
    _titleController.text = _currentTask.titulo;
    _descriptionController.text = _currentTask.descricao ?? '';
    _selectedPriority = _currentTask.prioridade;
    _selectedDate = _currentTask.dataPrazo;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<bool> _makeApiRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
    required Function(dynamic responseData) successCallback,
    required String errorMsgPrefix,
    required ValueSetter<bool> setLoadingState,
  }) async {
    if (widget.firebaseIdToken.isEmpty) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Sessão expirada ou não autenticada. Faça login novamente.",
          ),
        ),
      );
      return false;
    }

    setLoadingState(true);
    final client = http.Client();
    try {
      final request =
          http.Request(
              method,
              Uri.parse("https://megajr-back-end.onrender.com/api$endpoint"),
            )
            ..headers['Content-Type'] = 'application/json'
            ..headers['Authorization'] = 'Bearer ${widget.firebaseIdToken}';

      if (body != null) {
        request.body = jsonEncode(body);
      }

      final response = await client.send(request);
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData =
            responseBody.isNotEmpty ? jsonDecode(responseBody) : {};
        successCallback(responseData);
        return true;
      } else {
        final errorData =
            responseBody.isNotEmpty
                ? jsonDecode(responseBody)
                : {'message': response.reasonPhrase ?? 'Erro desconhecido'};
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$errorMsgPrefix: ${errorData['message'] ?? response.reasonPhrase}",
            ),
          ),
        );
        if (response.statusCode == 401 || response.statusCode == 403) {
          if (!mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Sessão expirada ou não autorizada. Faça login novamente.",
              ),
            ),
          );
        }
        return false;
      }
    } catch (error) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro de conexão: ${errorMsgPrefix.toLowerCase()}."),
        ),
      );
      return false;
    } finally {
      client.close();
      setLoadingState(false);
    }
  }

  Future<void> _handleDelete() async {
    if (_isDeleting) return;
    await _makeApiRequest(
      endpoint: "/tasks/${_currentTask.idTarefa}",
      method: "DELETE",
      successCallback: (_) {
        widget.onTaskDeleted(_currentTask.idTarefa);
      },
      errorMsgPrefix: "Erro ao deletar tarefa",
      setLoadingState: (loading) => setState(() => _isDeleting = loading),
    );
  }

  Future<void> _handleStatusChange(bool? isChecked) async {
    if (_isUpdatingStatus) return;
    final newStatus = isChecked! ? TaskStatus.Finalizada : TaskStatus.Pendente;
    await _makeApiRequest(
      endpoint: "/tasks/${_currentTask.idTarefa}/status",
      method: "PUT",
      body: {"estado_tarefa": newStatus.toString().split('.').last},
      successCallback: (_) {
        setState(() {
          _currentTask = _currentTask.copyWith(estadoTarefa: newStatus);
        });
        widget.onTaskUpdated(_currentTask);
      },
      errorMsgPrefix: "Erro ao atualizar estado",
      setLoadingState: (loading) => setState(() => _isUpdatingStatus = loading),
    );
  }

  Future<void> _handleEditSave() async {
    if (_isSavingEdit) return;

    if (_titleController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O título da tarefa não pode ser vazio.")),
      );
      return;
    }

    DateTime? newDatePrazo;
    try {
      if (_dateController.text.isNotEmpty) {
        newDatePrazo = DateFormat('yyyy-MM-dd').parse(_dateController.text);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Formato de data inválido. Use AAAA-MM-DD."),
        ),
      );
      return;
    }

    final updatedFields = {
      "titulo": _titleController.text.trim(),
      "descricao":
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
      "data_prazo": newDatePrazo?.toIso8601String().split('T').first,
      "prioridade": _currentTask.prioridade.toString().split('.').last,
      "estado_tarefa": _currentTask.estadoTarefa.toString().split('.').last,
    };

    await _makeApiRequest(
      endpoint: "/tasks/${_currentTask.idTarefa}",
      method: "PUT",
      body: updatedFields,
      successCallback: (_) {
        setState(() {
          _currentTask = _currentTask.copyWith(
            titulo: updatedFields["titulo"] as String,
            descricao: updatedFields["descricao"],
            dataPrazo: newDatePrazo,
          );
          _isEditing = false;
        });
        widget.onTaskUpdated(_currentTask);
      },
      errorMsgPrefix: "Erro ao atualizar tarefa",
      setLoadingState: (loading) => setState(() => _isSavingEdit = loading),
    );
  }

  void _resetFormAndExitEdit() {
    setState(() {
      _isEditing = false;
      _titleController.text = _currentTask.titulo;
      _descriptionController.text = _currentTask.descricao ?? '';
      _dateController.text =
          _currentTask.dataPrazo != null
              ? DateFormat('yyyy-MM-dd').format(_currentTask.dataPrazo!)
              : '';
    });
  }

  void _handleEditCancel() {
    _resetFormAndExitEdit();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isEditing && _isExpanded) {
        _resetFormAndExitEdit();
      }
    });
  }

  void _openEditMode() {
    setState(() {
      _titleController.text = _currentTask.titulo;
      _descriptionController.text = _currentTask.descricao ?? '';
      _dateController.text =
          _currentTask.dataPrazo != null
              ? DateFormat('yyyy-MM-dd').format(_currentTask.dataPrazo!)
              : '';
      _isEditing = true;
      if (!_isExpanded) _isExpanded = true;
    });
  }

  void _selectEditDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentTask.dataPrazo ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _currentTask = _currentTask.copyWith(dataPrazo: picked);
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Adaptação das funções de tamanho do Tailwind para responsividade
  double _getCardWidth() {
    switch (widget.taskDisplaySize) {
      case TaskDisplaySize.small:
        return 235.0; // w-[235px]
      case TaskDisplaySize.large:
        return 400.0; // w-[400px]
      case TaskDisplaySize.medium:
      default:
        return 335.0;
    }
  }

  double _getCardMinHeight() {
    switch (widget.taskDisplaySize) {
      case TaskDisplaySize.small:
        return 120.0; // min-h-[120px]
      case TaskDisplaySize.large:
        return 220.0; // min-h-[220px]
      case TaskDisplaySize.medium:
      default:
        return 100.0; // min-h-[100px]
    }
  }

  EdgeInsets _getCardPadding() {
    switch (widget.taskDisplaySize) {
      case TaskDisplaySize.small:
        return const EdgeInsets.all(12.0); // p-3 (equivalente a 12px)
      case TaskDisplaySize.large:
        return const EdgeInsets.all(24.0); // p-6 (equivalente a 24px)
      case TaskDisplaySize.medium:
      default:
        return const EdgeInsets.all(16.0); // p-4 (equivalente a 16px)
    }
  }

  TextStyle _getTitleTextStyle(BuildContext context) {
    switch (widget.taskDisplaySize) {
      case TaskDisplaySize.small:
        return Theme.of(context).textTheme.bodyLarge!;
      case TaskDisplaySize.large:
        return Theme.of(context).textTheme.headlineSmall!;
      case TaskDisplaySize.medium:
      default:
        return Theme.of(context).textTheme.titleLarge!;
    }
  }

  TextStyle _getDescriptionTextStyle(BuildContext context) {
    switch (widget.taskDisplaySize) {
      case TaskDisplaySize.small:
        return Theme.of(context).textTheme.bodySmall!;
      case TaskDisplaySize.large:
        return Theme.of(context).textTheme.bodyLarge!;
      case TaskDisplaySize.medium:
      default:
        return Theme.of(context).textTheme.bodyMedium!;
    }
  }

  EdgeInsets _getDatePriorityPadding(BuildContext context) {
    switch (widget.taskDisplaySize) {
      case TaskDisplaySize.small:
        return const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0);
      case TaskDisplaySize.large:
        return const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0);
      case TaskDisplaySize.medium:
      default:
        return const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);
    }
  }

  TextStyle _getDatePriorityTextStyle(BuildContext context) {
    switch (widget.taskDisplaySize) {
      case TaskDisplaySize.small:
        return Theme.of(context).textTheme.bodySmall!;
      case TaskDisplaySize.large:
        return Theme.of(context).textTheme.bodyLarge!;
      case TaskDisplaySize.medium:
      default:
        return Theme.of(context).textTheme.bodySmall!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final DueDateInfo dueDateInfo = widget.getDueDateStatus(
      _currentTask.dataPrazo,
      context,
    );
    final Color priorityColor = widget.getPriorityColor(
      _currentTask.prioridade,
      context,
    );
    final isLoading = _isDeleting || _isUpdatingStatus || _isSavingEdit;
    final isTaskCompleted = _currentTask.estadoTarefa == TaskStatus.Finalizada;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: _getCardWidth(), // Define a largura mínima
        maxWidth: _getCardWidth(), // Define a largura máxima (fixa)
        minHeight: _getCardMinHeight(), // Define a altura mínima
      ),
      child: Card(
        elevation: 4.0,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: _getCardPadding(), // Usa o padding dinâmico
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _currentTask.titulo,
                      style: _getTitleTextStyle(context).copyWith(
                        // Usar _getTitleTextStyle
                        fontWeight: FontWeight.bold,
                        decoration:
                            _currentTask.estadoTarefa == TaskStatus.Finalizada
                                ? TextDecoration.lineThrough
                                : null,
                        color:
                            _currentTask.estadoTarefa == TaskStatus.Finalizada
                                ? Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant.withOpacity(0.6)
                                : Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!_isEditing)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            size: 20,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _deleteTask(_currentTask.idTarefa),
                        ),
                      ],
                    ),
                ],
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 8.0),
                Text(
                  _currentTask.descricao ?? 'Sem descrição',
                  style: _getDescriptionTextStyle(context).copyWith(
                    // Usar _getDescriptionTextStyle
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    decoration:
                        _currentTask.estadoTarefa == TaskStatus.Finalizada
                            ? TextDecoration.lineThrough
                            : null,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(Icons.flag, size: 16, color: priorityColor),
                    const SizedBox(width: 4.0),
                    Text(
                      _currentTask.prioridade.toString().split('.').last,
                      style: _getDatePriorityTextStyle(context).copyWith(
                        // Usar _getDatePriorityTextStyle
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: dueDateInfo.color,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      dueDateInfo
                          .text, // <-- Acesso correto ao 'text' de DueDateInfo
                      style: _getDatePriorityTextStyle(context).copyWith(
                        // Usar _getDatePriorityTextStyle
                        color: dueDateInfo.color,
                        fontWeight:
                            dueDateInfo.text.contains('Atrasado')
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Checkbox(
                    value: _currentTask.estadoTarefa == TaskStatus.Finalizada,
                    onChanged: (bool? newValue) {
                      if (newValue != null) {
                        _updateTaskStatus(newValue);
                      }
                    },
                    activeColor: Theme.of(context).colorScheme.tertiary,
                    checkColor: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ] else ...[
                // Modo de Edição (se você tiver um)
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                ),
                DropdownButtonFormField<TaskPriority>(
                  value: _selectedPriority,
                  onChanged: (TaskPriority? newValue) {
                    setState(() {
                      _selectedPriority = newValue;
                    });
                  },
                  items:
                      TaskPriority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority.toString().split('.').last),
                        );
                      }).toList(),
                  decoration: const InputDecoration(labelText: 'Prioridade'),
                ),
                ListTile(
                  title: Text(
                    _selectedDate == null
                        ? 'Selecionar Data de Prazo'
                        : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          // Resetar os controladores caso o usuário cancele
                          _titleController.text = _currentTask.titulo;
                          _descriptionController.text =
                              _currentTask.descricao ?? '';
                          _selectedPriority = _currentTask.prioridade;
                          _selectedDate = _currentTask.dataPrazo;
                        });
                      },
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: _isSavingEdit ? null : () => _saveEditedTask(),
                      child:
                          _isSavingEdit
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text('Salvar'),
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

  TextStyle _getTextStyle(TaskDisplaySize size) {
    switch (size) {
      case TaskDisplaySize.small:
        return Theme.of(context).textTheme.bodySmall!;
      case TaskDisplaySize.medium:
        return Theme.of(context).textTheme.bodyMedium!;
      case TaskDisplaySize.large:
        return Theme.of(context).textTheme.bodyLarge!;
    }
  }

  // ... (métodos _deleteTask, _updateTaskStatus, _saveEditedTask)

  Future<void> _deleteTask(int taskId) async {
    setState(() {
      _isDeleting = true;
    });
    try {
      final response = await http.delete(
        Uri.parse("https://megajr-back-end.onrender.com/api/tasks/$taskId"),
        headers: {'Authorization': 'Bearer ${widget.firebaseIdToken}'},
      );
      if (response.statusCode == 200) {
        widget.onTaskDeleted(taskId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarefa deletada com sucesso!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao deletar tarefa: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão ao deletar tarefa: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _updateTaskStatus(bool isCompleted) async {
    setState(() {
      _isUpdatingStatus = true;
    });

    final newStatus = isCompleted ? TaskStatus.Finalizada : TaskStatus.Pendente;
    final updatedTask = _currentTask.copyWith(estadoTarefa: newStatus);

    try {
      final response = await http.put(
        Uri.parse(
          "https://megajr-back-end.onrender.com/api/tasks/${updatedTask.idTarefa}/status",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.firebaseIdToken}',
        },
        body: json.encode({
          'estado_tarefa': newStatus.toString().split('.').last,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _currentTask = updatedTask;
        });
        widget.onTaskUpdated(_currentTask); // Notifica o dashboard
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tarefa ${isCompleted ? 'finalizada' : 'reaberta'}!',
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar status: ${response.body}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão ao atualizar status: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _saveEditedTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O título da tarefa não pode ser vazio.')),
      );
      return;
    }

    setState(() {
      _isSavingEdit = true;
    });

    final updatedTask = _currentTask.copyWith(
      titulo: _titleController.text,
      descricao:
          _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
      dataPrazo: _selectedDate,
      prioridade: _selectedPriority,
    );

    try {
      final response = await http.put(
        Uri.parse(
          "https://megajr-back-end.onrender.com/api/tasks/${updatedTask.idTarefa}",
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.firebaseIdToken}',
        },
        body: json.encode(updatedTask.toJson()),
      );

      if (response.statusCode == 200) {
        setState(() {
          _currentTask = updatedTask;
          _isEditing = false;
        });
        widget.onTaskUpdated(_currentTask);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarefa atualizada com sucesso!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar tarefa: ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão ao salvar tarefa: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingEdit = false;
        });
      }
    }
  }
}
