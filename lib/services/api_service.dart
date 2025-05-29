// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart'; // Adjust path as needed

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // NOVO MÉTODO GENÉRICO PARA POST
  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body, // Pode ser Map<String, dynamic> ou outro objeto serializável
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          ...?headers, // Adiciona os headers passados, sobrescrevendo se houver conflito
        },
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      print('Error on POST request to $endpoint: $e');
      rethrow; // Lança o erro para ser tratado pelo chamador
    }
  }

  // NOVO MÉTODO GENÉRICO PARA GET (você pode precisar deste no futuro)
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    Uri url;
    if (queryParameters != null && queryParameters.isNotEmpty) {
      url = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParameters);
    } else {
      url = Uri.parse('$baseUrl$endpoint');
    }

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json', ...?headers},
      );
      return response;
    } catch (e) {
      print('Error on GET request to $endpoint: $e');
      rethrow;
    }
  }

  // Fetch all tasks for a user
  Future<List<Task>> fetchTasks({required String firebaseIdToken}) async {
    // A URL base já é fornecida no construtor
    final url = Uri.parse('$baseUrl/tasks'); // Exemplo de endpoint

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $firebaseIdToken', // Use o token para autenticação
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((taskJson) => Task.fromJson(taskJson)).toList();
      } else {
        print('Error fetching tasks: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      print('Error communicating with backend (fetchTasks): $e');
      rethrow;
    }
  }

  // Exemplo de como fetchUserData poderia usar o novo método `post`:
  Future<Map<String, dynamic>> fetchUserData(String userEmail) async {
    try {
      final response = await post(
        '/user-data', // Endpoint
        headers: {'Content-Type': 'application/json'},
        body: {'email': userEmail},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print(
          'Error fetching user data: ${response.statusCode} ${response.body}',
        );
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error communicating with backend (fetchUserData): $e');
      throw Exception('Failed to communicate with backend: $e');
    }
  }

  // Search tasks
  Future<List<Task>> searchTasks(
    String searchTerm,
    String firebaseIdToken,
  ) async {
    // Ajuste o endpoint se ele precisar de email ou outros parâmetros
    // Considerando que a autenticação é via token, userEmail pode não ser mais necessário
    final url = Uri.parse('$baseUrl/tasks/search?query=$searchTerm');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $firebaseIdToken', // Use o token
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((taskJson) => Task.fromJson(taskJson)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        print('Error searching tasks: ${response.statusCode} ${response.body}');
        throw Exception('Failed to search tasks');
      }
    } catch (e) {
      print('Error communicating with backend (searchTasks): $e');
      throw Exception('Failed to communicate with backend: $e');
    }
  }

  // Add a new task
  Future<Task?> addTask(
    Map<String, dynamic> taskData,
    String firebaseIdToken,
  ) async {
    try {
      final response = await post(
        // Usando o novo método genérico 'post'
        '/tasks/add',
        headers: {'Authorization': 'Bearer $firebaseIdToken'},
        body: taskData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Task.fromJson(jsonDecode(response.body));
      } else {
        print('Error adding task: ${response.statusCode} ${response.body}');
        throw Exception('Failed to add task');
      }
    } catch (e) {
      print('Error communicating with backend (addTask): $e');
      throw Exception('Failed to communicate with backend: $e');
    }
  }

  // Update an existing task
  Future<Task?> updateTask(
    String taskId,
    Map<String, dynamic> taskUpdateData,
    String firebaseIdToken,
  ) async {
    final url = Uri.parse('$baseUrl/tasks/$taskId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $firebaseIdToken', // Use o token
        },
        body: jsonEncode(taskUpdateData),
      );

      if (response.statusCode == 200) {
        return Task.fromJson(jsonDecode(response.body));
      } else {
        print('Error updating task: ${response.statusCode} ${response.body}');
        throw Exception('Failed to update task');
      }
    } catch (e) {
      print('Error communicating with backend (updateTask): $e');
      throw Exception('Failed to communicate with backend: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId, String firebaseIdToken) async {
    final url = Uri.parse('$baseUrl/tasks/$taskId');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $firebaseIdToken', // Use o token
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        print('Error deleting task: ${response.statusCode} ${response.body}');
        throw Exception('Failed to delete task');
      }
    } catch (e) {
      print('Error communicating with backend (deleteTask): $e');
      throw Exception('Failed to communicate with backend: $e');
    }
  }

  // Update task order (if your backend supports this)
  Future<void> updateTaskOrder(
    List<Task> orderedTasks,
    String firebaseIdToken,
  ) async {
    List<Map<String, dynamic>> tasksWithOrder =
        orderedTasks.asMap().entries.map((entry) {
          return {
            'id_tarefa': entry.value.idTarefa,
            'order': entry.key,
            // include other necessary fields if your backend requires them
          };
        }).toList();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks/reorder'), // Example endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $firebaseIdToken', // Use o token
        },
        body: jsonEncode({'orderedTasks': tasksWithOrder}), // Removido 'email'
      );

      if (response.statusCode != 200) {
        print(
          'Error updating task order: ${response.statusCode} ${response.body}',
        );
        throw Exception('Failed to update task order');
      }
    } catch (e) {
      print('Error communicating with backend (updateTaskOrder): $e');
      throw Exception('Failed to communicate with backend: $e');
    }
  }

  // NOVO MÉTODO: Deletar todas as tarefas concluídas (AGORA DENTRO DA CLASSE)
  Future<void> deleteCompletedTasks(String firebaseIdToken) async {
    final url = Uri.parse(
      '$baseUrl/tasks/delete-completed',
    ); // Endpoint conforme seu backend web

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $firebaseIdToken', // Use o token para autenticação
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Tarefas concluídas deletadas com sucesso no backend!');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print(
          'Erro de autenticação/autorização ao deletar tarefas concluídas: ${response.statusCode} ${response.body}',
        );
        throw Exception(
          'Sessão expirada ou não autorizada ao deletar tarefas.',
        );
      } else {
        print(
          'Erro ao deletar tarefas concluídas: ${response.statusCode} ${response.body}',
        );
        throw Exception('Falha ao deletar tarefas concluídas no servidor.');
      }
    } catch (e) {
      print('Erro na requisição de exclusão de tarefas concluídas: $e');
      throw Exception(
        'Não foi possível conectar ao servidor para deletar tarefas concluídas: $e',
      );
    }
  }
}
