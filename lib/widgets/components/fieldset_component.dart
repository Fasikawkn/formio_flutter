/// A Flutter widget that renders a group of components within a bordered fieldset
/// based on a Form.io "fieldset" component.
///
/// Displays child form fields inside a visual group with an optional legend/title.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../component_factory.dart';

class FieldSetComponent extends StatelessWidget {
  /// The Form.io fieldset component.
  final ComponentModel component;

  /// Current form values inside the fieldset.
  final Map<String, dynamic> value;

  /// Callback triggered when a nested field updates its value.
  final ValueChanged<Map<String, dynamic>> onChanged;

  /// Callback triggered when a button component is pressed.
  final OnButtonPressed? onPressed;

  /// Optional: Full form data for evaluating conditionals
  final Map<String, dynamic>? formData;

  const FieldSetComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.onPressed,
    this.formData,
  }) : super(key: key);

  /// List of child components inside the fieldset.
  List<ComponentModel> get _children {
    final components = component.raw['components'] ?? [];
    return (components as List).map((c) => ComponentModel.fromJson(c)).toList();
  }

  /// Optional legend/title text for the fieldset.
  String get _legend => component.label;

  void _updateChild(String key, dynamic fieldValue) {
    final updated = Map<String, dynamic>.from(value);
    updated[key] = fieldValue;
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(6)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_legend.isNotEmpty)
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_legend,
                    style: Theme.of(context).textTheme.labelLarge)),
          ..._children
              .where((child) => ComponentFactory.shouldShowComponent(
                    child,
                    formData ?? value,
                  ))
              .map(
                (child) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ComponentFactory.build(
                      component: child,
                      value: value[child.key],
                      onPressed: onPressed,
                      formData: formData,
                      onChanged: (val) => _updateChild(child.key, val)),
                ),
              ),
        ],
      ),
    );
  }
}
