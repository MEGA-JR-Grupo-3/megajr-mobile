// widgets/search_input.dart
import 'package:flutter/material.dart';
// import '../models/task_model.dart'; // If client-side filtering was intended

class SearchInputWidget extends StatefulWidget {
  final Function(String) onSearch;
  final TextEditingController controller;
  // final List<Task> tarefas; // For client-side filtering, if needed

  const SearchInputWidget({
    super.key,
    required this.onSearch,
    required this.controller,
    // required this.tarefas,
  });

  @override
  State<SearchInputWidget> createState() => _SearchInputWidgetState();
}

class _SearchInputWidgetState extends State<SearchInputWidget> {
  // TextEditingController _searchController = TextEditingController(); // Use passed controller

  @override
  void initState() {
    super.initState();
    // Listen to changes in the text field for real-time search (optional)
    // widget.controller.addListener(() {
    //   widget.onSearch(widget.controller.text);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: 'Pesquisar JubiTasks...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onSearch(''); // Trigger search with empty term to show all
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200], // Adjust color to match your theme
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        ),
        onChanged: (value) {
           // For real-time search as user types
           // widget.onSearch(value);
           // Or, if you want search on submit/button press, remove this and use onSubmitted
        },
        onSubmitted: (value) {
          // Trigger search when user submits (e.g., presses enter)
          widget.onSearch(value);
        },
      ),
    );
  }

  // @override
  // void dispose() {
  //   // widget.controller.dispose(); // Controller is managed by the parent (DashboardScreen)
  //   super.dispose();
  // }
}