/// A Flutter widget that renders a number input based on a Form.io "number" component.
///
/// Supports label, placeholder, default value, required validation,
/// and basic numeric constraints (min, max).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';
import '../shared/input_decoration_utils.dart';

class NumberComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current numeric value entered by the user.
  final num? value;

  /// Callback called when the user updates the number.
  final ValueChanged<num?> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const NumberComponent(
      {Key? key,
      required this.component,
      required this.value,
      required this.onChanged,
      this.fieldNumber})
      : super(key: key);

  /// Returns true if the field is marked as required.
  bool get _isRequired => component.required;

  /// The minimum allowed value (if defined).
  num? get _min =>
      num.tryParse(component.raw['validate']?['min']?.toString() ?? '');

  /// The maximum allowed value (if defined).
  num? get _max =>
      num.tryParse(component.raw['validate']?['max']?.toString() ?? '');

  /// Returns placeholder text, if available.
  String? get _placeholder => component.raw['placeholder'];

  /// Retrieves the description text if available in the raw JSON.
  String? get _description => component.raw['description'];

  /// Retrieves the tooltip text if available in the raw JSON.
  String? get _tooltip => component.raw['tooltip'];

  /// Parses a string to a numeric value, handling empty or invalid input.
  num? _parse(String input) {
    if (input.trim().isEmpty) return null;
    final parsed = num.tryParse(input);
    return parsed;
  }

  /// Validates the input against min/max and required constraints.
  String? _validator(String? input) {
    final parsed = _parse(input ?? '');

    if (_isRequired && parsed == null) {
      return '${component.label} is required.';
    }

    if (parsed != null) {
      if (_min != null && parsed < _min!) {
        return '${component.label} must be at least $_min.';
      }
      if (_max != null && parsed > _max!) {
        return '${component.label} must be at most $_max.';
      }
    }
    print(parsed);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final currentValue =
        value?.toString() ?? component.defaultValue?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FieldLabel(
          label: component.label,
          isRequired: _isRequired,
          showClearButton: true,
          hasContent: currentValue.isNotEmpty,
          onClear: () => onChanged(null),
          number: fieldNumber,
          description: _description,
          tooltip: _tooltip,
        ),
        TextFormField(
          key: ValueKey(component.key),
          initialValue: currentValue,
          decoration: InputDecorationUtils.createDecoration(
            context,
            hintText: _placeholder,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
          ],
          keyboardType: TextInputType.number,
          onChanged: (input) => onChanged(_parse(input)),
          validator: _validator,
        ),
      ],
    );
  }
}
