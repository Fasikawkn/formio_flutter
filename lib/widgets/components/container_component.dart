/// A Flutter widget that renders a container of nested components
/// based on a Form.io "container" component.
///
/// The container holds child components and groups their values under
/// a single key in the form data map.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../component_factory.dart';

class ContainerComponent extends StatelessWidget {
  /// The Form.io component definition for the container.
  final ComponentModel component;

  /// The current nested value map for this container.
  final Map<String, dynamic> value;

  /// Callback triggered when any child component changes its value.
  final ValueChanged<Map<String, dynamic>> onChanged;

  const ContainerComponent(
      {Key? key,
      required this.component,
      required this.value,
      required this.onChanged})
      : super(key: key);

  /// List of child components inside the container.
  List<ComponentModel> get _children {
    final rawComponents = component.raw['components'] ?? [];
    return (rawComponents as List)
        .map((c) => ComponentModel.fromJson(c))
        .toList();
  }

  /// Updates the container's internal state when a child field changes.
  void _updateField(String key, dynamic fieldValue) {
    final updated = Map<String, dynamic>.from(value);
    updated[key] = fieldValue;
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (component.label.isNotEmpty)
          Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(component.label,
                  style: Theme.of(context).textTheme.bodyMedium)),
        ..._children.map(
          (child) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ComponentFactory.build(
                component: child,
                value: value[child.key],
                onChanged: (val) => _updateField(child.key, val)),
          ),
        ),
      ],
    );
  }
}
