import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile_megajr_grupo3/models/task.dart';
import 'package:mobile_megajr_grupo3/widgets/add_task_form.dart';
import 'package:mobile_megajr_grupo3/widgets/task_card.dart';
import 'package:mobile_megajr_grupo3/widgets/custom_button.dart';
import 'package:mobile_megajr_grupo3/providers/auth_provider.dart';
import 'package:mobile_megajr_grupo3/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoadingTasks = false;
  bool _showFilterOptions = false;
  bool _showAddTaskForm = false;
  String _selectedFilter = 'all'; // 'all', 'pending', 'completed'
  String _sortBy = 'date'; // 'date', 'priority', 'title', 'description'
  String _sortOrder = 'asc'; // 'asc', 'desc'
  TaskDisplaySize _taskDisplaySize =
      TaskDisplaySize
          .medium; // <-- Este TaskDisplaySize agora vem de models/task.dart
  int _completedTasksCount = 0;
  String _currentSearchTerm = ''; // Adicionado para a busca

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Chave para controlar o Scaffold/Drawer

  final String _backendUrl =
      "https://megajr-back-end.onrender.com/api"; // Corrigi a string do URL

  final Map<TaskPriority, int> _priorityOrder = {
    TaskPriority.Urgente: 1,
    TaskPriority.Alta: 2,
    TaskPriority.Normal: 3,
    TaskPriority.Baixa: 4,
  };

  @override
  void initState() {
    super.initState();
    _loadTaskDisplaySize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated &&
          authProvider.firebaseIdToken != null) {
        _loadTasks();
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  // Função para carregar o tamanho de exibição das tarefas
  Future<void> _loadTaskDisplaySize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSize = prefs.getString('taskDisplaySize');
    if (savedSize != null) {
      setState(() {
        _taskDisplaySize = TaskDisplaySize.values.firstWhere(
          (e) => e.toString().split('.').last == savedSize,
          orElse: () => TaskDisplaySize.medium,
        );
      });
    }
  }

  // Função para salvar o tamanho de exibição das tarefas
  Future<void> _saveTaskDisplaySize(TaskDisplaySize size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('taskDisplaySize', size.toString().split('.').last);
  }

  // Função para carregar as tarefas do backend
  Future<void> _loadTasks() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final firebaseIdToken = authProvider.firebaseIdToken;

    if (firebaseIdToken == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Erro: Token de autenticação não disponível. Redirecionando...",
            ),
          ),
        );
        // O AuthProvider já lida com o redirecionamento
        //Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingTasks = true;
      });
    }

    try {
      final response = await http.get(
        Uri.parse("$_backendUrl/tasks"),
        headers: {'Authorization': 'Bearer $firebaseIdToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _allTasks = data.map((json) => Task.fromJson(json)).toList();
            _completedTasksCount =
                _allTasks
                    .where((task) => task.estadoTarefa == TaskStatus.Finalizada)
                    .length;
          });
          _applyFiltersAndSort(); // Aplica filtros e ordenação após carregar
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sessão expirada. Faça login novamente."),
            ),
          );
        }
        // O AuthProvider já desloga e redireciona automaticamente
        await authProvider.signOut();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erro ao carregar tarefas: ${response.statusCode} - ${response.reasonPhrase}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão ao carregar tarefas: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTasks = false;
        });
      }
    }
  }

  // Função para aplicar filtros e ordenação às tarefas
  void _applyFiltersAndSort() {
    setState(() {
      List<Task> tempTasks = List.from(_allTasks);

      // 1. Filtrar pelo termo de busca
      if (_currentSearchTerm.isNotEmpty) {
        final lowerCaseSearchTerm = _currentSearchTerm.toLowerCase();
        tempTasks =
            tempTasks.where((task) {
              return task.titulo.toLowerCase().contains(lowerCaseSearchTerm) ||
                  (task.descricao?.toLowerCase() ?? '').contains(
                    lowerCaseSearchTerm,
                  );
            }).toList();
      }

      // 2. Filtrar por status
      tempTasks =
          tempTasks.where((task) {
            if (_selectedFilter == 'pending') {
              return task.estadoTarefa == TaskStatus.Pendente;
            } else if (_selectedFilter == 'completed') {
              return task.estadoTarefa == TaskStatus.Finalizada;
            }
            return true; // 'all'
          }).toList();

      // Separar tarefas pendentes e finalizadas para ordenação específica
      List<Task> pendingTasks =
          tempTasks
              .where((task) => task.estadoTarefa == TaskStatus.Pendente)
              .toList();
      List<Task> completedTasks =
          tempTasks
              .where((task) => task.estadoTarefa == TaskStatus.Finalizada)
              .toList();

      // 3. Ordenar tarefas pendentes
      pendingTasks.sort((a, b) {
        int compareResult = 0;

        switch (_sortBy) {
          case 'priority':
            final aPriority = _priorityOrder[a.prioridade] ?? 99;
            final bPriority = _priorityOrder[b.prioridade] ?? 99;
            compareResult = aPriority.compareTo(bPriority);
            break;
          case 'date':
            if (a.dataPrazo == null && b.dataPrazo == null) {
              compareResult = 0;
            } else if (a.dataPrazo == null) {
              compareResult = 1;
            } else if (b.dataPrazo == null) {
              compareResult = -1;
            } else {
              compareResult = a.dataPrazo!.compareTo(b.dataPrazo!);
            }
            break;
          case 'title':
            compareResult = a.titulo.toLowerCase().compareTo(
              b.titulo.toLowerCase(),
            );
            break;
          case 'description':
            final aDesc = a.descricao?.toLowerCase() ?? '';
            final bDesc = b.descricao?.toLowerCase() ?? '';
            compareResult = aDesc.compareTo(bDesc);
            break;
          default:
            // Fallback para ordenação padrão por prioridade e depois data se _sortBy for 'all' ou não reconhecido
            final aPriority = _priorityOrder[a.prioridade] ?? 99;
            final bPriority = _priorityOrder[b.prioridade] ?? 99;
            compareResult = aPriority.compareTo(bPriority);
            if (compareResult == 0) {
              if (a.dataPrazo == null && b.dataPrazo == null) {
                compareResult = 0;
              } else if (a.dataPrazo == null) {
                compareResult = 1;
              } else if (b.dataPrazo == null) {
                compareResult = -1;
              } else {
                compareResult = a.dataPrazo!.compareTo(b.dataPrazo!);
              }
            }
            break;
        }

        return _sortOrder == 'asc' ? compareResult : -compareResult;
      });

      // Tarefas finalizadas não são reordenáveis e podem ter uma ordem padrão (ex: por data de conclusão, ou simplesmente após as pendentes)
      // Por simplicidade, as mantemos na ordem em que aparecem no array após a filtragem de status
      completedTasks.sort((a, b) {
        if (a.dataPrazo == null && b.dataPrazo == null) return 0;
        if (a.dataPrazo == null) return 1;
        if (b.dataPrazo == null) return -1;
        return b.dataPrazo!.compareTo(a.dataPrazo!);
      });

      _filteredTasks = [...pendingTasks, ...completedTasks];
    });
  }

  // Handlers para eventos
  void _handleTaskAdded(Task newTask) {
    setState(() {
      _allTasks.add(newTask);
      _applyFiltersAndSort(); // Reaplicar filtros para incluir a nova tarefa
      _showAddTaskForm = false; // Fechar o formulário
    });
    _loadTasks(); // Recarregar para garantir sincronia e ordem do backend
  }

  void _handleTaskDeleted(String taskId) {
    setState(() {
      _allTasks.removeWhere((task) => task.idTarefa == taskId);
      _applyFiltersAndSort(); // Reaplicar filtros
    });
    _loadTasks(); // Recarregar para garantir sincronia
  }

  void _handleTaskUpdated(Task updatedTask) {
    setState(() {
      _allTasks =
          _allTasks.map((task) {
            return task.idTarefa == updatedTask.idTarefa ? updatedTask : task;
          }).toList();
      _applyFiltersAndSort(); // Reaplicar filtros
    });
    _loadTasks(); // Recarregar para garantir sincronia (especialmente se o status mudou)
  }

  void _handleDeleteAllCompleted() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final firebaseIdToken = authProvider.firebaseIdToken;

    if (firebaseIdToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro: Token de autenticação não disponível."),
        ),
      );
      return;
    }

    // Mostrar modal de confirmação
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text(
            'Tem certeza que deseja deletar todas as tarefas concluídas?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Deletar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoadingTasks = true;
      });
      try {
        final response = await http.delete(
          Uri.parse("$_backendUrl/tasks/delete-completed"),
          headers: {'Authorization': 'Bearer $firebaseIdToken'},
        );

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Tarefas concluídas deletadas com sucesso!"),
              ),
            );
          }
          _loadTasks(); // Recarregar todas as tarefas
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Sessão expirada. Faça login novamente."),
              ),
            );
          }
          await authProvider.signOut();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Erro ao deletar tarefas concluídas: ${response.body}",
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Erro de conexão: $e")));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingTasks = false;
          });
        }
      }
    }
  }

  // --- Widgets e UI ---

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final registeredName = authProvider.registeredName;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Suas JubiTasks'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        // ... Conteúdo do Drawer ...
      ),
      // >>> AQUI É ONDE O FLOATINGACTIONBUTTON DEVE IR <<<
      floatingActionButton: FloatingActionButton(
        // <-- ADICIONE A PROPRIEDADE floatingActionButton AQUI
        onPressed: () {
          setState(() {
            _showAddTaskForm = true;
          });
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
      // >>> FIM DO FLOATINGACTIONBUTTON <<<
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _currentSearchTerm = value;
                    });
                    _applyFiltersAndSort();
                  },
                  decoration: InputDecoration(
                    labelText: 'Buscar Tarefas',
                    hintText: 'Pesquisar por título ou descrição...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton<String>(
                    itemBuilder:
                        (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'priority',
                            child: Text('Prioridade'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'date',
                            child: Text('Data'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'title',
                            child: Text('Título'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'description',
                            child: Text('Descrição'),
                          ),
                        ],
                    onSelected: (String value) {
                      setState(() {
                        _sortBy = value;
                        _sortOrder = 'asc';
                      });
                      _applyFiltersAndSort();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_list,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Filtrar por',
                            style: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_sortBy != 'date' || _sortOrder != 'asc')
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Chip(
                          label: Text(
                            'Filtrado por: ${getFilterLabel(_sortBy)} (${getSortOrderLabel(_sortOrder)})',
                            style: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onTertiaryContainer,
                            ),
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          onDeleted: () {
                            setState(() {
                              _sortBy = 'date';
                              _sortOrder = 'asc';
                            });
                            _applyFiltersAndSort();
                          },
                          deleteIconColor:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: 8),
                        // Botões para trocar a ordem (asc/desc)
                        CustomButton(
                          buttonText: 'Crescente',
                          onClick: () {
                            setState(() {
                              _sortOrder = 'asc';
                            });
                            _applyFiltersAndSort();
                          },
                          // Removido o parâmetro 'style' e usando as propriedades de cor existentes
                          primaryColor:
                              _sortOrder == 'asc'
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          secondaryColor:
                              _sortOrder == 'asc'
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        CustomButton(
                          buttonText: 'Decrescente',
                          onClick: () {
                            setState(() {
                              _sortOrder = 'desc';
                            });
                            _applyFiltersAndSort();
                          },
                          // Removido o parâmetro 'style' e usando as propriedades de cor existentes
                          primaryColor:
                              _sortOrder == 'desc'
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          secondaryColor:
                              _sortOrder == 'desc'
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.7),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                if (_completedTasksCount > 0)
                  Align(
                    alignment: Alignment.centerRight,
                    child: CustomButton(
                      buttonText: 'Deletar Concluídas ($_completedTasksCount)',
                      onClick: _handleDeleteAllCompleted,
                      // Removido o parâmetro 'buttonStyle' e usando as propriedades de cor existentes
                      primaryColor: Theme.of(context).colorScheme.error,
                      secondaryColor: Theme.of(
                        context,
                      ).colorScheme.error.withOpacity(0.7),
                    ),
                  ),
                const SizedBox(height: 16),

                _isLoadingTasks
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredTasks.isEmpty &&
                        !_isLoadingTasks &&
                        _currentSearchTerm.isEmpty
                    ? const Center(
                      child: Text(
                        'Nenhuma tarefa encontrada. Crie sua primeira tarefa!',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = _filteredTasks[index];
                        return TaskCard(
                          tarefa: task,
                          onTaskDeleted: (taskId) {
                            _handleTaskDeleted(
                              taskId.toString(),
                            ); // Corrigido novamente aqui, se necessário
                          },
                          onTaskUpdated: (updatedTask) {
                            _handleTaskUpdated(updatedTask);
                          },
                          firebaseIdToken: authProvider.firebaseIdToken!,
                          taskDisplaySize: _taskDisplaySize,
                          getDueDateStatus: getDueDateStatus,
                          getPriorityColor: getPriorityColor,
                        );
                      },
                    ),
              ],
            ),
          ),
          if (_showAddTaskForm)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showAddTaskForm = false;
                  });
                },
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: AddTaskForm(
                      onCancel: () {
                        setState(() {
                          _showAddTaskForm = false;
                        });
                      },
                      onTaskAdded: _handleTaskAdded,
                      firebaseIdToken: authProvider.firebaseIdToken ?? '',
                    ),
                  ),
                ),
              ),
            ),
        ], // Fechamento da lista de children do Stack
      ),
    );
  }

  String getFilterLabel(String sortBy) {
    switch (sortBy) {
      case 'priority':
        return 'Prioridade';
      case 'date':
        return 'Data';
      case 'title':
        return 'Título';
      case 'description':
        return 'Descrição';
      default:
        return 'Padrão';
    }
  }

  String getSortOrderLabel(String sortOrder) {
    return sortOrder == 'asc' ? 'Crescente' : 'Decrescente';
  }

  int _getCrossAxisCount(TaskDisplaySize size) {
    switch (size) {
      case TaskDisplaySize.small:
        return 3;
      case TaskDisplaySize.medium:
        return 2;
      case TaskDisplaySize.large:
        return 1;
      default:
        return 2;
    }
  }

  double _getCardAspectRatio(TaskDisplaySize size) {
    switch (size) {
      case TaskDisplaySize.small:
        return 0.8;
      case TaskDisplaySize.medium:
        return 1.0;
      case TaskDisplaySize.large:
        return 2.0;
      default:
        return 1.0;
    }
  }
}
