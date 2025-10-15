/// A Flutter widget that renders a currency input field based on
/// a Form.io "currency" component.
///
/// Supports default value, required validation, min/max, and basic formatting.
/// It accepts only numerical input and represents currency values like USD, EUR, etc.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';
import '../shared/input_decoration_utils.dart';

class CurrencyComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current numeric value entered by the user.
  final num? value;

  /// Callback triggered when the currency value changes.
  final ValueChanged<num?> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const CurrencyComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.fieldNumber,
  }) : super(key: key);

  /// Whether this field is marked as required.
  bool get _isRequired => component.required;

  /// Placeholder text shown when the field is empty.
  String? get _placeholder => component.raw['placeholder'];

  /// Minimum allowed currency value.
  num? get _min => component.raw['validate']?['min'];

  /// Maximum allowed currency value.
  num? get _max => component.raw['validate']?['max'];

  /// Currency symbol (default: $).
  String get _currencySymbol => component.raw['currency'] ?? '\$';

  /// Retrieves the description text if available in the raw JSON.
  String? get _description => component.raw['description'];

  /// Retrieves the tooltip text if available in the raw JSON.
  String? get _tooltip => component.raw['tooltip'];

  /// Parses the string input to a number.
  num? _parse(String input) {
    if (input.trim().isEmpty) return null;
    return num.tryParse(
        input.replaceAll(',', '').replaceAll(_currencySymbol, ''));
  }

  /// Validates the input against required and min/max constraints.
  String? _validator(String? input) {
    final parsed = _parse(input ?? '');

    if (_isRequired && parsed == null) {
      return '${component.label} is required.';
    }

    if (parsed != null) {
      if (_min != null && parsed < _min!) {
        return 'Minimum value is $_currencySymbol$_min.';
      }
      if (_max != null && parsed > _max!) {
        return 'Maximum value is $_currencySymbol$_max.';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final initialText =
        value?.toString() ?? component.defaultValue?.toString() ?? '';
    final hasContent = initialText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FieldLabel(
          label: component.label,
          isRequired: _isRequired,
          showClearButton: true,
          hasContent: hasContent,
          onClear: () => onChanged(null),
          number: fieldNumber,
          description: _description,
          tooltip: _tooltip,
        ),
        TextFormField(
          initialValue: initialText,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecorationUtils.createDecoration(
            context,
            hintText: _placeholder ?? '${_currencySymbol}0.00',
            suffixIcon: Icon(Icons.attach_money),
          ),
          onChanged: (input) => onChanged(_parse(input)),
          validator: _validator,
        ),
      ],
    );
  }
}
