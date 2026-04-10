import 'package:flutter/material.dart';
import 'cv_section.dart';
import 'section_types.dart';
import '../services/cv_data_service.dart' show SubsectionData;

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

abstract class CustomSection extends StatefulWidget {
  final String sectionName;
  final SectionType subsectionType;
  final VoidCallback? onRemoveSection;
  final GlobalKey<CustomSectionState>? sectionKey;
  late final String sectionId; // Add unique section ID
  final List<SubsectionData>? preloadedSubsections; // Preloaded subsections
  final bool allowMultipleSubsections; // Allow multiple subsections

  // Track widget instance for debugging
  final String widgetId = DateTime.now().millisecondsSinceEpoch.toString();

  CustomSection({
    super.key,
    required this.sectionName,
    required this.subsectionType,
    this.onRemoveSection,
    this.sectionKey,
    String? sectionId, // Optional sectionId parameter
    this.preloadedSubsections, // Optional preloaded subsections
    this.allowMultipleSubsections = true, // Default: allow multiple subsections
  }) {
    this.sectionId = sectionId ?? widgetId; // Use provided ID or generate one
    // print(
    //     '=== DEBUG: CustomSection widget created: $widgetId (sectionId: ${this.sectionId}) ===');
  }

  // Expose controllers from state via sectionKey
  List<TextEditingController> get allControllers {
    final currentState = sectionKey?.currentState;
    // print(
    //     '=== DEBUG: Widget $widgetId: State accessible: ${currentState != null} ===');

    if (currentState == null) {
      print('=== DEBUG: Widget $widgetId: State not accessible ===');
      return [];
    }

    final controllers = currentState.allControllers;
    // print(
    //     '=== DEBUG: Widget $widgetId: Returning ${controllers.length} controllers ===');
    return controllers;
  }
}

abstract class CustomSectionState extends State<CustomSection> {
  Map<int, Subsection> subsections = {};
  List<TextEditingController> controllers = []; // Store controllers in state
  bool _isInitialized = false; // Track initialization state

  @override
  void initState() {
    super.initState();
    // print('=== DEBUG: CustomSectionState.initState called ===');

    // Create subsections from preloaded data or create default
    if (widget.preloadedSubsections != null &&
        widget.preloadedSubsections!.isNotEmpty) {
      // print(
      //     '=== DEBUG: Creating ${widget.preloadedSubsections!.length} subsections from preloaded data ===');
      for (int i = 0; i < widget.preloadedSubsections!.length; i++) {
        final subsectionData = widget.preloadedSubsections![i];
        subsections[i] = createSubsectionFromData(subsectionData, i);
        // print('=== DEBUG: Created subsection: ${subsections[i]?.name} ===');
      }
    } else {
      // Create initial subsection based on type
      subsections[0] = createDefaultSubsection();
      print(
          '=== DEBUG: Created default subsection: ${subsections[0]?.name} ===');
    }

    // Register controllers from subsections
    registerControllers();
    _isInitialized = true; // Mark as initialized

    // print('=== DEBUG: State initialization completed ===');
  }

  Subsection createSubsectionFromData(SubsectionData data, int index);

  void registerControllers() {
    // print('=== DEBUG: _registerControllers called ===');
    controllers.clear(); // Clear previous controllers
    for (final subsection in subsections.values) {
      // print('=== DEBUG: Processing subsection: ${subsection.name} ===');
      for (final fieldGroup in subsection.fieldGroups) {
        // print('=== DEBUG: Processing field group: ${fieldGroup.title} ===');
        for (final field in fieldGroup.fields) {
          if (field.controller != null) {
            // print('=== DEBUG: Adding controller for field: ${field.label} ===');
            controllers.add(field.controller!); // Add to state controllers
          } else {
            // print('=== DEBUG: Field ${field.label} has no controller ===');
          }
        }
      }
    }
    // print(
    //     '=== DEBUG: Total controllers in state: ${subsections.values.map((subsection) => subsection.allControllers).fold(0, (a, b) => a + b.length)} ===');
  }

  // Expose controllers from subsections
  List<TextEditingController> get allControllers {
    if (!_isInitialized) {
      print(
          '=== DEBUG: State not initialized yet, returning 0 controllers ===');
      return [];
    }

    final controllers = <TextEditingController>[];
    for (final subsection in subsections.values) {
      for (final fieldGroup in subsection.fieldGroups) {
        for (final field in fieldGroup.fields) {
          if (field.controller != null) {
            controllers.add(field.controller!);
          }
        }
      }
    }
    // print(
    //     '=== DEBUG: Extracted ${controllers.length} controllers from subsections ===');
    return controllers;
  }

  Subsection createDefaultSubsection();

  void addSubsection();

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
        registerControllers(); // Re-collect controllers in new order
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
        registerControllers(); // Re-collect controllers in new order
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
            if (widget.allowMultipleSubsections)
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
}
