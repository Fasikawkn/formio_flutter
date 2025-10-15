/// A Flutter widget that renders a key-value input structure based on
/// a Form.io "datamap" component.
///
/// Allows users to add multiple dynamic key-value pairs. These pairs
/// are stored in a map and submitted as a nested object.

import 'package:flutter/material.dart';

import '../../models/component.dart';

class DataMapComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current key-value data stored as a Map<String, String>.
  final Map<String, String> value;

  /// Callback triggered when the map is updated.
  final ValueChanged<Map<String, String>> onChanged;

  const DataMapComponent(
      {Key? key,
      required this.component,
      required this.value,
      required this.onChanged})
      : super(key: key);

  @override
  State<DataMapComponent> createState() => _DataMapComponentState();
}

class _DataMapComponentState extends State<DataMapComponent> {
  late Map<String, String> _entries;
  final _newKeyController = TextEditingController();
  final _newValueController = TextEditingController();

  bool get _isRequired => widget.component.required;

  @override
  void initState() {
    super.initState();
    _entries = Map<String, String>.from(widget.value);
  }

  void _addEntry() {
    final key = _newKeyController.text.trim();
    final value = _newValueController.text.trim();
    if (key.isEmpty || value.isEmpty || _entries.containsKey(key)) return;

    setState(() {
      _entries[key] = value;
      _newKeyController.clear();
      _newValueController.clear();
    });

    widget.onChanged(_entries);
  }

  void _removeEntry(String key) {
    setState(() {
      _entries.remove(key);
    });
    widget.onChanged(_entries);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _isRequired && _entries.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.component.label,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: TextField(
                    controller: _newKeyController,
                    decoration: const InputDecoration(labelText: 'Key'))),
            const SizedBox(width: 8),
            Expanded(
                child: TextField(
                    controller: _newValueController,
                    decoration: const InputDecoration(labelText: 'Value'))),
            IconButton(icon: const Icon(Icons.add), onPressed: _addEntry),
          ],
        ),
        const SizedBox(height: 12),
        ..._entries.entries.map(
          (e) => ListTile(
            dense: true,
            title: Text('${e.key}: ${e.value}'),
            trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _removeEntry(e.key)),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('${widget.component.label} is required.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ),
      ],
    );
  }
}
