/// A Flutter widget that renders a text field based on a Form.io "textfield" component.
///
/// Supports placeholder, label, default value, and required validation.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';
import '../shared/input_decoration_utils.dart';

class TextFieldComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current value of the field.
  final String? value;

  /// Callback called when the user changes the input value.
  final ValueChanged<String> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const TextFieldComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.fieldNumber,
  }) : super(key: key);

  /// Retrieves a placeholder value if available in the raw JSON.
  String? get _placeholder => component.raw['placeholder'];

  /// Returns true if the field is required.
  bool get _isRequired => component.required;

  /// Retrieves the description text if available in the raw JSON.
  String? get _description => component.raw['description'];

  /// Retrieves the tooltip text if available in the raw JSON.
  String? get _tooltip => component.raw['tooltip'];

  @override
  Widget build(BuildContext context) {
    final currentValue = value ?? component.defaultValue?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FieldLabel(
          label: component.label,
          isRequired: _isRequired,
          showClearButton: true,
          hasContent: currentValue.isNotEmpty,
          onClear: () => onChanged(''),
          number: fieldNumber,
          description: _description,
          tooltip: _tooltip,
        ),
        TextFormField(
          key: ValueKey(component.key), // Ensures rebuild on condition change
          initialValue: currentValue,
          decoration: InputDecorationUtils.createDecoration(
            context,
            hintText: _placeholder,
          ),
          onChanged: onChanged,
          validator: _isRequired
              ? (val) => (val == null || val.isEmpty)
                  ? '${component.label} is required.'
                  : null
              : null,
        ),
      ],
    );
  }
}
