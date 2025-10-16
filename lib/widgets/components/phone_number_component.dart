/// A Flutter widget that renders a phone number input field based on
/// a Form.io "phoneNumber" component.
///
/// Supports label, placeholder, required validation, default value,
/// and automatic phone number formatting.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';
import '../shared/input_decoration_utils.dart';

class PhoneNumberComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current phone number value.
  final String? value;

  /// Callback triggered when the phone number is updated.
  final ValueChanged<String> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const PhoneNumberComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.fieldNumber,
  }) : super(key: key);

  /// Whether the field is marked as required.
  bool get _isRequired => component.required;

  /// Optional placeholder for the input field.
  String? get _placeholder => component.raw['placeholder'].toString().isEmpty
      ? null
      : component.raw['placeholder'];

  /// Retrieves the description text if available in the raw JSON.
  String? get _description => component.raw['description'];

  /// Retrieves the tooltip text if available in the raw JSON.
  String? get _tooltip => component.raw['tooltip'];

  /// Regular expression for basic phone number format validation.
  static final _phoneRegex = RegExp(r'^[\d\-\+\s\(\)]+$');

  /// Validates presence and basic format.
  String? _validator(String? input) {
    final text = (input ?? '').trim();

    if (_isRequired && text.isEmpty) {
      return '${component.label} is required.';
    }

    if (text.isNotEmpty && !_phoneRegex.hasMatch(text)) {
      return 'Please enter a valid phone number.';
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
            hintText: _placeholder ?? '(555) 123-4567',
          ),
          keyboardType: TextInputType.phone,
          onChanged: onChanged,
          validator: _validator,
        ),
      ],
    );
  }
}
