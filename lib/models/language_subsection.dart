import 'package:flutter/material.dart';
import 'cv_section.dart';
import 'custom_section.dart' as custom_section;

class LanguageSubsection extends custom_section.Subsection {
  LanguageSubsection({
    required String name,
    List<String>? restoredValues,
  }) : super(
          name: name,
          fieldGroups: [
            FieldGroup(
              title: 'Language',
              fields: [
                FieldDefinition(
                  label: 'Language',
                  type: FieldType.text,
                  width: 300,
                  controller:
                      restoredValues != null && restoredValues.isNotEmpty
                          ? TextEditingController.fromValue(
                              TextEditingValue(text: restoredValues[0]))
                          : TextEditingController(),
                ),
                FieldDefinition(
                  label: 'Level',
                  type: FieldType.dropdown,
                  width: 200,
                  controller:
                      restoredValues != null && restoredValues.length > 1
                          ? TextEditingController.fromValue(
                              TextEditingValue(text: restoredValues[1]))
                          : TextEditingController(text: 'beginner'),
                  dropdownItems: const [
                    DropdownMenuItem(
                        value: 'beginner', child: Text('Beginner')),
                    DropdownMenuItem(
                        value: 'intermediate', child: Text('Intermediate')),
                    DropdownMenuItem(
                        value: 'advanced', child: Text('Advanced')),
                    DropdownMenuItem(value: 'fluent', child: Text('Fluent')),
                    DropdownMenuItem(value: 'native', child: Text('Native')),
                  ],
                ),
              ],
            ),
          ],
        );
}
