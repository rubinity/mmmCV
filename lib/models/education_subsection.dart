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
                  label: 'Degree',
                  type: FieldType.text,
                  width: 200,
                ),
                FieldDefinition(
                  label: 'Field of Study',
                  type: FieldType.text,
                  width: 200,
                ),
                FieldDefinition(
                  label: 'Institution',
                  type: FieldType.text,
                  width: 200,
                ),
              ],
            ),
            FieldGroup(
              title: 'Location & Duration',
              fields: [
                FieldDefinition(
                  label: 'City/Country',
                  type: FieldType.text,
                  width: 200,
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
                  width: 400,
                ),
              ],
            ),
          ],
        );

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title is hidden for internal use only
          const SizedBox(height: 4.0),
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            children: fieldGroups
                .map((group) => SizedBox(
                      width: 200,
                      child: group.build(context),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'fieldGroups': fieldGroups
          .map((group) => {
                'title': group.title,
                'fields': group.fields
                    .map((field) => {
                          'label': field.label,
                          'type': field.type.name,
                          'initialValue': field.initialValue,
                          'placeholder': field.placeholder,
                          'width': field.width,
                          'child': field.child?.toString(),
                        })
                    .toList(),
              })
          .toList(),
    };
  }

  List<TextEditingController> get allControllers {
    final controllers = <TextEditingController>[];
    for (final group in fieldGroups) {
      for (final field in group.fields) {
        if (field.controller != null) {
          controllers.add(field.controller!);
        }
      }
    }
    return controllers;
  }
}
