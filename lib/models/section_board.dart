import 'package:flutter/material.dart';
import 'custom_section.dart';

class SectionBoard {
  final List<CustomSection> sections;
  final VoidCallback? onAddSection;
  final VoidCallback? onRemoveSection;

  SectionBoard({
    required this.sections,
    this.onAddSection,
    this.onRemoveSection,
  });

  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sections',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...sections
                .map((section) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section content with FieldGroup functionality
                          section.build(context),
                          const SizedBox(height: 8.0),
                          // Section management buttons
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Add new subsection to this section
                                  section.addSubsection();
                                },
                                child: const Text('Add Entry'),
                              ),
                              const SizedBox(width: 8.0),
                              ElevatedButton(
                                onPressed: () {
                                  // Remove this section
                                  onRemoveSection?.call();
                                },
                                child: const Text('Remove Section'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ))
                .toList(),
            const SizedBox(height: 16),
            // Add new section button
            if (onAddSection != null)
              ElevatedButton(
                onPressed: onAddSection,
                child: const Text('Add Section'),
              ),
          ],
        ),
      ),
    );
  }

  List<TextEditingController> get allControllers {
    final controllers = <TextEditingController>[];
    for (final section in sections) {
      controllers.addAll(section.allControllers);
    }
    return controllers;
  }
}
