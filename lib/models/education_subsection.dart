import 'package:flutter/material.dart';
import 'cv_section.dart';
import 'custom_section.dart' as custom_section;

class EducationSubsection extends custom_section.Subsection {
  EducationSubsection({required String name})
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
                  controller:
                      TextEditingController(), // Each field has its own controller
                ),
                FieldDefinition(
                  label: 'City/Country',
                  type: FieldType.text,
                  width: 145,
                  controller:
                      TextEditingController(), // Each field has its own controller
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
                  controller:
                      TextEditingController(), // Each field has its own controller
                ),
                FieldDefinition(
                  label: 'Field of Study',
                  type: FieldType.text,
                  width: 188,
                  controller:
                      TextEditingController(), // Each field has its own controller
                ),
                FieldDefinition(
                  label: 'Start',
                  type: FieldType.text,
                  width: 100,
                  controller:
                      TextEditingController(), // Each field has its own controller
                ),
                FieldDefinition(
                  label: 'End',
                  type: FieldType.text,
                  width: 100,
                  controller:
                      TextEditingController(), // Each field has its own controller
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
                  controller:
                      TextEditingController(), // Each field has its own controller
                ),
              ],
            ),
          ],
        );
}
