// lib/models/task.dart
import 'package:flutter/material.dart'; // Importe para Color
import 'package:intl/intl.dart';

enum TaskPriority { Baixa, Normal, Alta, Urgente }

enum TaskStatus { Pendente, Finalizada }

// Adicione TaskDisplaySize aqui se ainda não estiver
enum TaskDisplaySize { small, medium, large } // Este enum deve estar aqui!

class DueDateInfo {
  final String text;
  final Color color;

  DueDateInfo({required this.text, required this.color});
}

DueDateInfo getDueDateStatus(DateTime? dueDate, BuildContext context) {
  if (dueDate == null) {
    return DueDateInfo(text: "Indefinido", color: Colors.grey);
  }

  final today = DateTime.now();
  final taskDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
  final diff = taskDueDate.difference(
    DateTime(today.year, today.month, today.day),
  );

  final DateFormat formatter = DateFormat('dd/MM/yyyy');

  if (diff.inDays < 0) {
    return DueDateInfo(
      text: "Atrasado (${formatter.format(dueDate)})",
      color: Theme.of(context).colorScheme.error, // Usar tema para consistência
    );
  }
  if (diff.inDays <= 3) {
    return DueDateInfo(
      text: "Próxima (${formatter.format(dueDate)})",
      color:
          Theme.of(context).colorScheme.tertiary, // Usar tema para consistência
    );
  }
  return DueDateInfo(
    text: "Prazo: ${formatter.format(dueDate)}",
    color: Theme.of(context).colorScheme.primary, // Usar tema para consistência
  );
}

Color getPriorityColor(TaskPriority priority, BuildContext context) {
  switch (priority) {
    case TaskPriority.Urgente:
      return Theme.of(context).colorScheme.error;
    case TaskPriority.Alta:
      return Theme.of(context).colorScheme.tertiary;
    case TaskPriority.Normal:
      return Theme.of(context).colorScheme.secondary;
    case TaskPriority.Baixa:
      return Theme.of(context).colorScheme.primary;
    default:
      return Theme.of(context).colorScheme.onSurfaceVariant;
  }
}

class Task {
  final int idTarefa;
  String titulo;
  String? descricao;
  DateTime? dataPrazo;
  TaskPriority prioridade;
  TaskStatus estadoTarefa;
  int? ordem; // Certifique-se que este campo está no backend se for usado

  Task({
    required this.idTarefa,
    required this.titulo,
    this.descricao,
    this.dataPrazo,
    required this.prioridade,
    required this.estadoTarefa,
    this.ordem,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      idTarefa: json['id_tarefa'] as int ?? 0,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
      dataPrazo:
          json['data_prazo'] != null
              ? DateTime.parse(json['data_prazo'] as String)
              : null,
      prioridade: TaskPriority.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            json['prioridade'].toLowerCase(),
        orElse: () => TaskPriority.Normal,
      ),
      estadoTarefa: TaskStatus.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            json['estado_tarefa'].toLowerCase(),
        orElse: () => TaskStatus.Pendente,
      ),
      ordem:
          json['ordem']
              as int?, // Certifique-se que o backend retorna 'ordem' se você usar
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_tarefa': idTarefa,
      'titulo': titulo,
      'descricao': descricao,
      'data_prazo': dataPrazo?.toIso8601String().split('T').first,
      'prioridade': prioridade.toString().split('.').last,
      'estado_tarefa': estadoTarefa.toString().split('.').last,
      'ordem': ordem,
    };
  }

  Task copyWith({
    int? idTarefa,
    String? titulo,
    String? descricao,
    DateTime? dataPrazo,
    TaskPriority? prioridade,
    TaskStatus? estadoTarefa,
    int? ordem,
  }) {
    return Task(
      idTarefa: idTarefa ?? this.idTarefa,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataPrazo: dataPrazo ?? this.dataPrazo,
      prioridade: prioridade ?? this.prioridade,
      estadoTarefa: estadoTarefa ?? this.estadoTarefa,
      ordem: ordem ?? this.ordem,
    );
  }
}
