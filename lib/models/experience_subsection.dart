import 'package:flutter/material.dart';
import 'cv_section.dart';
import 'custom_section.dart' as custom_section;

class ExperienceSubsection extends custom_section.Subsection {
  ExperienceSubsection({required String name, List<String>? restoredValues})
      : super(
          name: name,
          fieldGroups: [
            FieldGroup(
              title: 'Position',
              fields: [
                FieldDefinition(
                  label: 'Company',
                  type: FieldType.text,
                  width: 264,
                  controller: restoredValues != null &&
                          restoredValues.isNotEmpty
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[0]))
                      : TextEditingController(), // Each field has its own controller
                ),
                FieldDefinition(
                  label: 'City/Country',
                  type: FieldType.text,
                  width: 140,
                  controller: restoredValues != null &&
                          restoredValues.length > 1
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[1]))
                      : TextEditingController(), // Each field has its own controller
                ),
              ],
            ),
            FieldGroup(
              title: 'Location & Duration',
              fields: [
                FieldDefinition(
                  label: 'Job Title',
                  type: FieldType.text,
                  width: 200,
                  controller: restoredValues != null &&
                          restoredValues.length > 2
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[2]))
                      : TextEditingController(), // Each field has its own controller
                ),
                FieldDefinition(
                  label: 'Start Date',
                  type: FieldType.text,
                  width: 100,
                  controller: restoredValues != null &&
                          restoredValues.length > 3
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[3]))
                      : TextEditingController(), // Each field has its own controller
                ),
                FieldDefinition(
                  label: 'End Date',
                  type: FieldType.text,
                  width: 100,
                  controller: restoredValues != null &&
                          restoredValues.length > 4
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[4]))
                      : TextEditingController(), // Each field has its own controller
                ),
              ],
            ),
            FieldGroup(
              title: 'Description',
              fields: [
                FieldDefinition(
                  label: 'Description',
                  type: FieldType.multiline,
                  width: 408,
                  controller: restoredValues != null &&
                          restoredValues.length > 5
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[5]))
                      : TextEditingController(), // Each field has its own controller
                ),
              ],
            ),
          ],
        );
}
