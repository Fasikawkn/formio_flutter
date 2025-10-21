/// Utility class for creating consistent input decorations across all form components.
/// Provides modern, accessible styling with proper focus states and error handling.

import 'package:flutter/material.dart';

class InputDecorationUtils {
  /// Creates a modern, consistent input decoration for form fields
  static InputDecoration createDecoration(
    BuildContext context, {
    String? hintText,
    String? errorText,
    Widget? suffixIcon,
    TextStyle? hintStyle,
  }) {
    final theme = Theme.of(context);
    final borderColor = Colors.grey.withValues(alpha: 0.3);

    return InputDecoration(
      hintText: hintText,
      errorText: errorText,
      hintStyle: hintStyle ??
          TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: borderColor,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.primaryColor,
          width: 1,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.colorScheme.error,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.colorScheme.error,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  /// Creates a decoration specifically for dropdown/select components
  static InputDecoration createDropdownDecoration(
    BuildContext context, {
    String? hintText,
    String? errorText,
  }) {
    return createDecoration(
      context,
      hintText: hintText,
      errorText: errorText,
      hintStyle: TextStyle(
        color: Colors.grey,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      suffixIcon: const Icon(Icons.keyboard_arrow_down),
    );
  }

  /// Gets the default text style for dropdown items and hints
  /// Use this with DropdownButtonFormField's `style` property
  static TextStyle getDropdownStyle({
    Color? color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return TextStyle(
      color: color ?? Colors.black87,
      fontSize: fontSize,
      fontWeight: fontWeight,
      overflow: TextOverflow.ellipsis
    );
  }
}
