/// A Flutter widget that renders day, month, and year dropdowns
/// based on a Form.io "day" component.
///
/// Allows users to select a date by separately choosing the day,
/// month, and year. The result is returned as a single ISO-8601 string.

import 'package:flutter/material.dart';

import '../../models/component.dart';
import '../shared/field_label.dart';
import '../shared/input_decoration_utils.dart';

class DayComponent extends StatefulWidget {
  /// The Form.io component definition.
  final ComponentModel component;

  /// The current ISO-8601 date string (yyyy-MM-dd).
  final String? value;

  /// Callback called when the date changes.
  final ValueChanged<String?> onChanged;

  /// Optional field number to display before the label
  final int? fieldNumber;

  const DayComponent({
    Key? key,
    required this.component,
    required this.value,
    required this.onChanged,
    this.fieldNumber,
  }) : super(key: key);

  @override
  State<DayComponent> createState() => _DayComponentState();
}

class _DayComponentState extends State<DayComponent> {
  int? _day;
  int? _month;
  int? _year;

  bool get _isRequired => widget.component.required;

  int get _startYear => widget.component.raw['fields']?['year']?['min'] ?? 1900;
  int get _endYear =>
      widget.component.raw['fields']?['year']?['max'] ??
      DateTime.now().year + 10;

  /// Retrieves the description text if available in the raw JSON.
  String? get _description => widget.component.raw['description'];

  /// Retrieves the tooltip text if available in the raw JSON.
  String? get _tooltip => widget.component.raw['tooltip'];

  void _updateValue() {
    if (_day != null && _month != null && _year != null) {
      final formatted =
          '${_year!.toString().padLeft(4, '0')}-${_month!.toString().padLeft(2, '0')}-${_day!.toString().padLeft(2, '0')}';
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

  String? validator() {
    if (_isRequired && (_day == null || _month == null || _year == null)) {
      return '${widget.component.label} is required.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasContent = _day != null || _month != null || _year != null;

    return FormField<String>(
      initialValue: widget.value,
      validator: (_) {
        if (_isRequired && (_day == null || _month == null || _year == null)) {
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
                setState(() {
                  _day = null;
                  _month = null;
                  _year = null;
                });
                _updateValue();
                field.didChange(null);
              },
              number: widget.fieldNumber,
              description: _description,
              tooltip: _tooltip,
            ),
            Row(
              children: [
                // Day
                Flexible(
                  child: DropdownButtonFormField<int>(
                    value: _day,
                    alignment: Alignment.center,
                    icon: SizedBox.shrink(),
                    style: InputDecorationUtils.getDropdownStyle(fontSize: 14),
                    decoration: InputDecorationUtils.createDropdownDecoration(
                      context,
                      hintText: 'Day',
                    ),
                    items: List.generate(31, (i) => i + 1)
                        .map((d) => DropdownMenuItem(
                            value: d, child: Text(d.toString())))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _day = val);
                      _updateValue();
                      field.didChange(widget.value);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Month
                Flexible(
                  child: DropdownButtonFormField<int>(
                    value: _month,
                    alignment: Alignment.center,
                    icon: SizedBox.shrink(),
                    style: InputDecorationUtils.getDropdownStyle(fontSize: 14),
                    decoration: InputDecorationUtils.createDropdownDecoration(
                      context,
                      hintText: 'Month',
                    ),
                    items: List.generate(12, (i) => i + 1)
                        .map((m) => DropdownMenuItem(
                            value: m, child: Text(m.toString())))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _month = val);
                      _updateValue();
                      field.didChange(widget.value);
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Year
                Flexible(
                  child: DropdownButtonFormField<int>(
                    value: _year,
                    alignment: Alignment.center,
                    icon: SizedBox.shrink(),
                    style: InputDecorationUtils.getDropdownStyle(fontSize: 14),
                    decoration: InputDecorationUtils.createDropdownDecoration(
                      context,
                      hintText: 'Year',
                    ),
                    items: List.generate(
                            _endYear - _startYear + 1, (i) => _endYear - i)
                        .map((y) => DropdownMenuItem(
                            value: y, child: Text(y.toString())))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _year = val);
                      _updateValue();
                      field.didChange(widget.value);
                    },
                  ),
                ),
              ],
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
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
