/// A Flutter widget that renders horizontally aligned columns based on
/// a Form.io "columns" layout component.
///
/// Each column can contain multiple child components. This is used
/// for creating side-by-side form layouts in a responsive row.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../component_factory.dart';

class ColumnsComponent extends StatelessWidget {
  /// The Form.io "columns" component definition.
  final ComponentModel component;

  /// Current value map that contains values of all nested components.
  final Map<String, dynamic> value;

  /// Callback triggered when any nested component in any column updates its value.
  final ValueChanged<Map<String, dynamic>> onChanged;

  const ColumnsComponent(
      {Key? key,
      required this.component,
      required this.value,
      required this.onChanged})
      : super(key: key);

  /// Parses the column layout structure from the raw JSON.
  List<List<ComponentModel>> get _columns {
    final cols = component.raw['columns'] as List<dynamic>? ?? [];
    return cols.map((col) {
      final comps = col['components'] as List<dynamic>? ?? [];
      return comps.map((c) => ComponentModel.fromJson(c)).toList();
    }).toList();
  }

  /// Updates a nested component's value using its key.
  void _updateField(String key, dynamic newValue) {
    final updated = Map<String, dynamic>.from(value);
    updated[key] = newValue;
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final columns = _columns;

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(bottom: 25),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 1.5,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: columns.map((colComponents) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: colComponents
                        .map(
                          (comp) => Padding(
                            padding:
                                const EdgeInsets.only(right: 20, bottom: 20),
                            child: ComponentFactory.build(
                                component: comp,
                                value: value[comp.key],
                                onChanged: (val) =>
                                    _updateField(comp.key, val)),
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
