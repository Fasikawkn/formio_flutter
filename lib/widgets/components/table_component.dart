/// A Flutter widget that renders a grid-style layout of form components
/// based on a Form.io "table" component.
///
/// Each cell can contain zero or more form components. This layout
/// is ideal for creating structured forms with rows and columns.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../component_factory.dart';

class TableComponent extends StatelessWidget {
  /// The Form.io table component definition.
  final ComponentModel component;

  /// Current value map of all child components.
  final Map<String, dynamic> value;

  /// Callback triggered when any child component's value changes.
  final ValueChanged<Map<String, dynamic>> onChanged;

  /// Callback triggered when a button component is pressed.
  final OnButtonPressed? onPressed;

  const TableComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.onPressed,
  }) : super(key: key);

  /// Returns a list of rows, where each row is a list of components.
  // List<List<ComponentModel>> get _rows {
  //   final rows = component.raw['rows'] as List? ?? [];

  //   return rows.map<List<ComponentModel>>((row) {
  //     final cells = row as List;
  //     return cells.expand<ComponentModel>((cell) {
  //       final components = cell['components'] as List? ?? [];
  //       return components.map((c) => ComponentModel.fromJson(c));
  //     }).toList();
  //   }).toList();
  // }

  /// Helper to build a single cell's widget content.
  Widget _buildCell(ComponentModel component) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ComponentFactory.build(
        component: component,
        value: value[component.key],
        onPressed: onPressed,
        onChanged: (val) {
          final updated = Map<String, dynamic>.from(value);
          updated[component.key] = val;
          onChanged(updated);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tableRows = component.raw['rows'] as List? ?? [];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 1.3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: tableRows.map<TableRow>((row) {
              final rowCells = row as List<dynamic>;
              return TableRow(
                children: rowCells.map((cell) {
                  final components = cell['components'] as List? ?? [];
                  if (components.isEmpty) {
                    return const SizedBox(height: 48); // empty cell
                  }
                  return Column(
                      children: components
                          .map<ComponentModel>(
                              (json) => ComponentModel.fromJson(json))
                          .map(_buildCell)
                          .toList());
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
