import 'package:flutter/material.dart';

enum FieldType {
  text,
  email,
  phone,
  multiline,
  url,
  dropdown,
  button,
}

class FieldDefinition {
  final String label;
  final FieldType type;
  final TextEditingController? controller;
  final String? initialValue;
  final String? placeholder;
  final int? width;
  final Widget? child;
  final List<DropdownMenuItem<String>>? dropdownItems;
  final VoidCallback? onPressed;
  final String? buttonText;
  final IconData? buttonIcon;
  final Function(String?)? onChanged;

  // Cache for lazily created controller
  TextEditingController? _cachedController;

  FieldDefinition({
    required this.label,
    required this.type,
    this.controller,
    this.initialValue,
    this.placeholder,
    this.width,
    this.child,
    this.dropdownItems,
    this.onPressed,
    this.buttonText,
    this.buttonIcon,
    this.onChanged,
  });

  // Create controller if not provided (for text fields)
  TextEditingController get effectiveController {
    if (controller != null) return controller!;

    // Return cached controller or create new one
    _cachedController ??= TextEditingController(text: initialValue ?? '');
    return _cachedController!;
  }

  Widget build(BuildContext context) {
    switch (type) {
      case FieldType.multiline:
        return Expanded(
          child: TextFormField(
            controller: effectiveController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
          ),
        );
      case FieldType.dropdown:
        return Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            value: controller?.text ?? initialValue,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.category),
            ),
            items: dropdownItems,
            onChanged: (value) {
              if (controller != null) {
                controller!.text = value ?? '';
              }
              onChanged?.call(value);
            },
          ),
        );
      case FieldType.button:
        return Expanded(
          flex: 1,
          child: ElevatedButton(
            onPressed: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (buttonIcon != null) Icon(buttonIcon),
                if (buttonText != null) Text(buttonText!),
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        );
      default: // text, email, phone, url
        return Expanded(
          child: TextFormField(
            controller: effectiveController,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            keyboardType: switch (type) {
              FieldType.email => TextInputType.emailAddress,
              FieldType.phone => TextInputType.phone,
              FieldType.url => TextInputType.url,
              _ => TextInputType.text,
            },
          ),
        );
    }
  }
}

class FieldGroup {
  final String title;
  final List<FieldDefinition> fields;
  final VoidCallback? onAddEntry;
  final VoidCallback? onRemoveEntry;

  FieldGroup({
    required this.title,
    required this.fields,
    this.onAddEntry,
    this.onRemoveEntry,
  });

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
            children: fields
                .map((field) => SizedBox(
                      width: (field.width ?? 200).toDouble(),
                      child: field.build(context),
                    ))
                .toList(),
          ),
          // Show add/remove buttons if callbacks are provided
          if (onAddEntry != null || onRemoveEntry != null)
            Column(
              children: [
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    if (onAddEntry != null)
                      ElevatedButton(
                        onPressed: onAddEntry,
                        child: const Text('Add Entry'),
                      ),
                    const SizedBox(width: 8.0),
                    if (onRemoveEntry != null)
                      ElevatedButton(
                        onPressed: onRemoveEntry,
                        child: const Text('Remove Entry'),
                      ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'fields': fields
          .map((field) => {
                'label': field.label,
                'type': field.type.name,
                'initialValue': field.initialValue,
                'placeholder': field.placeholder,
                'width': field.width,
                'child': field.child?.toString(),
              })
          .toList(),
    };
  }

  List<TextEditingController> get allControllers {
    final controllers = <TextEditingController>[];
    for (final field in fields) {
      if (field.type != FieldType.button) {
        controllers.add(field.effectiveController);
      }
    }
    return controllers;
  }
}

class Subsection {
  final String name;
  final List<FieldGroup> fieldGroups;

  Subsection({
    required this.name,
    required this.fieldGroups,
  });

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
      controllers.addAll(group.allControllers);
    }
    return controllers;
  }
}

abstract class CvSection {
  final String sectionName;
  final String type;

  CvSection({
    required this.sectionName,
    required this.type,
  });

  Widget build(BuildContext context);
  Map<String, dynamic> toMap();
  List<TextEditingController> get allControllers => [];
}

class MainSection extends CvSection {
  List<Subsection> subsections = [];

  MainSection({
    required String sectionName,
    List<Subsection>? subsections,
    Map<String, String>? preloadedValues,
  }) : super(sectionName: sectionName, type: 'main') {
    this.subsections = subsections ??
        [
          Subsection(
            name: 'Personal Information',
            fieldGroups: [
              FieldGroup(
                title: 'Name',
                fields: [
                  FieldDefinition(
                    label: 'First Name',
                    type: FieldType.text,
                    initialValue: preloadedValues?[
                        'main_section.personal_info.first_name'],
                  ),
                  FieldDefinition(
                    label: 'Middle Name',
                    type: FieldType.text,
                    initialValue: preloadedValues?[
                        'main_section.personal_info.middle_name'],
                  ),
                  FieldDefinition(
                    label: 'Last Name',
                    type: FieldType.text,
                    initialValue: preloadedValues?[
                        'main_section.personal_info.last_name'],
                  ),
                ],
              ),
              FieldGroup(
                title: 'Contact',
                fields: [
                  FieldDefinition(
                    label: 'Email',
                    type: FieldType.email,
                    initialValue:
                        preloadedValues?['main_section.contact.email'],
                  ),
                  FieldDefinition(
                    label: 'Phone',
                    type: FieldType.phone,
                    initialValue:
                        preloadedValues?['main_section.contact.phone'],
                  ),
                  FieldDefinition(
                    label: 'City',
                    type: FieldType.text,
                    initialValue: preloadedValues?['main_section.contact.city'],
                  ),
                  FieldDefinition(
                    label: 'Country',
                    type: FieldType.text,
                    initialValue:
                        preloadedValues?['main_section.contact.country'],
                  ),
                ],
              ),
              FieldGroup(
                title: 'Online',
                fields: [
                  FieldDefinition(
                    label: 'Website 1',
                    type: FieldType.text,
                    width: 150,
                    initialValue:
                        preloadedValues?['main_section.online.website_1'],
                  ),
                  FieldDefinition(
                    label: 'URL 1',
                    type: FieldType.url,
                    width: 250,
                    initialValue: preloadedValues?['main_section.online.url_1'],
                  ),
                  FieldDefinition(
                    label: 'Website 2',
                    type: FieldType.text,
                    width: 150,
                    initialValue:
                        preloadedValues?['main_section.online.website_2'],
                  ),
                  FieldDefinition(
                    label: 'URL 2',
                    type: FieldType.url,
                    width: 250,
                    initialValue: preloadedValues?['main_section.online.url_2'],
                  ),
                ],
              ),
              FieldGroup(
                title: 'Summary',
                fields: [
                  FieldDefinition(
                    label: 'Summary',
                    type: FieldType.multiline,
                    width: 812,
                    initialValue:
                        preloadedValues?['main_section.summary.summary'],
                  ),
                ],
              ),
            ],
          ),
        ];
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

class EducationSection extends CvSection {
  List<Subsection> subsections = [];

  EducationSection({
    required String sectionName,
    List<Subsection>? subsections,
  }) : super(sectionName: sectionName, type: 'education') {
    this.subsections = subsections ?? [];
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

class ExperienceSection extends CvSection {
  List<Subsection> subsections = [];

  ExperienceSection({
    required String sectionName,
    List<Subsection>? subsections,
  }) : super(sectionName: sectionName, type: 'experience') {
    this.subsections = subsections ?? [];
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
