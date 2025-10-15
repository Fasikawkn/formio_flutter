/// A Flutter widget that renders an email input based on a Form.io "email" component.
///
/// Validates email format and supports label, placeholder, required constraint,
/// and a default value.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';
import '../shared/input_decoration_utils.dart';

class EmailComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current email value.
  final String? value;

  /// Callback triggered when the email is updated.
  final ValueChanged<String> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const EmailComponent(
      {Key? key,
      required this.component,
      required this.value,
      required this.onChanged,
      this.fieldNumber})
      : super(key: key);

  /// Whether the field is marked as required.
  bool get _isRequired => component.required;

  /// Placeholder hint for the input.
  String? get _placeholder => component.raw['placeholder'];

  /// Retrieves the description text if available in the raw JSON.
  String? get _description => component.raw['description'];

  /// Retrieves the tooltip text if available in the raw JSON.
  String? get _tooltip => component.raw['tooltip'];

  /// Regular expression for basic email validation.
  static final _emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');

  /// Validates required and format constraints.
  String? _validator(String? input) {
    final text = (input ?? '').trim();

    if (_isRequired && text.isEmpty) {
      return '${component.label} is required.';
    }

    if (text.isNotEmpty && !_emailRegex.hasMatch(text)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

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
          decoration: InputDecorationUtils.createDecoration(
            context,
            hintText: _placeholder ?? 'example@example.com',
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: onChanged,
          validator: _validator,
        ),
      ],
    );
  }
}
