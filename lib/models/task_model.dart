// models/task_model.dart
class Task {
  final String idTarefa; // Corresponds to id_tarefa
  String titulo;
  String descricao;
  String dataConclusao; // Assuming this is a String like "YYYY-MM-DD"
  String prioridade; // e.g., "Alta", "Média", "Baixa"
  String status; // e.g., "Pendente", "Em Progresso", "Concluída"
  int? order; // For drag and drop ordering

  Task({
    required this.idTarefa,
    required this.titulo,
    required this.descricao,
    required this.dataConclusao,
    required this.prioridade,
    required this.status,
    this.order,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      idTarefa: json['id_tarefa'] as String,
      titulo: json['titulo'] as String? ?? 'Sem título',
      descricao: json['descricao'] as String? ?? 'Sem descrição',
      dataConclusao: json['data_conclusao'] as String? ?? '', // Handle potential null
      prioridade: json['prioridade'] as String? ?? 'Normal', // Handle potential null
      status: json['status'] as String? ?? 'Pendente', // Handle potential null
      order: json['order'] as int?, // Assuming order might come from backend
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_tarefa': idTarefa,
      'titulo': titulo,
      'descricao': descricao,
      'data_conclusao': dataConclusao,
      'prioridade': prioridade,
      'status': status,
      'order': order,
    };
  }

  // Helper to create a copy with new values, useful for updates
  Task copyWith({
    String? idTarefa,
    String? titulo,
    String? descricao,
    String? dataConclusao,
    String? prioridade,
    String? status,
    int? order,
  }) {
    return Task(
      idTarefa: idTarefa ?? this.idTarefa,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataConclusao: dataConclusao ?? this.dataConclusao,
      prioridade: prioridade ?? this.prioridade,
      status: status ?? this.status,
      order: order ?? this.order,
    );
  }
}
