/// A Flutter widget that renders a password input based on a Form.io "password" component.
///
/// Supports label, placeholder, required validation, and default value.
/// The input is obscured by default for security.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';
import '../shared/input_decoration_utils.dart';

class PasswordComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current value of the password input.
  final String? value;

  /// Callback called when the user updates the password.
  final ValueChanged<String> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const PasswordComponent(
      {Key? key,
      required this.component,
      required this.value,
      required this.onChanged,
      this.fieldNumber})
      : super(key: key);

  @override
  State<PasswordComponent> createState() => _PasswordComponentState();
}

class _PasswordComponentState extends State<PasswordComponent> {
  bool _obscureText = true;

  /// Whether the field is marked as required.
  bool get _isRequired => widget.component.required;

  /// Placeholder text if defined.
  String? get _placeholder => widget.component.raw['placeholder'];

  /// Retrieves the description text if available in the raw JSON.
  String? get _description => widget.component.raw['description'];

  /// Retrieves the tooltip text if available in the raw JSON.
  String? get _tooltip => widget.component.raw['tooltip'];

  @override
  Widget build(BuildContext context) {
    final currentValue =
        widget.value ?? widget.component.defaultValue?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FieldLabel(
          label: widget.component.label,
          isRequired: _isRequired,
          showClearButton: true,
          hasContent: currentValue.isNotEmpty,
          onClear: () => widget.onChanged(''),
          number: widget.fieldNumber,
          description: _description,
          tooltip: _tooltip,
        ),
        TextFormField(
          initialValue: currentValue,
          decoration: InputDecorationUtils.createDecoration(
            context,
            hintText: _placeholder,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              tooltip: _obscureText ? 'Show password' : 'Hide password',
            ),
          ),
          obscureText: _obscureText,
          onChanged: widget.onChanged,
          validator: _isRequired
              ? (val) => (val == null || val.isEmpty)
                  ? '${widget.component.label} is required.'
                  : null
              : null,
        ),
      ],
    );
  }
}
