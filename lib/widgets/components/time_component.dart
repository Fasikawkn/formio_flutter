/// A Flutter widget that renders a time picker based on a Form.io "time" component.
///
/// Only allows time selection (hour and minute). Supports required validation,
/// default value, and formatted display.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';
import '../shared/input_decoration_utils.dart';

class TimeComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current selected time value in "HH:mm" format.
  final String? value;

  /// Callback called when the time changes.
  final ValueChanged<String?> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const TimeComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.fieldNumber,
  }) : super(key: key);

  @override
  State<TimeComponent> createState() => _TimeComponentState();
}

class _TimeComponentState extends State<TimeComponent> {
  TimeOfDay? _selectedTime;

  bool get _isRequired => widget.component.required;
  String? get _placeholder => widget.component.raw['placeholder'];

  /// Retrieves the description text if available in the raw JSON.
  String? get _description => widget.component.raw['description'];

  /// Retrieves the tooltip text if available in the raw JSON.
  String? get _tooltip => widget.component.raw['tooltip'];

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      final parts = widget.value!.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null) {
          _selectedTime = TimeOfDay(hour: hour, minute: minute);
        }
      }
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
        context: context, initialTime: _selectedTime ?? TimeOfDay.now());

    if (picked != null) {
      setState(() => _selectedTime = picked);
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      widget.onChanged(formatted);
    }
  }

  String? validator() {
    if (_isRequired && _selectedTime == null) {
      return '${widget.component.label} is required.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final displayText =
        _selectedTime != null ? _selectedTime!.format(context) : '';

    return FormField<String>(
      initialValue: widget.value,
      validator: (_) {
        if (_isRequired && _selectedTime == null) {
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
              hasContent: _selectedTime != null,
              onClear: () {
                setState(() => _selectedTime = null);
                widget.onChanged(null);
                field.didChange(null);
              },
              number: widget.fieldNumber,
              description: _description,
              tooltip: _tooltip,
            ),
            InkWell(
              onTap: _pickTime,
              child: InputDecorator(
                decoration: InputDecorationUtils.createDecoration(
                  context,
                  suffixIcon: const Icon(Icons.access_time),
                  errorText: field.errorText,
                ),
                child: Text(
                  displayText.isEmpty
                      ? ' ${_placeholder?.isEmpty ?? true ? '12:00' : _placeholder} '
                      : displayText,
                  style: displayText.isEmpty
                      ? TextStyle(
                          color: Theme.of(context)
                              .hintColor
                              .withValues(alpha: 0.6))
                      : Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
