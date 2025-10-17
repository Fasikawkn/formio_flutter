/// A Flutter widget that renders a button based on a Form.io "button" component.
///
/// Supports configurable action types (submit, reset, etc.), label, theme,
/// and disabled state. Button logic is handled externally via the [onPressed] callback.

import 'package:flutter/material.dart';

import '../../models/component.dart';

/// Defines the type of action the button performs.
enum ButtonAction { submit, reset, custom, unknown }

class ButtonComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// Called when the button is tapped.
  final Function(String action) onPressed;

  /// Whether the button is currently disabled.
  final bool isDisabled;

  const ButtonComponent(
      {Key? key,
      required this.component,
      required this.onPressed,
      this.isDisabled = false})
      : super(key: key);

  /// Extracts the button label from the component definition.
  String get _label => component.label.isNotEmpty
      ? component.label
      : (component.raw['label'] ?? 'Submit').toString();
  String get action => component.raw['action'] ?? 'submit';

  /// Determines the action type of the button.
  // ButtonAction get _action {
  //   final type = component.raw['action'] ?? 'submit';
  //   switch (type) {
  //     case 'submit':
  //       return ButtonAction.submit;
  //     case 'reset':
  //       return ButtonAction.reset;
  //     case 'event':
  //       return ButtonAction.custom;
  //     default:
  //       return ButtonAction.unknown;
  //   }
  // }

  /// Chooses a button style based on the theme specified in the component.
  ButtonStyle _style(BuildContext context) {
    final theme = (component.raw['theme'] ?? 'primary').toString();
    switch (theme) {
      case 'primary':
        // Using primary color
        break;
      case 'danger':
        // Using error color
        break;
      case 'info':
        // Using teal color
        break;
      case 'success':
        // Using green color
        break;
      case 'warning':
        // Using orange color
        break;
      default:
        // Default to primary
        break;
    }

    return ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
            style: _style(context),
            onPressed: isDisabled ? null : () => onPressed(action),
            child: Text(_label)));
  }
}
