/// A Flutter widget that renders a date and/or time picker based on a Form.io "datetime" component.
///
/// Supports label, placeholder, required validation, default value, and configuration for date, time, or both.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';
import '../shared/input_decoration_utils.dart';

class DateTimeComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current selected DateTime value.
  final String? value;

  /// Callback triggered when the user selects a new date/time.
  final ValueChanged<String?> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const DateTimeComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.fieldNumber,
  }) : super(key: key);

  @override
  State<DateTimeComponent> createState() => _DateTimeComponentState();
}

class _DateTimeComponentState extends State<DateTimeComponent> {
  late TextEditingController _controller;

  /// Whether the field is marked as required.
  bool get _isRequired => widget.component.required;

  /// Placeholder text for the input field.
  String? get _placeholder => widget.component.raw['placeholder'];

  /// Determines if the picker should include time selection.
  bool get _enableTime => widget.component.raw['widget']['enableTime'] ?? false;

  /// Determines if the picker should include date selection.
  bool get _enableDate => widget.component.raw['enableDate'] ?? true;

  /// Retrieves the description text if available in the raw JSON.
  String? get _description => widget.component.raw['description'];

  /// Retrieves the tooltip text if available in the raw JSON.
  String? get _tooltip => widget.component.raw['tooltip'];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: widget.value != null
            ? _formatDateTime(DateTime.parse(widget.value!))
            : '');
  }

  @override
  void didUpdateWidget(covariant DateTimeComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value != null
          ? _formatDateTime(DateTime.parse(widget.value!))
          : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Formats the DateTime object into a string based on the specified format.
  String _formatDateTime(DateTime dateTime) {
    if (_enableTime && _enableDate) {
      // Show both date and time: "2025-10-28 12:00 PM"
      return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
    } else if (_enableTime) {
      // Show only time: "12:00 PM"
      return DateFormat('hh:mm a').format(dateTime);
    } else {
      // Show only date: "2025-10-28"
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
  }

  /// Validates the input based on requirement.
  String? validator(String? input) {
    if (_isRequired && (input == null || input.isEmpty)) {
      return '${widget.component.label} is required.';
    }
    return null;
  }

  /// Handles the date/time picker dialog.
  Future<void> _handlePick(BuildContext context) async {
    DateTime? selectedDateTime;

    if (_enableDate && _enableTime) {
      // Show both date and time picker
      selectedDateTime = await showOmniDateTimePicker(
        context: context,
        initialDate: widget.value != null
            ? DateTime.parse(widget.value!)
            : DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        is24HourMode: false,
        isShowSeconds: false,
        minutesInterval: 1,
        borderRadius: BorderRadius.circular(16),
      );
    } else if (_enableDate) {
      // Show only date picker
      selectedDateTime = await showOmniDateTimePicker(
        context: context,
        initialDate: widget.value != null
            ? DateTime.parse(widget.value!)
            : DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        type: OmniDateTimePickerType.date,
        borderRadius: BorderRadius.circular(16),
      );
    } else if (_enableTime) {
      // Show only time picker
      selectedDateTime = await showOmniDateTimePicker(
        context: context,
        initialDate: widget.value != null
            ? DateTime.parse(widget.value!)
            : DateTime.now(),
        type: OmniDateTimePickerType.time,
        is24HourMode: false,
        isShowSeconds: false,
        minutesInterval: 1,
        borderRadius: BorderRadius.circular(16),
      );
    }

    if (selectedDateTime != null) {
      widget.onChanged(selectedDateTime.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasContent = widget.value != null;

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
            _controller.clear();
            widget.onChanged(null);
          },
          number: widget.fieldNumber,
          description: _description,
          tooltip: _tooltip,
        ),
        TextFormField(
          controller: _controller,
          readOnly: true,
          decoration: InputDecorationUtils.createDecoration(
            context,
            hintText: _placeholder ?? 'Select date/time...',
            suffixIcon: Icon(
              _enableTime && _enableDate
                  ? Icons.calendar_today
                  : _enableTime
                      ? Icons.access_time
                      : Icons.calendar_today,
            ),
          ),
          onTap: () => _handlePick(context),
          validator: (value) {
            if (_isRequired && (value == null || value.isEmpty)) {
              return '${widget.component.label} is required.';
            }
            return null;
          },
        ),
      ],
    );
  }
}
