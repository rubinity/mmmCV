import 'package:flutter/material.dart';
import 'custom_section.dart';

class SectionBoard extends StatelessWidget {
  final List<CustomSection> sections;
  final Function(int)? onSectionRemoved;

  const SectionBoard({
    super.key,
    required this.sections,
    this.onSectionRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: sections.map((section) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section content is now self-contained
                  section,
                  const SizedBox(height: 8.0),
                  // Section management buttons
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Remove this section
                          final index = sections.indexOf(section);
                          onSectionRemoved?.call(index);
                        },
                        child: const Text('Remove Section'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
