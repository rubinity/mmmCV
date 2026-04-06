import 'package:flutter/material.dart';
import 'cv_section.dart';
import 'custom_section.dart' as custom_section;

class EducationSubsection extends custom_section.Subsection {
  EducationSubsection({
    required String name,
  }) : super(
          name: name,
          fieldGroups: [
            FieldGroup(
              title: 'Degree',
              fields: [
                FieldDefinition(
                  label: 'Institution',
                  type: FieldType.text,
                  width: 450,
                ),
                FieldDefinition(
                  label: 'City/Country',
                  type: FieldType.text,
                  width: 145,
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
                ),
                FieldDefinition(
                  label: 'Field of Study',
                  type: FieldType.text,
                  width: 188,
                ),
                FieldDefinition(
                  label: 'Start',
                  type: FieldType.text,
                  width: 100,
                ),
                FieldDefinition(
                  label: 'End',
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
                  width: 600,
                ),
              ],
            ),
          ],
        );
}
