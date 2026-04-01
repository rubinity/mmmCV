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
        return TextFormField(
          controller: controller,
          initialValue: initialValue ?? controller?.text,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.label),
            hintText: placeholder,
          ),
        );
      case FieldType.email:
        return TextFormField(
          controller: controller,
          initialValue: initialValue ?? controller?.text,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
            hintText: placeholder,
          ),
        );
      case FieldType.phone:
        return TextFormField(
          controller: controller,
          initialValue: initialValue ?? controller?.text,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
            hintText: placeholder,
          ),
        );
      case FieldType.multiline:
        return TextFormField(
          controller: controller,
          initialValue: initialValue ?? controller?.text,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
            hintText: placeholder,
          ),
        );
      case FieldType.url:
        return TextFormField(
          controller: controller,
          initialValue: initialValue ?? controller?.text,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
            hintText: placeholder,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...fields.map((field) => field.build(context)).toList(),
          ],
        ),
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

  List<FieldDefinition> get fields {
    return fieldGroups.expand((group) => group.fields).toList();
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
  MainSection({
    required String sectionName,
  }) : super(sectionName: sectionName, type: 'main');

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
            FieldGroup(
              title: 'Personal Information',
              fields: [
                FieldDefinition(
                  label: 'First Name',
                  type: FieldType.text,
                ),
                FieldDefinition(
                  label: 'Middle Name',
                  type: FieldType.text,
                ),
                FieldDefinition(
                  label: 'Last Name',
                  type: FieldType.text,
                ),
                FieldDefinition(
                  label: 'Note',
                  type: FieldType.multiline,
                ),
                FieldDefinition(
                  label: 'Email',
                  type: FieldType.email,
                ),
                FieldDefinition(
                  label: 'Phone',
                  type: FieldType.phone,
                ),
                FieldDefinition(
                  label: 'Address',
                  type: FieldType.multiline,
                ),
                FieldDefinition(
                  label: 'Zip Code',
                  type: FieldType.text,
                ),
                FieldDefinition(
                  label: 'City',
                  type: FieldType.text,
                ),
                FieldDefinition(
                  label: 'Country',
                  type: FieldType.text,
                ),
                FieldDefinition(
                  label: 'Website 1',
                  type: FieldType.text,
                ),
                FieldDefinition(
                  label: 'URL 1',
                  type: FieldType.url,
                ),
                FieldDefinition(
                  label: 'Website 2',
                  type: FieldType.text,
                ),
                FieldDefinition(
                  label: 'URL 2',
                  type: FieldType.url,
                ),
              ],
            ).build(context),
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
    return [];
  }
}

class EducationSection extends CvSection {
  final List<Subsection> subsections = [];

  EducationSection({
    required String sectionName,
    List<Subsection>? subsections,
  }) : super(sectionName: sectionName, type: 'education');

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
            // Education subsections will be rendered here
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
  List<TextEditingController> get allControllers => [];
}

class ExperienceSection extends CvSection {
  final List<Subsection> subsections = [];

  ExperienceSection({
    required String sectionName,
    List<Subsection>? subsections,
  }) : super(sectionName: sectionName, type: 'experience');

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
            // Experience subsections will be rendered here
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
  List<TextEditingController> get allControllers => [];
}
