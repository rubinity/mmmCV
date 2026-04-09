import 'package:flutter/material.dart';
import 'cv_section.dart';
import 'custom_section.dart' as custom_section;

class EducationSubsection extends custom_section.Subsection {
  EducationSubsection({required String name, List<String>? restoredValues})
      : super(
          name: name,
          fieldGroups: [
            FieldGroup(
              title: 'Degree',
              fields: [
                FieldDefinition(
                  label: 'Institution',
                  type: FieldType.text,
                  width: 450,
                  controller: restoredValues != null &&
                          restoredValues.isNotEmpty
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[0]))
                      : TextEditingController(), // Each field has its own controller
                ),
                FieldDefinition(
                  label: 'City/Country',
                  type: FieldType.text,
                  width: 145,
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
                  label: 'Degree',
                  type: FieldType.text,
                  width: 200,
                  controller: restoredValues != null &&
                          restoredValues.length > 2
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[2]))
                      : TextEditingController(), // Each field has its own controller
                ),
                FieldDefinition(
                  label: 'Field of Study',
                  type: FieldType.text,
                  width: 188,
                  controller: restoredValues != null &&
                          restoredValues.length > 3
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[3]))
                      : TextEditingController(), // Each field has its own controller
                ),
                FieldDefinition(
                  label: 'Start',
                  type: FieldType.text,
                  width: 100,
                  controller: restoredValues != null &&
                          restoredValues.length > 4
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[4]))
                      : TextEditingController(), // Each field has its own controller
                ),
                FieldDefinition(
                  label: 'End',
                  type: FieldType.text,
                  width: 100,
                  controller: restoredValues != null &&
                          restoredValues.length > 5
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[5]))
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
                  width: 600,
                  controller: restoredValues != null &&
                          restoredValues.length > 6
                      ? TextEditingController.fromValue(
                          TextEditingValue(text: restoredValues[6]))
                      : TextEditingController(), // Each field has its own controller
                ),
              ],
            ),
          ],
        );
}
