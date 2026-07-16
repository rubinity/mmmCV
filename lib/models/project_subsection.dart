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
                  label: 'Affiliation',
                  type: FieldType.text,
                  width: 200,
                  controller: restoredValues != null &&
                          restoredValues.isNotEmpty
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[0]))
                      : TextEditingController(), // Each field has its own controller
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
              title: 'Name & URL',
              fields: [
                FieldDefinition(
                  label: 'Name',
                  type: FieldType.text,
                  width: 300,
                  controller: restoredValues != null &&
                          restoredValues.length > 3
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[3]))
                      : TextEditingController(),
                ),
                FieldDefinition(
                  label: 'URL',
                  type: FieldType.url,
                  width: 250,
                  controller: restoredValues != null &&
                          restoredValues.length > 4
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[4]))
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
                          restoredValues.length > 5
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[5]))
                      : TextEditingController(),
                ),
              ],
            ),
          ],
        );
}
