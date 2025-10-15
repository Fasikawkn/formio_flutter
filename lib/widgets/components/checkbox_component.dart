/// A Flutter widget that renders a checkbox based on a Form.io "checkbox" component.
///
/// Supports default value, label, and required validation.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';

class CheckboxComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current value of the checkbox (true/false).
  final bool value;

  /// Callback called when the user toggles the checkbox.
  final ValueChanged<bool> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const CheckboxComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.fieldNumber,
  }) : super(key: key);

  /// Determines whether the checkbox is required.
  bool get _isRequired => component.required;

  /// Retrieves the description text if available in the raw JSON.
  String? get _description => component.raw['description'];

  /// Retrieves the tooltip text if available in the raw JSON.
  String? get _tooltip => component.raw['tooltip'];

  /// Returns validation error message if needed.
  String? validator() {
    if (_isRequired && !value) {
      return '${component.label} is required.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Checkbox(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              value: value,
              onChanged: (val) {
                if (val != null) {
                  onChanged(val);
                }
              },
              visualDensity: VisualDensity(
                horizontal: -4,
                vertical: -4,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FieldLabel(
                label: component.label,
                isRequired: _isRequired,
                showClearButton: true,
                hasContent: value,
                onClear: () => onChanged(false),
                number: fieldNumber,
                description: _description,
                tooltip: _tooltip,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
