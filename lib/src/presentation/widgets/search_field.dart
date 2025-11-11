import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';

/// Lightweight search field broadcasting queries through a [ValueNotifier].
class SearchField extends StatefulWidget {
  const SearchField({required this.queryListenable, super.key});

  final ValueNotifier<String> queryListenable;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.queryListenable.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.queryListenable,
      builder: (context, value, _) {
        return TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: AppStrings.searchHint,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      widget.queryListenable.value = '';
                    },
                  ),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (query) => widget.queryListenable.value = query,
          textInputAction: TextInputAction.search,
        );
      },
    );
  }
}
