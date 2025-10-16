/// A Flutter widget that renders a survey matrix based on a Form.io "survey" component.
///
/// Each row represents a question and each column is a selectable rating option.
/// Internally stores the selected values in a map of { questionValue: selectedOption }.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';
import '../shared/input_decoration_utils.dart';

class SurveyComponent extends StatelessWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current selected values per row, in the form:
  /// { "question1": "answerA", "question2": "answerB" }
  final Map<String, String> value;

  /// Callback triggered when a survey row is answered.
  final ValueChanged<Map<String, String>> onChanged;

  const SurveyComponent(
      {Key? key,
      required this.component,
      required this.value,
      required this.onChanged})
      : super(key: key);

  /// Whether at least one answer is required.
  bool get _isRequired => component.required;

  /// The list of rows/questions in the survey.
  List<Map<String, dynamic>> get _rows =>
      List<Map<String, dynamic>>.from(component.raw['questions'] ?? []);

  /// The list of answer options (columns).
  List<Map<String, dynamic>> get _columns =>
      List<Map<String, dynamic>>.from(component.raw['values'] ?? []);

  /// Returns the current selected value for a given row/question.
  String? _selectedFor(String rowKey) => value[rowKey];

  /// Validates if all required questions are answered.
  String? validator() {
    if (_isRequired) {
      final answered = value.entries.where((e) => e.value.isNotEmpty).length;
      if (answered < _rows.length) {
        return 'Please complete all survey questions.';
      }
    }
    return null;
  }

  /// Updates the answer for a given question.
  void _update(String questionKey, String answerValue) {
    final updated = Map<String, String>.from(value);
    updated[questionKey] = answerValue;
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = component.raw['description']?.toString();
    final tooltip = component.raw['tooltip']?.toString();

    return FormField<Map<String, String>>(
      initialValue: value,
      validator: (_) {
        if (_isRequired) {
          final answered =
              value.entries.where((e) => e.value.isNotEmpty).length;
          if (answered < _rows.length) {
            return 'Please complete all survey questions.';
          }
        }
        return null;
      },
      builder: (FormFieldState<Map<String, String>> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use FieldLabel for consistent styling
            FieldLabel(
              label: component.label,
              isRequired: _isRequired,
              description: description,
              tooltip: tooltip,
            ),
            const SizedBox(height: 8),

            // Modern card-style container for the table
            InputDecorator(
              decoration: InputDecorationUtils.createDecoration(
                context,
                errorText: field.errorText,
              ).copyWith(
                contentPadding: EdgeInsets.zero,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Table(
                  columnWidths: const {0: FlexColumnWidth(2)},
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    verticalInside: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  children: [
                    // Header Row with modern styling
                    TableRow(
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.05),
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(''),
                        ),
                        ..._columns.map((col) => Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                col['label'] ?? '',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            )),
                      ],
                    ),
                    // Question Rows with modern styling
                    ..._rows.asMap().entries.map((entry) {
                      final index = entry.key;
                      final row = entry.value;
                      final rowKey = row['value'] ?? '';
                      final isEven = index % 2 == 0;

                      return TableRow(
                        decoration: BoxDecoration(
                          color: isEven
                              ? Colors.transparent
                              : Colors.grey.withValues(alpha: 0.03),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              row['label'] ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          ..._columns.map((col) {
                            final colValue = col['value']?.toString() ?? '';

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Center(
                                child: Radio<String>(
                                  groupValue: _selectedFor(rowKey),
                                  value: colValue,
                                  activeColor: theme.primaryColor,
                                  onChanged: (val) {
                                    if (val != null) {
                                      _update(rowKey, val);
                                      field.didChange(value);
                                    }
                                  },
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
