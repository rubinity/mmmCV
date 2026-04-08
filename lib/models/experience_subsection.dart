import 'package:flutter/material.dart';
import 'cv_section.dart';
import 'custom_section.dart' as custom_section;

class ExperienceSubsection extends custom_section.Subsection {
  ExperienceSubsection({required String name})
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
                  controller:
                      TextEditingController(), // Each field has its own controller
                ),
                FieldDefinition(
                  label: 'City/Country',
                  type: FieldType.text,
                  width: 140,
                  controller:
                      TextEditingController(), // Each field has its own controller
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
                  controller:
                      TextEditingController(), // Each field has its own controller
                ),
                FieldDefinition(
                  label: 'Start Date',
                  type: FieldType.text,
                  width: 100,
                  controller:
                      TextEditingController(), // Each field has its own controller
                ),
                FieldDefinition(
                  label: 'End Date',
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
                  width: 408,
                  controller:
                      TextEditingController(), // Each field has its own controller
                ),
              ],
            ),
          ],
        );
}
