import 'package:flutter/material.dart';
import 'cv_section.dart';
import 'custom_section.dart' as custom_section;

class SimplestSubsection extends custom_section.Subsection {
  SimplestSubsection({
    required String name,
    List<String>? restoredValues,
  }) : super(
          name: name,
          fieldGroups: [
            FieldGroup(
              title: 'Description',
              fields: [
                FieldDefinition(
                  label: 'Description',
                  type: FieldType.multiline,
                  width: 600,
                  controller:
                      restoredValues != null && restoredValues.isNotEmpty
                          ? TextEditingController.fromValue(
                              TextEditingValue(text: restoredValues[0]))
                          : TextEditingController(),
                ),
              ],
            ),
          ],
        );
}
