/// A Flutter widget that renders a file upload input based on
/// a Form.io "file" component.
///
/// Handles file selection, preview, and basic validation.
/// Upload logic (to Form.io or custom storage) must be handled externally.

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';

class FileComponent extends StatelessWidget {
  /// The Form.io file component definition.
  final ComponentModel component;

  /// Currently selected file paths (may be local or uploaded URLs).
  final List<String> value;

  /// Callback triggered when files are selected or cleared.
  final ValueChanged<List<String>> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const FileComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.fieldNumber,
  }) : super(key: key);

  /// Whether multiple file selection is allowed.
  bool get _isMultiple => component.raw['multiple'] == true;

  /// Whether this field is required.
  bool get _isRequired => component.required;

  /// Allowed file types (from accept property, e.g., 'image/*').
  List<String> get _acceptedExtensions {
    final accept = component.raw['fileTypes'] as List? ?? [];
    return accept.map((e) => e['value'].toString()).toList();
  }

  /// Retrieves the description text if available in the raw JSON.
  String? get _description => component.raw['description'];

  /// Retrieves the tooltip text if available in the raw JSON.
  String? get _tooltip => component.raw['tooltip'];

  /// Retrieves the placeholder text if available in the raw JSON.
  String? get _placeholder => component.raw['placeholder'] == null ||
          component.raw['placeholder'].toString().isEmpty
      ? null
      : component.raw['placeholder'].toString();

  Future<void> _pickFiles(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: _isMultiple,
      type: FileType.custom,
      allowedExtensions: _acceptedExtensions.isNotEmpty
          ? _acceptedExtensions
              .map((e) => e.replaceAll(RegExp(r'[^\w]'), ''))
              .toList()
          : null,
    );

    if (result != null) {
      final paths = result.paths.whereType<String>().toList();
      onChanged(paths);
    }
  }

  void _removeFile(String path) {
    final updated = List<String>.from(value)..remove(path);
    onChanged(updated);
  }

  void _clearAll() {
    onChanged([]);
  }

  String? validator() {
    if (_isRequired && value.isEmpty) {
      return '${component.label} is required.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = Colors.grey.withValues(alpha: 0.3);

    return FormField<List<String>>(
      initialValue: value,
      validator: (_) {
        if (_isRequired && value.isEmpty) {
          return '${component.label} is required.';
        }
        return null;
      },
      builder: (FormFieldState<List<String>> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FieldLabel(
              label: component.label,
              isRequired: _isRequired,
              showClearButton: true,
              hasContent: value.isNotEmpty,
              onClear: () {
                _clearAll();
                field.didChange([]);
              },
              number: fieldNumber,
              description: _description,
              tooltip: _tooltip,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: field.hasError ? theme.colorScheme.error : borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (value.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: value.map((filePath) {
                        final fileName =
                            filePath.split(Platform.pathSeparator).last;
                        return Chip(
                          label: Text(fileName),
                          onDeleted: () {
                            _removeFile(filePath);
                            field.didChange(value);
                          },
                          deleteIcon: const Icon(Icons.close, size: 18),
                          backgroundColor:
                              theme.primaryColor.withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 13,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _pickFiles(context);
                        field.didChange(value);
                      },
                      icon: const Icon(Icons.upload_file, size: 20),
                      label: Text(
                        value.isEmpty
                            ? ((_placeholder) ??
                                (_isMultiple ? 'Upload Files' : 'Upload File'))
                            : 'Add ${_isMultiple ? 'More Files' : 'Another File'}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: theme.primaryColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
