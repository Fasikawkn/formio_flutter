/// A Flutter widget that renders multiple checkboxes based on a
/// Form.io "selectboxes" component.
///
/// Each checkbox represents a boolean value for a labeled option.
/// The result is stored as a map of `{ optionKey: true/false }`.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';

class SelectBoxesComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current selection state as a map of { key: bool }.
  final Map<String, bool> value;

  /// Callback triggered when any option is toggled.
  final ValueChanged<Map<String, bool>> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const SelectBoxesComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.fieldNumber,
  }) : super(key: key);

  /// Whether the component is required (at least one must be selected).
  bool get _isRequired => component.required;

  /// List of available checkbox options.
  List<Map<String, dynamic>> get _values =>
      List<Map<String, dynamic>>.from(component.raw['values'] ?? []);

  /// Retrieves the description text if available in the raw JSON.
  String? get _description => component.raw['description'];

  /// Retrieves the tooltip text if available in the raw JSON.
  String? get _tooltip => component.raw['tooltip'];

  /// Returns validation error message if needed.
  String? validator() {
    if (_isRequired) {
      final hasAnyChecked = value.values.any((v) => v == true);
      if (!hasAnyChecked) {
        return '${component.label} is required.';
      }
    }
    return null;
  }

  /// Updates the selected checkbox state.
  void _toggle(String key, bool isChecked) {
    final newState = Map<String, bool>.from(value);
    newState[key] = isChecked;
    onChanged(newState);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = value.values.any((v) => v == true);

    return FormField<Map<String, bool>>(
      initialValue: value,
      validator: (_) {
        if (_isRequired) {
          final hasAnyChecked = value.values.any((v) => v == true);
          if (!hasAnyChecked) {
            return '${component.label} is required.';
          }
        }
        return null;
      },
      builder: (FormFieldState<Map<String, bool>> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FieldLabel(
              label: component.label,
              isRequired: _isRequired,
              showClearButton: true,
              hasContent: hasValue,
              onClear: () {
                final clearedState = Map<String, bool>.from(value);
                clearedState.updateAll((key, value) => false);
                onChanged(clearedState);
                field.didChange(clearedState);
              },
              number: fieldNumber,
              description: _description,
              tooltip: _tooltip,
            ),
            ..._values.map((option) {
              final key = option['value']?.toString() ?? '';
              final label = option['label']?.toString() ?? '';
              final checked = value[key] ?? false;

              return CheckboxListTile(
                dense: true,
                checkboxShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                visualDensity: VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
                value: checked,
                title: Text(label),
                onChanged: (val) {
                  if (val != null) {
                    _toggle(key, val);
                    final newState = Map<String, bool>.from(value);
                    newState[key] = val;
                    field.didChange(newState);
                  }
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
