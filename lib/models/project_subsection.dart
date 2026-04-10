import 'package:flutter/material.dart';
import 'cv_section.dart';
import 'custom_section.dart' as custom_section;

class ProjectSubsection extends custom_section.Subsection {
  ProjectSubsection({required String name, List<String>? restoredValues})
      : super(
          name: name,
          fieldGroups: [
            FieldGroup(
              title: 'Project Details',
              fields: [
                FieldDefinition(
                  label: 'Project Name',
                  type: FieldType.text,
                  width: 300,
                  controller: restoredValues != null &&
                          restoredValues.isNotEmpty
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[0]))
                      : TextEditingController(),
                ),
                FieldDefinition(
                  label: 'Start',
                  type: FieldType.text,
                  width: 120,
                  controller: restoredValues != null &&
                          restoredValues.length > 1
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[1]))
                      : TextEditingController(),
                ),
                FieldDefinition(
                  label: 'End',
                  type: FieldType.text,
                  width: 120,
                  controller: restoredValues != null &&
                          restoredValues.length > 2
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[2]))
                      : TextEditingController(),
                ),
              ],
            ),
            FieldGroup(
              title: 'Description',
              fields: [
                FieldDefinition(
                  label: 'Description',
                  type: FieldType.multiline,
                  width: 600,
                  controller: restoredValues != null &&
                          restoredValues.length > 3
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[3]))
                      : TextEditingController(),
                ),
              ],
            ),
          ],
        );
}
