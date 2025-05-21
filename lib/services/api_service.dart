// services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart'; // Adjust path as needed

class ApiService {
  // IMPORTANT: Replace with your actual backend URL
  static const String _backendUrl = "YOUR_NEXT_PUBLIC_BACKEND_URL_HERE"; // e.g., "http://localhost:3001" or your deployed URL

  // Fetch all tasks for a user
  Future<List<Task>> fetchTasks(String userEmail) async {
    if (_backendUrl == "YOUR_NEXT_PUBLIC_BACKEND_URL_HERE") {
        print("ApiService: Backend URL is not configured.");
        // Return empty list or throw an error to indicate configuration issue
        return [];
    }
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': userEmail}),
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
      throw Exception('Failed to communicate with backend: $e');
    }
  }

  // Fetch user data (e.g., registered name)
  Future<Map<String, dynamic>> fetchUserData(String userEmail) async {
     if (_backendUrl == "YOUR_NEXT_PUBLIC_BACKEND_URL_HERE") {
        print("ApiService: Backend URL is not configured.");
        return {};
    }
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/user-data'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': userEmail}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Error fetching user data: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error communicating with backend (fetchUserData): $e');
      throw Exception('Failed to communicate with backend: $e');
    }
  }

  // Search tasks
  Future<List<Task>> searchTasks(String searchTerm, String userEmail) async {
     if (_backendUrl == "YOUR_NEXT_PUBLIC_BACKEND_URL_HERE") {
        print("ApiService: Backend URL is not configured.");
        return [];
    }
    // Assuming your backend search needs the user's email to scope the search
    // Adjust the endpoint if it's a general search or if email is passed differently
    try {
      final response = await http.get(
        // Example: Uri.parse('$_backendUrl/tasks/search?query=$searchTerm&email=$userEmail'),
        // Or if your backend doesn't need email for search and filters by auth:
        Uri.parse('$_backendUrl/tasks/search?query=$searchTerm'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((taskJson) => Task.fromJson(taskJson)).toList();
      } else if (response.statusCode == 404) { // Handle not found specifically
        return []; // No tasks found for the search term
      }
      else {
        print('Error searching tasks: ${response.statusCode} ${response.body}');
        throw Exception('Failed to search tasks');
      }
    } catch (e) {
      print('Error communicating with backend (searchTasks): $e');
      throw Exception('Failed to communicate with backend: $e');
    }
  }

  // Add a new task
  Future<Task?> addTask(Map<String, dynamic> taskData, String userEmail) async {
     if (_backendUrl == "YOUR_NEXT_PUBLIC_BACKEND_URL_HERE") {
        print("ApiService: Backend URL is not configured.");
        return null;
    }
    // Add userEmail to taskData if your backend expects it in the body for creation
    // taskData['email'] = userEmail; // Or however your backend associates tasks with users

    try {
      // Assuming your backend endpoint for adding tasks is /tasks and method is POST
      // And it returns the created task
      final response = await http.post(
        Uri.parse('$_backendUrl/tasks/add'), // Adjust endpoint as needed
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(taskData..addAll({'email': userEmail})), // Example: merge email
      );

      if (response.statusCode == 201 || response.statusCode == 200) { // 201 Created is common
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
  Future<Task?> updateTask(String taskId, Map<String, dynamic> taskUpdateData) async {
     if (_backendUrl == "YOUR_NEXT_PUBLIC_BACKEND_URL_HERE") {
        print("ApiService: Backend URL is not configured.");
        return null;
    }
    try {
      // Assuming endpoint like /tasks/:id and method PUT or PATCH
      final response = await http.put(
        Uri.parse('$_backendUrl/tasks/$taskId'), // Adjust endpoint as needed
        headers: {'Content-Type': 'application/json'},
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
  Future<void> deleteTask(String taskId) async {
     if (_backendUrl == "YOUR_NEXT_PUBLIC_BACKEND_URL_HERE") {
        print("ApiService: Backend URL is not configured.");
        return;
    }
    try {
      // Assuming endpoint like /tasks/:id and method DELETE
      final response = await http.delete(
        Uri.parse('$_backendUrl/tasks/$taskId'), // Adjust endpoint as needed
      );

      if (response.statusCode != 200 && response.statusCode != 204) { // 204 No Content is also common
        print('Error deleting task: ${response.statusCode} ${response.body}');
        throw Exception('Failed to delete task');
      }
      // No return needed for successful deletion typically
    } catch (e) {
      print('Error communicating with backend (deleteTask): $e');
      throw Exception('Failed to communicate with backend: $e');
    }
  }

  // Update task order (if your backend supports this)
  Future<void> updateTaskOrder(List<Task> orderedTasks, String userEmail) async {
     if (_backendUrl == "YOUR_NEXT_PUBLIC_BACKEND_URL_HERE") {
        print("ApiService: Backend URL is not configured.");
        return;
    }
    // This is a conceptual example. Your backend needs an endpoint to receive the new order.
    // It might expect a list of task IDs in order, or the full task objects.
    List<Map<String, dynamic>> tasksWithOrder = orderedTasks.asMap().entries.map((entry) {
      return {
        'id_tarefa': entry.value.idTarefa,
        'order': entry.key, // Using index as order
        // include other necessary fields if your backend requires them
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/tasks/reorder'), // Example endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': userEmail,
          'orderedTasks': tasksWithOrder,
        }),
      );

      if (response.statusCode != 200) {
        print('Error updating task order: ${response.statusCode} ${response.body}');
        throw Exception('Failed to update task order');
      }
    } catch (e) {
      print('Error communicating with backend (updateTaskOrder): $e');
      throw Exception('Failed to communicate with backend: $e');
    }
  }
}
