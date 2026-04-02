import 'package:flutter/material.dart';

enum FieldType {
  text,
  email,
  phone,
  multiline,
  url,
}

class FieldDefinition {
  final String label;
  final FieldType type;
  final TextEditingController? controller;
  final String? initialValue;
  final String? placeholder;
  final int? width;
  final Widget? child;

  FieldDefinition({
    required this.label,
    required this.type,
    this.controller,
    this.initialValue,
    this.placeholder,
    this.width,
    this.child,
  });

  Widget build(BuildContext context) {
    switch (type) {
      case FieldType.text:
        return Expanded(
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            decoration: InputDecoration(
              labelText: label,
              hintText: placeholder,
              border: const OutlineInputBorder(),
            ),
          ),
        );
      case FieldType.email:
        return Expanded(
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            decoration: InputDecoration(
              labelText: label,
              hintText: placeholder,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        );
      case FieldType.phone:
        return Expanded(
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            decoration: InputDecoration(
              labelText: label,
              hintText: placeholder,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
        );
      case FieldType.multiline:
        return Expanded(
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            decoration: InputDecoration(
              labelText: label,
              hintText: placeholder,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        );
      case FieldType.url:
        return Expanded(
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            decoration: InputDecoration(
              labelText: label,
              hintText: placeholder,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
        );
      default:
        return Expanded(
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            decoration: InputDecoration(
              labelText: label,
              hintText: placeholder,
              border: const OutlineInputBorder(),
            ),
          ),
        );
    }
  }
}

class FieldGroup {
  final String title;
  final List<FieldDefinition> fields;

  FieldGroup({
    required this.title,
    required this.fields,
  });

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Wrap(
        spacing: 4.0,
        runSpacing: 4.0,
        children: fields
            .map((field) => SizedBox(
                  width: (field.width ?? 200).toDouble(),
                  child: field.build(context),
                ))
            .toList(),
      ),
    );
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...fieldGroups.map((group) => group.build(context)).toList(),
          ],
        ),
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
  }) : super(sectionName: sectionName, type: 'main') {
    this.subsections = subsections ??
        [
          Subsection(
            name: 'Personal Information',
            fieldGroups: [
              FieldGroup(
                title: 'Name',
                fields: [
                  FieldDefinition(label: 'First Name', type: FieldType.text),
                  FieldDefinition(label: 'Middle Name', type: FieldType.text),
                  FieldDefinition(label: 'Last Name', type: FieldType.text),
                ],
              ),
              FieldGroup(
                title: 'Contact',
                fields: [
                  FieldDefinition(label: 'Email', type: FieldType.email),
                  FieldDefinition(label: 'Phone', type: FieldType.phone),
                  FieldDefinition(label: 'City', type: FieldType.text),
                  FieldDefinition(label: 'Country', type: FieldType.text),
                ],
              ),
              FieldGroup(
                title: 'Online',
                fields: [
                  FieldDefinition(label: 'Website 1', type: FieldType.text, width: 150),
                  FieldDefinition(label: 'URL 1', type: FieldType.url, width: 250),
                  FieldDefinition(label: 'Website 2', type: FieldType.text, width: 150),
                  FieldDefinition(label: 'URL 2', type: FieldType.url, width: 250),
                ],
              ),
              FieldGroup(
                title: 'Summary',
                fields: [
                  FieldDefinition(
                      label: 'Summary', type: FieldType.multiline, width: 812),
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
