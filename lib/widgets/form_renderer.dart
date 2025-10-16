/// Renders a dynamic form in Flutter based on a Form.io form definition.
///
/// This widget receives a [FormModel] and builds a corresponding widget tree
/// based on its list of components. It supports dynamic user input handling,
/// required field validation, and data collection for form submission.
///
/// When a component of type "button" and action "submit" is tapped,
/// the form data is validated and submitted via [onSubmit].

import 'package:flutter/material.dart';

import '../core/exceptions.dart';
import '../models/component.dart';
import '../models/file_data.dart';
import '../models/form.dart';
import 'component_factory.dart';

typedef OnFormChanged = void Function(Map<String, dynamic> data);
typedef OnFormSubmitted = void Function(Map<String, dynamic> data);
typedef OnFormSubmitFailed = void Function(String error);
typedef OnAttachmentsChanged = void Function(
    Map<String, List<FileData>> attachments);
typedef OnFormSubmittedWithAttachments = void Function(
  Map<String, dynamic> data,
  Map<String, List<FileData>> attachments,
);

class FormRenderer extends StatefulWidget {
  final FormModel form;
  final OnFormChanged? onChanged;
  final OnFormSubmitted? onSubmit;
  final OnFormSubmitFailed? onError;
  final Map<String, dynamic>? initialData;
  final bool isSubmitting;

  /// Callback when attachments change (separate from form data)
  final OnAttachmentsChanged? onAttachmentsChanged;

  const FormRenderer({
    Key? key,
    required this.form,
    this.onChanged,
    this.onSubmit,
    this.onError,
    this.initialData,
    this.isSubmitting = false,
    this.onAttachmentsChanged,
  }) : super(key: key);

  @override
  State<FormRenderer> createState() => _FormRendererState();
}

class _FormRendererState extends State<FormRenderer> {
  late Map<String, dynamic> _formData;
  late Map<String, List<FileData>> _attachments;
  bool _isSubmitting = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _formData = widget.initialData != null
        ? Map<String, dynamic>.from(widget.initialData!)
        : {};
    _attachments = {};
  }

  @override
  void didUpdateWidget(covariant FormRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSubmitting != widget.isSubmitting) {
      setState(() {
        _isSubmitting = widget.isSubmitting;
      });
    }
  }

  void _updateField(String key, dynamic value) {
    setState(() {
      _formData[key] = value;
    });
    widget.onChanged?.call(_formData);
  }

  void _updateAttachment(String key, List<FileData> files) {
    setState(() {
      if (files.isEmpty) {
        _attachments.remove(key);
      } else {
        _attachments[key] = files;
      }
    });
    widget.onAttachmentsChanged?.call(_attachments);
  }

  bool _validateForm() {
    // Use Flutter's built-in form validation
    return _formKey.currentState?.validate() ?? false;
  }

  Future<void> _handleSubmit() async {
    final isValid = _validateForm();
    if (!isValid) return;

    setState(() => _isSubmitting = true);

    try {
      widget.onSubmit?.call(_formData);
    } catch (e) {
      final error = e is ApiException ? e.message : 'Unknown error';
      widget.onError?.call(error);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  /// Checks whether a component should be shown based on its conditional logic.
  bool _shouldShowComponent(ComponentModel component) {
    final condition = component.raw['conditional'];
    if (condition is! Map<String, dynamic>) return true;

    final when = condition['when'];
    final eq = condition['eq'];
    final show = condition['show'];

    if (when == null || when.toString().isEmpty) return true;

    final value = _formData[when];
    final matches = value?.toString() == eq?.toString();

    // Default behavior is to show if matched
    final shouldShow = (show == true || show == 'true') ? matches : !matches;

    return shouldShow;
  }

  Widget _buildComponent(ComponentModel component, {int? fieldNumber}) {
    if (!_shouldShowComponent(component)) {
      return const SizedBox.shrink();
    }

    // Handle button component separately to avoid rebuilding it through ComponentFactory
    if (component.type == 'button' &&
        (component.raw['action'] == 'submit' ||
            component.raw['action'] == null)) {
      return SizedBox.shrink();
    }

    final fieldWidget = ComponentFactory.build(
      component: component,
      // For file components, get value from _attachments instead of _formData
      value: component.type == 'file'
          ? _attachments[component.key] ?? []
          : _formData[component.key],
      onChanged: (value) {
        _updateField(component.key, value);
      },
      onFileChanged: (key, files) {
        _updateAttachment(key, files);
      },
      fieldNumber: fieldNumber,
    );

    return fieldWidget;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate field numbers for non-button, visible components
    int fieldNumber = 0;
    final componentNumbers = <String, int>{};
    for (final component in widget.form.components) {
      if (_shouldShowComponent(component) && component.type != 'button') {
        fieldNumber++;
        componentNumbers[component.key] = fieldNumber;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.form.components.map((component) {
                    // Skip hidden components
                    if (!_shouldShowComponent(component)) {
                      return const SizedBox.shrink();
                    }

                    final fieldNum = componentNumbers[component.key];

                    return Padding(
                      key: ValueKey(
                          'component_${component.key}_${component.type}'),
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildComponent(component, fieldNumber: fieldNum),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Theme.of(context)
                        .primaryColor
                        .withValues(alpha: 0.8);
                  }
                  if (states.contains(WidgetState.disabled)) {
                    return Theme.of(context).disabledColor;
                  }
                  return Theme.of(context).primaryColor;
                },
              ),
            ),
            onPressed: _isSubmitting ? null : _handleSubmit,
            child: _isSubmitting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Submit Form',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        )
      ],
    );
  }
}
