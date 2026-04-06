import 'package:flutter/material.dart';
import 'cv_section.dart';
import 'education_subsection.dart';
import 'experience_subsection.dart';

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
  final GlobalKey<CustomSectionState>? sectionKey;

  const CustomSection({
    super.key,
    required this.sectionName,
    this.initialSubsections,
    required this.subsectionType,
    this.onRemoveSection,
    this.sectionKey,
  });

  @override
  State<CustomSection> createState() => CustomSectionState();
}

class CustomSectionState extends State<CustomSection> {
  Map<int, Subsection> subsections = {};

  @override
  void initState() {
    super.initState();
    // Initialize with provided subsections or create default
    if (widget.initialSubsections != null) {
      for (int i = 0; i < widget.initialSubsections!.length; i++) {
        subsections[i] = widget.initialSubsections![i];
      }
    } else {
      subsections[0] = Subsection(
        name: '${widget.sectionName} Entry 1',
        fieldGroups: [],
      );
    }
  }

  void addSubsection() {
    setState(() { 
      Subsection newSubsection;
      final newKey = subsections.length;

      switch (widget.subsectionType) {
        case SubsectionType.education:
          newSubsection = EducationSubsection(
            name: '${widget.sectionName} Entry ${newKey + 1}',
          );
          break;
        case SubsectionType.experience:
          newSubsection = ExperienceSubsection(
            name: '${widget.sectionName} Entry ${newKey + 1}',
          );
          break;
        default:
          newSubsection = Subsection(
            name: '${widget.sectionName} Entry ${newKey + 1}',
            fieldGroups: [],
          );
          break;
      }

      subsections[newKey] = newSubsection;
    });
  }

  void removeSubsection(int key) {
    setState(() {
      subsections.remove(key);
      // Renumber remaining keys
      final newMap = <int, Subsection>{};
      int newKey = 0;
      final sortedEntries = subsections.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      for (final entry in sortedEntries) {
        newMap[newKey++] = entry.value;
      }
      subsections = newMap;
    });
  }

  void moveUp(int key) {
    if (key > 0) {
      setState(() {
        // Simple swap - just swap values directly
        final current = subsections[key]!;
        final above = subsections[key - 1]!;
        subsections[key] = above;
        subsections[key - 1] = current;
      });
    }
  }

  void moveDown(int key) {
    final maxKey = subsections.length - 1;
    if (key < maxKey) {
      setState(() {
        // Simple swap - just swap values directly
        final current = subsections[key]!;
        final below = subsections[key + 1]!;
        subsections[key] = below;
        subsections[key + 1] = current;
      });
    }
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
            ...subsections.entries.map((entry) {
              final position =
                  entry.key; // This is the current position after reordering
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (position > 0)
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_up, size: 16),
                            onPressed: () => moveUp(position),
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                          )
                        else
                          const SizedBox(width: 32), // Spacer for first entry
                        if (position < subsections.length - 1)
                          IconButton(
                            icon:
                                const Icon(Icons.keyboard_arrow_down, size: 16),
                            onPressed: () => moveDown(position),
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                          )
                        else
                          const SizedBox(width: 32), // Spacer for last entry
                        if (subsections.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete, size: 16),
                            onPressed: () => removeSubsection(position),
                            constraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  entry.value.build(context),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
            ElevatedButton(
              onPressed: () => addSubsection(),
              child: const Text('Add Entry'),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sectionName': widget.sectionName,
      'subsections': subsections.entries
          .map((entry) => {
                'key': entry.key,
                'subsection': entry.value.toMap(),
              })
          .toList(),
    };
  }

  List<TextEditingController> get allControllers {
    final controllers = <TextEditingController>[];
    for (final subsection in subsections.values) {
      controllers.addAll(subsection.allControllers);
    }
    return controllers;
  }
}
