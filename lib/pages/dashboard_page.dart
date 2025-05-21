import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import 'models/task_model.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'widgets/task_card.dart';
import 'widgets/add_task_form.dart';
import 'widgets/sidebar_drawer.dart';
import 'widgets/search_input.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  User? _currentUser;
  bool _isLoadingPage = true; // For initial page load
  bool _isLoadingTasks = false;
  String _registeredName = "";
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  String? _errorMessage; // For modal error messages
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.getCurrentUser();
    if (_currentUser == null) {
      // This should ideally be handled by the StreamBuilder in main.dart
      // but as a fallback:
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
    } else {
      _initializeDashboard();
    }
  }

  Future<void> _initializeDashboard() async {
    setState(() => _isLoadingPage = true);
    await _fetchUserData();
    await _fetchTasks();
    setState(() => _isLoadingPage = false);
  }

  Future<void> _fetchUserData() async {
    if (_currentUser?.email == null) return;
    try {
      final userData = await _apiService.fetchUserData(_currentUser!.email!);
      if (mounted) {
        setState(() {
          _registeredName = userData['name'] as String? ?? "";
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog("Erro ao buscar dados do usuário: $e");
      }
    }
  }

  Future<void> _fetchTasks() async {
    if (_currentUser?.email == null) return;
    if (mounted) setState(() => _isLoadingTasks = true);
    try {
      final tasks = await _apiService.fetchTasks(_currentUser!.email!);
      if (mounted) {
        setState(() {
          _allTasks = tasks;
          // Sort tasks by order if available, or by some default
          _allTasks.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
          _filteredTasks = List.from(_allTasks);
        });
      }
    } catch (e) {
      if (mounted) {
         _showErrorDialog("Erro ao buscar tarefas: $e");
        _filteredTasks = []; // Clear tasks on error
      }
    } finally {
      if (mounted) setState(() => _isLoadingTasks = false);
    }
  }

  void _handleSearch(String searchTerm) async {
    if (searchTerm.isEmpty) {
      if (mounted) {
        setState(() {
          _filteredTasks = List.from(_allTasks);
          _errorMessage = null; // Clear any previous search error
        });
      }
      return;
    }

    if (mounted) setState(() => _isLoadingTasks = true);
    try {
      // Pass current user's email if your backend search is user-specific
      final tasks = await _apiService.searchTasks(searchTerm, _currentUser!.email!);
      if (mounted) {
        setState(() {
          _filteredTasks = tasks;
          if (tasks.isEmpty) {
            _errorMessage = "Nenhuma task encontrada para sua busca.";
          } else {
            _errorMessage = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _filteredTasks = []; // Clear tasks on error
          _errorMessage = "Erro de conexão ao pesquisar.";
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingTasks = false);
    }
  }

  void _onTaskAdded(Task newTask) {
    // The AddTaskForm now returns the new task, or we can refetch
    // For simplicity, refetching ensures data consistency with backend
    _fetchTasks();
    // Or, add locally for quicker UI update and then sync:
    // if (mounted) {
    //   setState(() {
    //     _allTasks.add(newTask);
    //     _filteredTasks = List.from(_allTasks); // or apply current filter
    //   });
    // }
  }

  void _onTaskDeleted(String deletedTaskId) async {
    try {
      await _apiService.deleteTask(deletedTaskId);
      if (mounted) {
        setState(() {
          _allTasks.removeWhere((task) => task.idTarefa == deletedTaskId);
          _filteredTasks.removeWhere((task) => task.idTarefa == deletedTaskId);
        });
      }
    } catch (e) {
       if (mounted) _showErrorDialog("Erro ao deletar tarefa: $e");
    }
  }

  void _onTaskUpdated(Task updatedTask) async {
    // For simplicity, refetching. Or update locally:
    _fetchTasks();
    // if (mounted) {
    //   setState(() {
    //     _allTasks = _allTasks.map((task) =>
    //       task.idTarefa == updatedTask.idTarefa ? updatedTask : task).toList();
    //     _filteredTasks = _filteredTasks.map((task) =>
    //       task.idTarefa == updatedTask.idTarefa ? updatedTask : task).toList();
    //   });
    // }
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (mounted) {
      setState(() {
        final Task item = _filteredTasks.removeAt(oldIndex);
        _filteredTasks.insert(newIndex, item);

        // Update order property for all tasks in _filteredTasks
        for (int i = 0; i < _filteredTasks.length; i++) {
          _filteredTasks[i].order = i;
        }
        // Also update _allTasks if necessary, or handle merging logic
        // This example focuses on the displayed list.
      });
      // Persist the new order to the backend
      if (_currentUser?.email != null) {
        _apiService.updateTaskOrder(_filteredTasks, _currentUser!.email!)
          .catchError((e) => _showErrorDialog("Erro ao salvar nova ordem: $e"));
      }
    }
  }

  void _showAddTaskForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTaskFormWidget(
          onTaskAdded: (newTask) { // Expecting the form to return the newly created task
            _onTaskAdded(newTask);
          },
          userEmail: _currentUser!.email!, // Pass userEmail to the form
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    // If there's already an error dialog, don't show another one
    // This simple check might need refinement for complex scenarios
    if (ModalRoute.of(context)?.isCurrent != true) {
        // If a dialog is already open, perhaps log or use a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent)
        );
        return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Erro", style: TextStyle(color: Colors.redAccent)),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
                if (mounted) {
                    setState(() {
                        _errorMessage = null; // Clear the page-level error message if any
                    });
                }
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoadingPage) {
      return const Scaffold(
        body: Center(
          child: SpinKitFadingCircle(color: Colors.blue, size: 50.0),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 1;
    if (screenWidth > 1024) { // lg
      crossAxisCount = 3;
    } else if (screenWidth > 640) { // sm
      crossAxisCount = 2;
    }
    double childAspectRatio = screenWidth / (crossAxisCount * 350); // Adjust 350 based on desired card height


    return Scaffold(
      // Using a GlobalKey for the Scaffold to open the drawer programmatically
      key: _scaffoldKey,
      appBar: AppBar(
        // Show menu icon to open drawer only on smaller screens
        leading: (screenWidth < 1024) // 'lg' breakpoint in Tailwind
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              )
            : null, // No leading icon on larger screens if sidebar is always visible or different trigger
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (screenWidth < 1024) // lg:hidden
              Image.asset('assets/splash-pato.png', height: 30, fit: BoxFit.contain),
            if (screenWidth < 1024) // lg:hidden
              const SizedBox(width: 8),
            if (screenWidth < 1024) // lg:hidden
              Expanded(
                child: Text(
                  'Olá, ${_registeredName.isNotEmpty ? _registeredName : _currentUser?.displayName ?? "parceiro(a)!"}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        // On larger screens, the title might be different or not needed if sidebar is persistent
        centerTitle: (screenWidth < 1024) ? false : true, // Adjust as per your design
        actions: [
          // If sidebar is not persistent on large screens, add a button for it here too
          // or handle it differently.
           if (screenWidth >= 1024)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                 'Olá, ${_registeredName.isNotEmpty ? _registeredName : _currentUser?.displayName ?? "parceiro(a)!"}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            if (screenWidth >= 1024)
             IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await _authService.signOut();
                  if (mounted) Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
        ],
      ),
      // Sidebar (Drawer)
      drawer: (screenWidth < 1024) ? SidebarDrawer(
        userName: _registeredName.isNotEmpty ? _registeredName : _currentUser?.displayName ?? "Usuário",
        userEmail: _currentUser?.email ?? "Não logado",
        onLogout: () async {
          Navigator.of(context).pop(); // Close drawer first
          await _authService.signOut();
          if (mounted) Navigator.of(context).pushReplacementNamed('/login');
        },
      ) : null, // No drawer if sidebar is part of the main layout on large screens

      body: Row(
        children: [
          // Persistent Sidebar for large screens
          if (screenWidth >= 1024) // 'lg' breakpoint
            SidebarDrawer(
              userName: _registeredName.isNotEmpty ? _registeredName : _currentUser?.displayName ?? "Usuário",
              userEmail: _currentUser?.email ?? "Não logado",
              onLogout: () async {
                await _authService.signOut();
                if (mounted) Navigator.of(context).pushReplacementNamed('/login');
              },
            ),

          // Main content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0), // p-2
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SearchInputWidget(
                    controller: _searchController,
                    onSearch: _handleSearch,
                    // tarefas: _allTasks, // Pass all tasks if client-side filtering is needed
                  ),
                  const SizedBox(height: 20), // pt-[30px] approx
                  Text(
                    "Suas JubiTasks",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 15), // mt-[30px] approx
                  if (_isLoadingTasks)
                    const Expanded(
                      child: Center(
                        child: SpinKitFadingCircle(color: Colors.grey, size: 40.0),
                      ),
                    )
                  else if (_errorMessage != null && _filteredTasks.isEmpty)
                     Expanded(
                        child: Center(
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Text(
                                _errorMessage!,
                                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                                textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                onPressed: () {
                                    _searchController.clear();
                                    _handleSearch(""); // Clear search and fetch all
                                },
                                child: const Text("Limpar Busca"),
                                )
                            ],
                            ),
                        ),
                        ),
                    )
                  else if (_filteredTasks.isEmpty)
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0), // For overall padding
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Bora organizar sua vida!",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 30), // gap-14 approx
                              Image.asset(
                                'assets/pato-triste.png',
                                width: 180, // Adjusted from 250 for typical mobile view
                                height: 180,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ReorderableGridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 15.0), // px-4 mt-[30px]
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio, // Adjust for card aspect ratio
                          crossAxisSpacing: 16, // gap-4
                          mainAxisSpacing: 16,  // gap-4
                        ),
                        itemCount: _filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = _filteredTasks[index];
                          return TaskCardWidget(
                            key: ValueKey(task.idTarefa), // Important for reordering
                            task: task,
                            onTaskDeleted: () => _onTaskDeleted(task.idTarefa),
                            onTaskUpdated: (updatedTask) => _onTaskUpdated(updatedTask),
                            // isDraggable is inherent with ReorderableGridView
                          );
                        },
                        onReorder: _onReorder,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskForm,
        backgroundColor: Colors.deepPurpleAccent, // Example color
        tooltip: 'Adicionar Tarefa',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // For opening drawer

  @override
  void dispose() {
    _searchController.dispose();
    // Dispose other controllers if any
    super.dispose();
  }
}