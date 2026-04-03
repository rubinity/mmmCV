import 'package:flutter/material.dart';
import 'cv_section.dart';
import 'custom_section.dart' as custom_section;

class ExperienceSubsection extends custom_section.Subsection {
  ExperienceSubsection({
    required String name,
  }) : super(
          name: name,
          fieldGroups: [
            FieldGroup(
              title: 'Position',
              fields: [
                FieldDefinition(
                  label: 'Job Title',
                  type: FieldType.text,
                  width: 300,
                ),
                FieldDefinition(
                  label: 'Company',
                  type: FieldType.text,
                  width: 300,
                ),
              ],
            ),
            FieldGroup(
              title: 'Location & Duration',
              fields: [
                FieldDefinition(
                  label: 'City/Country',
                  type: FieldType.text,
                  width: 150,
                ),
                FieldDefinition(
                  label: 'Start Date',
                  type: FieldType.text,
                  width: 100,
                ),
                FieldDefinition(
                  label: 'End Date',
                  type: FieldType.text,
                  width: 100,
                ),
              ],
            ),
            FieldGroup(
              title: 'Description',
              fields: [
                FieldDefinition(
                  label: 'Description',
                  type: FieldType.multiline,
                  width: 400,
                ),
              ],
            ),
          ],
        );
}
