/// A Flutter widget that renders a repeatable grid of form entries
/// based on a Form.io "editgrid" component.
///
/// Each row opens as a full form (not inline) and can contain multiple
/// child components. Ideal for collecting structured, nested data.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../component_factory.dart';

class EditGridComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// List of form rows; each row is a Map of values for its components.
  final List<Map<String, dynamic>> value;

  /// Callback triggered when the edit grid changes.
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  const EditGridComponent(
      {Key? key,
      required this.component,
      required this.value,
      required this.onChanged})
      : super(key: key);

  @override
  State<EditGridComponent> createState() => _EditGridComponentState();
}

class _EditGridComponentState extends State<EditGridComponent> {
  late List<Map<String, dynamic>> _rows;

  List<ComponentModel> get _childComponents {
    final components = widget.component.raw['components'] ?? [];
    return (components as List).map((c) => ComponentModel.fromJson(c)).toList();
  }

  bool get _isRequired => widget.component.required;

  @override
  void initState() {
    super.initState();
    _rows = List<Map<String, dynamic>>.from(widget.value);
  }

  void _addRow() {
    final newRow = <String, dynamic>{};
    for (var comp in _childComponents) {
      newRow[comp.key] = null;
    }
    setState(() {
      _rows.add(newRow);
    });
    widget.onChanged(_rows);
  }

  void _removeRow(int index) {
    setState(() {
      _rows.removeAt(index);
    });
    widget.onChanged(_rows);
  }

  void _updateField(int rowIndex, String key, dynamic value) {
    setState(() {
      _rows[rowIndex][key] = value;
    });
    widget.onChanged(_rows);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _isRequired && _rows.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.component.label,
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ..._rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Entry ${index + 1}',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      IconButton(
                          onPressed: () => _removeRow(index),
                          icon: const Icon(Icons.delete_outline)),
                    ],
                  ),
                  ..._childComponents.map(
                    (component) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: ComponentFactory.build(
                        component: component,
                        value: row[component.key],
                        onChanged: (val) =>
                            _updateField(index, component.key, val),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        TextButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add),
            label: const Text('Add Entry')),
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
