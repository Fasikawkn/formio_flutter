/// A Flutter widget that renders a multi-line text area based on a
/// Form.io "textarea" component.
///
/// Supports label, placeholder, default value, and required validation.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';
import '../shared/input_decoration_utils.dart';

class TextAreaComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current value of the text area field.
  final String? value;

  /// Callback called when the user updates the text.
  final ValueChanged<String> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const TextAreaComponent(
      {Key? key,
      required this.component,
      required this.value,
      required this.onChanged,
      this.fieldNumber})
      : super(key: key);

  /// Placeholder text shown inside the textarea when empty.
  String? get _placeholder => component.raw['placeholder'];

  /// Returns true if the field is marked as required.
  bool get _isRequired => component.required;

  /// Number of rows/lines to show initially (default is 3).
  int get _rows => component.raw['rows'] ?? 3;

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
          initialValue: currentValue,
          maxLines: _rows,
          decoration: InputDecorationUtils.createDecoration(
            context,
            hintText: _placeholder,
          ).copyWith(
            alignLabelWithHint: true,
          ),
          onChanged: onChanged,
          validator: _isRequired
              ? (val) => (val == null || val.trim().isEmpty)
                  ? '${component.label} is required.'
                  : null
              : null,
        ),
      ],
    );
  }
}
