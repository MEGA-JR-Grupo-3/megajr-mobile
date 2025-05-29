import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class AddTaskForm extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(Task newTask) onTaskAdded;
  final String firebaseIdToken;

  const AddTaskForm({
    super.key,
    required this.onCancel,
    required this.onTaskAdded,
    required this.firebaseIdToken,
  });

  @override
  AddTaskFormState createState() => AddTaskFormState();
}

class AddTaskFormState extends State<AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  String _titulo = "";
  String _descricao = "";
  DateTime? _dataPrazo;
  String _prioridade = "Normal";

  final String _backendUrl = "https://megajr-back-end.onrender.com/api";

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataPrazo ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dataPrazo) {
      setState(() {
        _dataPrazo = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final String firebaseIdToken = widget.firebaseIdToken;

    if (firebaseIdToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Faça login para adicionar tarefas.")),
      );
      return;
    }

    final Map<String, dynamic> newTaskData = {
      "titulo": _titulo,
      "descricao": _descricao,
      "data_prazo": _dataPrazo?.toIso8601String().split('T').first,
      "prioridade": _prioridade,
      "estado_tarefa": "Pendente",
    };

    try {
      final response = await http.post(
        Uri.parse("$_backendUrl/tasks/add"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $firebaseIdToken",
        },
        body: jsonEncode(newTaskData),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final newTask = Task.fromJson(responseData);
        if (mounted) {
          widget.onTaskAdded(newTask);
          Navigator.of(context).pop();
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao adicionar tarefa: ${response.statusCode} - ${response.reasonPhrase}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão ao adicionar tarefa: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        width: 330,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Adicionar Nova Tarefa",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Título:",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, insira um título.";
                  }
                  return null;
                },
                onSaved: (value) {
                  _titulo = value!;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Descrição:",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) {
                  _descricao = value!;
                },
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: "Data Prazo:",
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text:
                          _dataPrazo == null
                              ? ""
                              : "${_dataPrazo!.day}/${_dataPrazo!.month}/${_dataPrazo!.year}",
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Prioridade:",
                  border: OutlineInputBorder(),
                ),
                value: _prioridade,
                items:
                    <String>[
                      "Baixa",
                      "Normal",
                      "Alta",
                      "Urgente",
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _prioridade = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, selecione uma prioridade.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text("Cancelar"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Salvar"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
