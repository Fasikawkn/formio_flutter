/// ComponentFactory maps Form.io component types to Flutter widgets.
///
/// Supports all standard, advanced, layout, data, and custom components.
/// Add new component types here as needed.

import 'package:flutter/material.dart';

import '../models/component.dart';
import '../models/file_data.dart';
import 'components/button_component.dart';
import 'components/captcha_component.dart';
import 'components/checkbox_component.dart';
import 'components/columns_component.dart';
import 'components/container_component.dart';
// import 'components/content_component.dart';
import 'components/currency_component.dart';
// Custom
// import 'components/custom_component.dart';
import 'components/data_grid_component.dart';
// import 'components/data_map_component.dart';
// Advanced
import 'components/datetime_component.dart';
import 'components/day_component.dart';
// import 'components/edit_grid_component.dart';
import 'components/email_component.dart';
import 'components/fieldset_component.dart';
// Premium
import 'components/file_component.dart';
// Data
import 'components/hidden_component.dart';
// import 'components/html_element_component.dart';
// import 'components/nested_form_component.dart';
import 'components/number_component.dart';
// Layout
import 'components/panel_component.dart';
// import 'components/password_component.dart';
import 'components/phone_number_component.dart';
import 'components/radio_component.dart';
import 'components/select_boxes_component.dart';
import 'components/select_component.dart';
import 'components/signature_component.dart';
import 'components/survey_component.dart';
import 'components/table_component.dart';
import 'components/tabs_component.dart';
import 'components/text_area_component.dart';
// Basic
import 'components/text_field_component.dart';
import 'components/time_component.dart';
// import 'components/well_component.dart';

typedef OnComponentChanged = void Function(dynamic value);
typedef OnFileChanged = void Function(String key, List<FileData> files);
typedef OnButtonPressed = void Function(String action);

class ComponentFactory {
  /// Evaluates whether a component should be shown based on its conditional logic.
  ///
  /// [component] - The component to check
  /// [formData] - The complete form data map containing all field values
  ///
  /// Returns true if the component should be shown, false otherwise.
  static bool shouldShowComponent(
    ComponentModel component,
    Map<String, dynamic> formData,
  ) {
    final condition = component.conditional;
    if (condition == null) return true;

    final when = condition['when'];
    final eq = condition['eq'];
    final show = condition['show'];

    if (when == null || when.toString().isEmpty) return true;

    final value = formData[when];

    // Handle selectboxes value format (Map<String, bool>)
    bool matches;
    if (value is Map) {
      // For selectboxes, check if the specific option is selected
      matches = value[eq] == true;
    } else {
      // For other component types, compare values directly
      matches = value?.toString() == eq?.toString();
    }

    // Default behavior is to show if matched
    final shouldShow = (show == true || show == 'true') ? matches : !matches;

    return shouldShow;
  }

  /// Creates the appropriate widget for a given component.
  static Widget build({
    required ComponentModel component,
    dynamic value,
    required OnComponentChanged onChanged,
    OnFileChanged? onFileChanged,
    OnButtonPressed? onPressed,
    int? fieldNumber,
    Map<String, dynamic>? formData,
  }) {
    // Note: Conditional logic is handled in FormRenderer, not here
    // The 'value' parameter here is the component's own value, not form data

    switch (component.type) {
      // Basic
      case 'textfield':
      case 'url':
        return TextFieldComponent(
            component: component,
            value: value,
            onChanged: onChanged,
            fieldNumber: fieldNumber);
      case 'textarea':
        return TextAreaComponent(
            component: component,
            value: value,
            onChanged: onChanged,
            fieldNumber: fieldNumber);
      case 'number':
        return NumberComponent(
            component: component,
            value: value,
            onChanged: onChanged,
            fieldNumber: fieldNumber);
      // case 'password':
      //   return PasswordComponent(
      //       component: component,
      //       value: value,
      //       onChanged: onChanged,
      //       fieldNumber: fieldNumber);
      case 'email':
        return EmailComponent(
            component: component,
            value: value,
            onChanged: onChanged,
            fieldNumber: fieldNumber);
      case 'phoneNumber':
        return PhoneNumberComponent(
            component: component, value: value, onChanged: onChanged);
      case 'checkbox':
        return CheckboxComponent(
            component: component, value: value == true, onChanged: onChanged);
      case 'radio':
        return RadioComponent(
            component: component, value: value, onChanged: onChanged);
      case 'select':
        return SelectComponent(
            component: component,
            value: value,
            onChanged: onChanged,
            fieldNumber: fieldNumber);
      case 'selectboxes':
        return SelectBoxesComponent(
            component: component,
            value: value is Map<String, bool> ? value : <String, bool>{},
            onChanged: onChanged);
      case 'button':
        return ButtonComponent(
            component: component,
            onPressed: onPressed ?? (_) {},
            isDisabled: false);

      // Advanced
      case 'datetime':
        return DateTimeComponent(
            component: component, value: value, onChanged: onChanged);
      case 'day':
        return DayComponent(
            component: component, value: value, onChanged: onChanged);
      case 'time':
        return TimeComponent(
            component: component, value: value, onChanged: onChanged);
      case 'currency':
        return CurrencyComponent(
            component: component, value: value, onChanged: onChanged);
      case 'survey':
        return SurveyComponent(
            component: component,
            value: value is Map<String, String> ? value : <String, String>{},
            onChanged: onChanged);
      case 'signature':
        return SignatureComponent(
            component: component, value: value, onChanged: onChanged);

      // Data
      case 'hidden':
        return HiddenComponent(
            component: component, value: value, onChanged: onChanged);
      case 'container':
        return ContainerComponent(
            component: component,
            value: value is Map<String, dynamic> ? value : {},
            onChanged: onChanged,
            onPressed: onPressed,
            formData: formData);
      // case 'datamap':
      //   return DataMapComponent(
      //       component: component,
      //       value: value is Map<String, String> ? value : {},
      //       onChanged: onChanged);
      case 'datagrid':
        return DataGridComponent(
            component: component,
            value: value is List<Map<String, dynamic>> ? value : [],
            onChanged: onChanged,
            onPressed: onPressed);
      // case 'editgrid':
      //   return EditGridComponent(
      //       component: component,
      //       value: value is List<Map<String, dynamic>> ? value : [],
      //       onChanged: onChanged);

      // Layout
      case 'panel':
        return PanelComponent(
            component: component,
            value: value is Map<String, dynamic> ? value : {},
            onChanged: onChanged,
            onPressed: onPressed,
            formData: formData);
      case 'columns':
        return ColumnsComponent(
            component: component,
            value: value is Map<String, dynamic> ? value : {},
            onChanged: onChanged,
            onPressed: onPressed,
            formData: formData);
      // case 'htmlelement':
      //   return HtmlElementComponent(component: component);
      // case 'content':
      //   return ContentComponent(component: component);
      case 'fieldset':
        return FieldSetComponent(
            component: component,
            value: value is Map<String, dynamic> ? value : {},
            onChanged: onChanged,
            onPressed: onPressed,
            formData: formData);
      case 'table':
        return TableComponent(
            component: component,
            value: value is Map<String, dynamic> ? value : {},
            onChanged: onChanged,
            onPressed: onPressed,
            formData: formData);
      case 'tabs':
        return TabsComponent(
            component: component,
            value: value is Map<String, dynamic> ? value : {},
            onChanged: onChanged,
            onPressed: onPressed,
            formData: formData);
      // case 'well':
      //   return WellComponent(
      //       component: component,
      //       value: value is Map<String, dynamic> ? value : {},
      //       onChanged: onChanged);

      // Premium
      case 'file':
        return FileComponent(
            component: component,
            value: value is List<FileData>
                ? value
                : (value is List
                    ? value
                        .whereType<Map<String, dynamic>>()
                        .map((e) => FileData.fromJson(e))
                        .toList()
                    : []),
            onChanged: (files) {
              onFileChanged?.call(component.key, files);
            });
      // case 'nestedform':
      //   return NestedFormComponent(
      //       component: component,
      //       value: value is Map<String, dynamic> ? value : {},
      //       onChanged: onChanged);
      case 'captcha':
        return CaptchaComponent(
            component: component, value: value, onChanged: onChanged);

      // Custom
      // case 'custom':
      //   return CustomComponent(
      //       component: component, value: value, onChanged: onChanged);

      // Fallback
      default:
        return SizedBox.shrink();
    }
  }
}
