/// A Flutter widget that renders a repeatable table of input rows
/// based on a Form.io "datagrid" component.
///
/// Each row consists of multiple child components (columns),
/// and users can add or remove rows dynamically. The output is
/// a List<Map<String, dynamic>>.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../component_factory.dart';

class DataGridComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// Current list of row values (each row is a Map of component values).
  final List<Map<String, dynamic>> value;

  /// Callback triggered when the grid content changes.
  final ValueChanged<List<Map<String, dynamic>>> onChanged;

  const DataGridComponent(
      {Key? key,
      required this.component,
      required this.value,
      required this.onChanged})
      : super(key: key);

  @override
  State<DataGridComponent> createState() => _DataGridComponentState();
}

class _DataGridComponentState extends State<DataGridComponent> {
  late List<Map<String, dynamic>> _rows;

  List<ComponentModel> get _columns {
    final rawCols = widget.component.raw['components'] as List? ?? [];
    return rawCols.map((c) => ComponentModel.fromJson(c)).toList();
  }

  bool get _isRequired => widget.component.required;

  @override
  void initState() {
    super.initState();
    _rows = List<Map<String, dynamic>>.from(widget.value);
    if (_rows.isEmpty) _addRow(); // Start with one empty row
  }

  void _addRow() {
    final newRow = <String, dynamic>{};
    for (var col in _columns) {
      newRow[col.key] = null;
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

  void _updateCell(int rowIndex, String key, dynamic value) {
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
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _rows.length,
          itemBuilder: (context, index) {
            final row = _rows[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ..._columns.map(
                      (col) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ComponentFactory.build(
                            component: col,
                            value: row[col.key],
                            onChanged: (val) =>
                                _updateCell(index, col.key, val)),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                          onPressed: () => _removeRow(index),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remove Row')),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        TextButton.icon(
            onPressed: _addRow,
            icon: const Icon(Icons.add),
            label: const Text('Add Row')),
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
