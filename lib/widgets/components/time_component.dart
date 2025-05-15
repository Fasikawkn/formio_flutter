/// A Flutter widget that renders a time picker based on a Form.io "time" component.
///
/// Only allows time selection (hour and minute). Supports required validation,
/// default value, and formatted display.

import 'package:flutter/material.dart';

import '../../models/component.dart';

class TimeComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current selected time value in "HH:mm" format.
  final String? value;

  /// Callback called when the time changes.
  final ValueChanged<String?> onChanged;

  const TimeComponent({Key? key, required this.component, required this.value, required this.onChanged}) : super(key: key);

  @override
  State<TimeComponent> createState() => _TimeComponentState();
}

class _TimeComponentState extends State<TimeComponent> {
  TimeOfDay? _selectedTime;

  bool get _isRequired => widget.component.required;
  String? get _placeholder => widget.component.raw['placeholder'];

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
    final picked = await showTimePicker(context: context, initialTime: _selectedTime ?? TimeOfDay.now());

    if (picked != null) {
      setState(() => _selectedTime = picked);
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      widget.onChanged(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _isRequired && _selectedTime == null;
    final displayText = _selectedTime != null ? _selectedTime!.format(context) : (_placeholder ?? 'Select time');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.component.label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        InkWell(
          onTap: _pickTime,
          child: InputDecorator(decoration: InputDecoration(hintText: _placeholder ?? 'HH:mm', border: const OutlineInputBorder()), child: Text(displayText)),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('${widget.component.label} is required.', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ),
      ],
    );
  }
}
