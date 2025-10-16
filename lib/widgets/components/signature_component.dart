/// A Flutter widget that renders a signature input field based on
/// a Form.io "signature" component.
///
/// Allows the user to draw a signature on a canvas. The signature
/// is captured as a base64-encoded PNG image string.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';
import '../shared/input_decoration_utils.dart';

class SignatureComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current signature value as a base64-encoded PNG.
  final String? value;

  /// Callback triggered when the signature is drawn.
  final ValueChanged<String?> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const SignatureComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.fieldNumber,
  }) : super(key: key);

  @override
  State<SignatureComponent> createState() => _SignatureComponentState();
}

class _SignatureComponentState extends State<SignatureComponent> {
  late SignatureController _controller;

  bool get _isRequired => widget.component.required;

  /// Retrieves the description text if available in the raw JSON.
  String? get _description => widget.component.raw['description'];

  /// Retrieves the tooltip text if available in the raw JSON.
  String? get _tooltip => widget.component.raw['tooltip'];

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 2.0,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    // Listen to signature changes
    _controller.addListener(_onSignatureChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSignatureChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSignatureChanged() async {
    if (_controller.isNotEmpty) {
      final signature = await _controller.toPngBytes();
      if (signature != null) {
        final base64Image = base64Encode(signature);
        widget.onChanged('$base64Image');
      }
    } else {
      widget.onChanged(null);
    }
  }

  void _clear() {
    _controller.clear();
  }

  String? validator() {
    if (_isRequired && (widget.value == null || _controller.isEmpty)) {
      return '${widget.component.label} is required.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasContent = widget.value != null && _controller.isNotEmpty;

    return FormField<String>(
      initialValue: widget.value,
      validator: (_) {
        if (_isRequired && (widget.value == null || _controller.isEmpty)) {
          return '${widget.component.label} is required.';
        }
        return null;
      },
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FieldLabel(
              label: widget.component.label,
              isRequired: _isRequired,
              showClearButton: true,
              hasContent: hasContent,
              onClear: () {
                _clear();
                field.didChange(null);
              },
              number: widget.fieldNumber,
              description: _description,
              tooltip: _tooltip,
            ),
            InputDecorator(
              decoration: InputDecorationUtils.createDecoration(
                context,
                errorText: field.errorText,
              ),
              child: Container(
                height: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Signature(
                    controller: _controller,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
