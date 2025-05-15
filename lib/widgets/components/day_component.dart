/// A Flutter widget that renders day, month, and year dropdowns
/// based on a Form.io "day" component.
///
/// Allows users to select a date by separately choosing the day,
/// month, and year. The result is returned as a single ISO-8601 string.

import 'package:flutter/material.dart';

import '../../models/component.dart';

class DayComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current ISO-8601 date string (yyyy-MM-dd).
  final String? value;

  /// Callback called when the date changes.
  final ValueChanged<String?> onChanged;

  const DayComponent({Key? key, required this.component, required this.value, required this.onChanged}) : super(key: key);

  @override
  State<DayComponent> createState() => _DayComponentState();
}

class _DayComponentState extends State<DayComponent> {
  int? _day;
  int? _month;
  int? _year;

  bool get _isRequired => widget.component.required;

  int get _startYear => widget.component.raw['fields']?['year']?['min'] ?? 1900;
  int get _endYear => widget.component.raw['fields']?['year']?['max'] ?? DateTime.now().year;

  void _updateValue() {
    if (_day != null && _month != null && _year != null) {
      final formatted = '${_year!.toString().padLeft(4, '0')}-${_month!.toString().padLeft(2, '0')}-${_day!.toString().padLeft(2, '0')}';
      widget.onChanged(formatted);
    } else {
      widget.onChanged(null);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      final parts = widget.value!.split('-');
      if (parts.length == 3) {
        _year = int.tryParse(parts[0]);
        _month = int.tryParse(parts[1]);
        _day = int.tryParse(parts[2]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _isRequired && (_day == null || _month == null || _year == null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.component.label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            // Day
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _day,
                decoration: const InputDecoration(labelText: 'Day'),
                items: List.generate(31, (i) => i + 1).map((d) => DropdownMenuItem(value: d, child: Text(d.toString()))).toList(),
                onChanged: (val) {
                  setState(() => _day = val);
                  _updateValue();
                },
              ),
            ),
            const SizedBox(width: 8),

            // Month
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _month,
                decoration: const InputDecoration(labelText: 'Month'),
                items: List.generate(12, (i) => i + 1).map((m) => DropdownMenuItem(value: m, child: Text(m.toString()))).toList(),
                onChanged: (val) {
                  setState(() => _month = val);
                  _updateValue();
                },
              ),
            ),
            const SizedBox(width: 8),

            // Year
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _year,
                decoration: const InputDecoration(labelText: 'Year'),
                items: List.generate(_endYear - _startYear + 1, (i) => _endYear - i).map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                onChanged: (val) {
                  setState(() => _year = val);
                  _updateValue();
                },
              ),
            ),
          ],
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
