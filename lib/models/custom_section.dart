import 'package:flutter/material.dart';
import 'cv_section.dart';

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

class CustomSection extends CvSection {
  List<Subsection> subsections = [];

  CustomSection({
    required String sectionName,
    List<Subsection>? subsections,
  }) : super(sectionName: sectionName, type: 'custom') {
    // Automatically create first subsection if none provided
    this.subsections = subsections ??
        [
          Subsection(
            name: '${sectionName} Entry 1',
            fieldGroups: [],
          ),
        ];
  }

  void addSubsection() {
    final newSubsection = Subsection(
      name: '${sectionName} Entry ${subsections.length + 1}',
      fieldGroups: [],
    );
    subsections.add(newSubsection);
  }

  void removeSubsection(int index) {
    subsections.removeAt(index);
    // When no subsections remain, notify parent to remove this section
  }

  void removeSection() {
    // This section should be removed by parent (SectionBoard)
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sectionName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  @override
  Map<String, dynamic> toMap() {
    return {
      'sectionName': sectionName,
      'type': type,
      'subsections': subsections.map((s) => s.toMap()).toList(),
    };
  }

  @override
  List<TextEditingController> get allControllers {
    final controllers = <TextEditingController>[];
    for (final subsection in subsections) {
      controllers.addAll(subsection.allControllers);
    }
    return controllers;
  }
}
