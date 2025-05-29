// lib/widgets/search_input.dart
import 'package:flutter/material.dart';
import 'dart:async';

class SearchInput extends StatefulWidget {
  final List<dynamic>? tarefas;
  final ValueChanged<String> onSearch;

  const SearchInput({super.key, this.tarefas, required this.onSearch});

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  // Implementação do debounce
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(_searchController.text);
    });
  }

  void _handleClearClick() {
    _searchController.clear();
    widget.onSearch('');
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color subbackgroundColor = Theme.of(context).colorScheme.surface;
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color hintColor = textColor.withValues(alpha: 0.6);

    return Container(
      width: 320,
      constraints: const BoxConstraints(maxWidth: 600),
      margin: const EdgeInsets.only(top: 20),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Pesquisar tarefas...",
              hintStyle: TextStyle(color: hintColor),
              filled: true,
              fillColor: subbackgroundColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(color: textColor.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(color: textColor.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2.0,
                ),
              ),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _searchController,
                builder: (context, value, child) {
                  if (value.text.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.grey.shade500,
                      hoverColor: Colors.grey.shade700,
                      onPressed: _handleClearClick,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
            ),
            style: TextStyle(color: textColor),
            cursorColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
