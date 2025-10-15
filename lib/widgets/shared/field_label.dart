/// A reusable label widget for form fields that provides consistent styling
/// and handles required field indicators with an optional clear button.

import 'package:flutter/material.dart';

class FieldLabel extends StatelessWidget {
  /// The label text to display
  final String label;

  /// Whether the field is required (shows red asterisk)
  final bool isRequired;

  /// Optional padding around the label
  final EdgeInsetsGeometry? padding;

  /// Optional custom text style
  final TextStyle? style;

  /// Whether to show a clear button
  final bool showClearButton;

  /// Callback for clear button tap
  final VoidCallback? onClear;

  /// Whether there's content to clear
  final bool hasContent;

  /// Optional number to display before the label (e.g., "1. ")
  final int? number;

  /// Optional description text shown as a subtitle below the label
  final String? description;

  /// Optional tooltip text shown when tapping the info icon
  final String? tooltip;

  const FieldLabel({
    Key? key,
    required this.label,
    this.isRequired = false,
    this.padding,
    this.style,
    this.showClearButton = false,
    this.onClear,
    this.hasContent = false,
    this.number,
    this.description,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      if (number != null)
                        TextSpan(
                          text: '$number. ',
                          style: style ??
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                        ),
                      TextSpan(
                        text: label,
                        style: style ??
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                      ),
                      if (isRequired)
                        TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (tooltip != null && tooltip!.isNotEmpty)
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Tooltip(
                              message: tooltip!,
                              triggerMode: TooltipTriggerMode.tap,
                              showDuration: const Duration(seconds: 3),
                              child: Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.clear_all,
                    size: 18,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ],
          ),
          if (description != null && description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
