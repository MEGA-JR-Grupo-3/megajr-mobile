// widgets/add_task_form.dart
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';

class AddTaskFormWidget extends StatefulWidget {
  final Function(Task) onTaskAdded; // Callback after task is successfully added/updated
  final String userEmail; // Needed if your backend associates tasks with users on creation
  final Task? existingTask; // Optional: if provided, the form is for editing

  const AddTaskFormWidget({
    super.key,
    required this.onTaskAdded,
    required this.userEmail,
    this.existingTask,
  });

  @override
  State<AddTaskFormWidget> createState() => _AddTaskFormWidgetState();
}

class _AddTaskFormWidgetState extends State<AddTaskFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dueDateController;
  String _selectedPriority = 'Média'; // Default priority
  String _selectedStatus = 'Pendente'; // Default status

  bool _isLoading = false;

  final List<String> _priorities = ['Baixa', 'Média', 'Alta', 'Urgente'];
  final List<String> _statuses = ['Pendente', 'Em Progresso', 'Concluída'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingTask?.titulo ?? '');
    _descriptionController = TextEditingController(text: widget.existingTask?.descricao ?? '');
    _dueDateController = TextEditingController(text: widget.existingTask?.dataConclusao ?? '');
    _selectedPriority = widget.existingTask?.prioridade ?? 'Média';
    _selectedStatus = widget.existingTask?.status ?? 'Pendente';

     if (widget.existingTask == null && _dueDateController.text.isEmpty) {
      _dueDateController.text = DateTime.now().toIso8601String().substring(0, 10); // Default to today
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDateController.text.isNotEmpty
          ? (DateTime.tryParse(_dueDateController.text) ?? DateTime.now())
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked.toIso8601String().substring(0, 10) != _dueDateController.text) {
      setState(() {
        _dueDateController.text = picked.toIso8601String().substring(0, 10);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Map<String, dynamic> taskData = {
        'titulo': _titleController.text,
        'descricao': _descriptionController.text,
        'data_conclusao': _dueDateController.text,
        'prioridade': _selectedPriority,
        'status': _selectedStatus,
        // 'email': widget.userEmail, // Backend might require email
      };

      try {
        Task? resultTask;
        if (widget.existingTask != null) {
          // Update existing task
          resultTask = await _apiService.updateTask(widget.existingTask!.idTarefa, taskData);
        } else {
          // Add new task
          resultTask = await _apiService.addTask(taskData, widget.userEmail);
        }

        if (resultTask != null) {
          widget.onTaskAdded(resultTask); // Pass the created/updated task back
          if (mounted) Navigator.of(context).pop(); // Close dialog
        } else {
           if (mounted) _showErrorSnackbar("Falha ao ${widget.existingTask != null ? 'atualizar' : 'adicionar'} tarefa. Resposta nula do servidor.");
        }
      } catch (e) {
        if (mounted) _showErrorSnackbar("Erro ao ${widget.existingTask != null ? 'atualizar' : 'adicionar'} tarefa: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingTask != null ? 'Editar Tarefa' : 'Adicionar Nova Tarefa'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título da Tarefa'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição (Opcional)'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _dueDateController,
                decoration: InputDecoration(
                  labelText: 'Data de Conclusão (YYYY-MM-DD)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true, // Make it read-only if using date picker exclusively
                onTap: () => _selectDate(context),
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma data de conclusão';
                  }
                  // Basic date format validation (YYYY-MM-DD)
                  final RegExp dateRegExp = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  if (!dateRegExp.hasMatch(value)) {
                    return 'Formato de data inválido. Use YYYY-MM-DD';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                items: _priorities.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPriority = newValue!;
                  });
                },
              ),
              if (widget.existingTask != null) // Only show status for existing tasks, or define default for new
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: _statuses.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedStatus = newValue!;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(widget.existingTask != null ? 'Atualizar' : 'Adicionar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }
}