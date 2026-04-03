import 'package:flutter/material.dart';
import 'cv_section.dart';
import 'education_subsection.dart';

class Subsection {
  final String name;
  final List<FieldGroup> fieldGroups;

  Subsection({
    required this.name,
    required this.fieldGroups,
  });

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title is hidden for internal use only
          const SizedBox(height: 4.0),
          ...fieldGroups.map((group) => group.build(context)).toList(),
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

enum SubsectionType {
  generic,
  education,
  experience,
}

class CustomSection extends StatefulWidget {
  final String sectionName;
  final List<Subsection>? initialSubsections;
  final SubsectionType subsectionType;
  final VoidCallback? onRemoveSection;

  const CustomSection({
    super.key,
    required this.sectionName,
    this.initialSubsections,
    required this.subsectionType,
    this.onRemoveSection,
  });

  @override
  State<CustomSection> createState() => _CustomSectionState();
}

class _CustomSectionState extends State<CustomSection> {
  late List<Subsection> subsections;

  @override
  void initState() {
    super.initState();
    // Initialize with provided subsections or create default
    subsections = widget.initialSubsections ??
        [
          Subsection(
            name: '${widget.sectionName} Entry 1',
            fieldGroups: [],
          ),
        ];
  }

  void addSubsection() {
    setState(() {
      Subsection newSubsection;

      switch (widget.subsectionType) {
        case SubsectionType.education:
          newSubsection = EducationSubsection(
            name: '${widget.sectionName} Entry ${subsections.length + 1}',
          );
          break;
        case SubsectionType.experience:
          newSubsection = Subsection(
            name: '${widget.sectionName} Entry ${subsections.length + 1}',
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
                title: 'Duration',
                fields: [
                  FieldDefinition(
                    label: 'Start Date',
                    type: FieldType.text,
                    width: 150,
                  ),
                  FieldDefinition(
                    label: 'End Date',
                    type: FieldType.text,
                    width: 150,
                  ),
                ],
              ),
            ],
          );
          break;
        default:
          newSubsection = Subsection(
            name: '${widget.sectionName} Entry ${subsections.length + 1}',
            fieldGroups: [],
          );
          break;
      }

      subsections.add(newSubsection);
    });
  }

  void removeSubsection(int index) {
    setState(() {
      subsections.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title and remove button in same line
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.sectionName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (widget.onRemoveSection != null)
                  ElevatedButton(
                    onPressed: widget.onRemoveSection,
                    child: const Text('Remove Section'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...subsections
                .map((subsection) => subsection.build(context))
                .toList(),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => addSubsection(),
                  child: const Text('Add Entry'),
                ),
                const SizedBox(width: 8),
                if (subsections.length > 1)
                  ElevatedButton(
                    onPressed: () => removeSubsection(subsections.length - 1),
                    child: const Text('Remove Last Entry'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sectionName': widget.sectionName,
      'subsections': subsections.map((s) => s.toMap()).toList(),
    };
  }

  List<TextEditingController> get allControllers {
    final controllers = <TextEditingController>[];
    for (final subsection in subsections) {
      controllers.addAll(subsection.allControllers);
    }
    return controllers;
  }
}
