/// A Flutter widget that renders a dropdown menu based on a Form.io "select" component.
///
/// Supports label, placeholder, required validation, default value,
/// and dynamic value lists from static JSON.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';
import '../shared/input_decoration_utils.dart';

class SelectComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The currently selected value.
  final dynamic value;

  /// Callback triggered when the user selects an option.
  final ValueChanged<dynamic> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const SelectComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.fieldNumber,
  }) : super(key: key);

  /// Whether the field is marked as required.
  bool get _isRequired => component.required;

  /// Placeholder shown when no value is selected.
  String? get _placeholder => component.raw['placeholder'];

  /// Retrieves the description text if available in the raw JSON.
  String? get _description => component.raw['description'];

  /// Retrieves the tooltip text if available in the raw JSON.
  String? get _tooltip => component.raw['tooltip'];

  /// Returns the list of available options.
  List<Map<String, dynamic>> get _values =>
      List<Map<String, dynamic>>.from(component.raw['data']?['values'] ?? []);

  /// Validates if a required selection is made.
  String? validator() {
    if (_isRequired && (value == null || value.toString().isEmpty)) {
      return '${component.label} is required.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value.toString().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FieldLabel(
          label: component.label,
          isRequired: _isRequired,
          showClearButton: true,
          hasContent: hasValue,
          onClear: () {
            onChanged(null);
          },
          number: fieldNumber,
          description: _description,
          tooltip: _tooltip,
        ),
        InputDecorator(
          key: ValueKey(
              component.key), // ensure proper rebuild when visibility toggles
          decoration: InputDecorationUtils.createDropdownDecoration(
            context,
            hintText: _placeholder ?? 'Select an option...',
            // errorText: error,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<dynamic>(
              isExpanded: true,
              isDense: true,
              hint: Text(
                _placeholder ?? 'Select an option...',
                style: TextStyle(
                  color: Theme.of(context).hintColor.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              value: value,
              onChanged: onChanged,
              icon: const SizedBox
                  .shrink(), // Hide default icon since we have it in decoration
              items: _values.map((option) {
                final label = option['label']?.toString() ?? '';
                final val = option['value'];
                return DropdownMenuItem<dynamic>(
                  value: val,
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
