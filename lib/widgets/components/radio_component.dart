/// A Flutter widget that renders a group of radio buttons based on a
/// Form.io "radio" component.
///
/// Displays a vertical list of options, supports default value,
/// required validation, and value change handling.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';

class RadioComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The currently selected value.
  final dynamic value;

  /// Callback triggered when the user selects a new option.
  final ValueChanged<dynamic> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const RadioComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.fieldNumber,
  }) : super(key: key);

  /// Whether the field is marked as required.
  bool get _isRequired => component.required;

  /// List of values the user can select from.
  List<Map<String, dynamic>> get _values =>
      List<Map<String, dynamic>>.from(component.raw['values'] ?? []);

  /// Retrieves the description text if available in the raw JSON.
  String? get _description => component.raw['description'];

  /// Retrieves the tooltip text if available in the raw JSON.
  String? get _tooltip => component.raw['tooltip'];

  /// Validates selection based on requirement.
  String? validator() {
    if (_isRequired && (value == null || value.toString().isEmpty)) {
      return '${component.label} is required.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value.toString().isNotEmpty;

    return FormField<dynamic>(
      initialValue: value,
      validator: (_) {
        if (_isRequired && (value == null || value.toString().isEmpty)) {
          return '${component.label} is required.';
        }
        return null;
      },
      builder: (FormFieldState<dynamic> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FieldLabel(
              label: component.label,
              isRequired: _isRequired,
              showClearButton: true,
              hasContent: hasValue,
              onClear: () {
                onChanged(null);
                field.didChange(null);
              },
              number: fieldNumber,
              description: _description,
              tooltip: _tooltip,
            ),
            ..._values.map((option) {
              final optionLabel = option['label'] ?? '';
              final optionValue = option['value'];

              return RadioListTile(
                dense: true,
                visualDensity: VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
                key:
                    ValueKey('${component.key}_$optionValue'), // Ensure rebuild
                value: optionValue,
                groupValue: value,
                title: Text(optionLabel.toString()),
                onChanged: (dynamic newValue) {
                  onChanged(newValue);
                  field.didChange(newValue);
                },
                contentPadding: EdgeInsets.zero,
              );
            }),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
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
