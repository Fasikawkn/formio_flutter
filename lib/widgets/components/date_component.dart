/// A Flutter widget that renders a date/time picker based on a Form.io "datetime" component.
///
/// Supports picking date, time, or both depending on the `enableTime` and `enableDate` flags.
/// Handles required validation and provides a formatted string as the selected value.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';
import '../shared/input_decoration_utils.dart';

class DateComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The currently selected ISO-8601 datetime string.
  final String? value;

  /// Callback triggered when the datetime value changes.
  final ValueChanged<String?> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const DateComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.fieldNumber,
  }) : super(key: key);

  @override
  State<DateComponent> createState() => _DateComponentState();
}

class _DateComponentState extends State<DateComponent> {
  DateTime? _selectedDateTime;

  bool get _isRequired => widget.component.required;

  bool get _enableDate => widget.component.raw['enableDate'] != false;
  bool get _enableTime => widget.component.raw['enableTime'] == true;

  String? get _placeholder => widget.component.raw['placeholder'];

  /// Retrieves the description text if available in the raw JSON.
  String? get _description => widget.component.raw['description'];

  /// Retrieves the tooltip text if available in the raw JSON.
  String? get _tooltip => widget.component.raw['tooltip'];

  String _formatDateTime(DateTime dateTime) {
    if (_enableDate && _enableTime) {
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } else if (_enableTime) {
      return DateFormat('HH:mm').format(dateTime);
    } else {
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
  }

  Future<void> _pickDateTime() async {
    DateTime? date;
    TimeOfDay? time;

    if (_enableDate) {
      date = await showDatePicker(
          context: context,
          initialDate: _selectedDateTime ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100));
      if (date == null) return;
    }

    if (_enableTime) {
      time = await showTimePicker(
          context: context,
          initialTime:
              TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()));
      if (time == null && !_enableDate) return;
    }

    DateTime finalDateTime;
    if (_enableDate && _enableTime) {
      finalDateTime =
          DateTime(date!.year, date.month, date.day, time!.hour, time.minute);
    } else if (_enableDate) {
      finalDateTime = date!;
    } else {
      final now = DateTime.now();
      finalDateTime =
          DateTime(now.year, now.month, now.day, time!.hour, time.minute);
    }

    setState(() {
      _selectedDateTime = finalDateTime;
    });
    widget.onChanged(finalDateTime.toIso8601String());
  }

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      _selectedDateTime = DateTime.tryParse(widget.value!);
    }
  }

  String? _validator() {
    if (_isRequired && _selectedDateTime == null) {
      return '${widget.component.label} is required.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final displayValue =
        _selectedDateTime != null ? _formatDateTime(_selectedDateTime!) : '';
    final error = _validator();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FieldLabel(
          label: widget.component.label,
          isRequired: _isRequired,
          showClearButton: true,
          hasContent: _selectedDateTime != null,
          onClear: () {
            setState(() => _selectedDateTime = null);
            widget.onChanged(null);
          },
          number: widget.fieldNumber,
          description: _description,
          tooltip: _tooltip,
        ),
        InkWell(
          onTap: _pickDateTime,
          child: InputDecorator(
            decoration: InputDecorationUtils.createDecoration(
              context,
              hintText: _placeholder ?? 'Select date...',
              errorText: error,
              suffixIcon: Icon(_enableTime && _enableDate
                  ? Icons.calendar_today
                  : _enableTime
                      ? Icons.access_time
                      : Icons.calendar_today),
            ),
            child: Text(
              displayValue.isEmpty ? ' ' : displayValue,
              style: displayValue.isEmpty
                  ? TextStyle(
                      color: Theme.of(context).hintColor.withValues(alpha: 0.6))
                  : Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}
