/// A Flutter widget that renders a checkbox based on a Form.io "checkbox" component.
///
/// Supports default value, label, and required validation.

import 'package:flutter/material.dart';

import '../../models/component.dart';

class CheckboxComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current value of the checkbox (true/false).
  final bool value;

  /// Callback called when the user toggles the checkbox.
  final ValueChanged<bool> onChanged;

  const CheckboxComponent({Key? key, required this.component, required this.value, required this.onChanged}) : super(key: key);

  /// Determines whether the checkbox is required.
  bool get _isRequired => component.required;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(component.label),
      value: value,
      onChanged: (val) {
        if (val != null) {
          onChanged(val);
        }
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      subtitle: _isRequired && !value ? Text('${component.label} is required.', style: TextStyle(color: Theme.of(context).colorScheme.error)) : null,
    );
  }
}
