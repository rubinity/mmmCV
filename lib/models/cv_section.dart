import 'package:flutter/material.dart';

abstract class CvSection {
  String sectionName;
  String type;
  List<Map<String, String>> items;
  String subsectionName;

  CvSection({
    required this.sectionName,
    required this.type,
    this.items = const [],
    required this.subsectionName,
  });

  Map<String, dynamic> toMap();
  String get displayName => sectionName.isEmpty ? type : sectionName;
  Widget build(BuildContext context);
}

class FieldGroup {
  final List<Widget> fields;
  final String? title;
  final CrossAxisAlignment alignment;
  final double spacing;

  FieldGroup({
    required this.fields,
    this.title,
    this.alignment = CrossAxisAlignment.start,
    this.spacing = 16.0,
  });

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: spacing),
        ],
        Wrap(
          spacing: spacing,
          runSpacing: 10,
          children: fields,
        ),
      ],
    );
  }
}

class MainSection extends CvSection {
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _noteController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _website1Controller = TextEditingController();
  final _url1Controller = TextEditingController();
  final _website2Controller = TextEditingController();
  final _url2Controller = TextEditingController();

  MainSection({
    required String sectionName,
    List<Map<String, String>> items = const [],
  }) : super(
            sectionName: sectionName,
            type: 'main',
            items: items,
            subsectionName: 'Personal Information');

  @override
  Map<String, dynamic> toMap() {
    return {
      'sectionName': sectionName,
      'type': type,
      'items': items,
      'subsectionName': subsectionName,
    };
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
              displayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FieldGroup(
              title: 'Fill out the form to create your CV',
              fields: [
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _middleNameController,
                    decoration: const InputDecoration(
                      labelText: 'Middle Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ).build(context),
            FieldGroup(
              title: null,
              fields: [
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
              ],
            ).build(context),
            FieldGroup(
              title: null,
              fields: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                ),
              ],
            ).build(context),
            FieldGroup(
              title: null,
              fields: [
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home),
                  ),
                ),
              ],
            ).build(context),
            FieldGroup(
              title: null,
              fields: [
                Expanded(
                  child: TextFormField(
                    controller: _zipCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Zip Code',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.mail),
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag),
                    ),
                  ),
                ),
              ],
            ).build(context),
            FieldGroup(
              title: null,
              fields: [
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _website1Controller,
                    decoration: const InputDecoration(
                      labelText: 'Website 1',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _url1Controller,
                    decoration: const InputDecoration(
                      labelText: 'URL 1',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _website2Controller,
                    decoration: const InputDecoration(
                      labelText: 'Website 2',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.language),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _url2Controller,
                    decoration: const InputDecoration(
                      labelText: 'URL 2',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                ),
              ],
            ).build(context),
          ],
        ),
      ),
    );
  }

  factory MainSection.fromMap(Map<String, dynamic> map) {
    return MainSection(
      sectionName: map['sectionName'] ?? '',
      items: List<Map<String, String>>.from(map['items'] ?? []),
    );
  }
}

class EducationSection extends CvSection {
  EducationSection({
    required String sectionName,
    List<Map<String, String>> items = const [],
  }) : super(
            sectionName: sectionName,
            type: 'education',
            items: items,
            subsectionName: 'Education');

  @override
  Map<String, dynamic> toMap() {
    return {
      'sectionName': sectionName,
      'type': type,
      'items': items,
      'subsectionName': subsectionName,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Subsections
            if (items.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...items.asMap().entries.map((entry) {
                int itemIndex = entry.key;
                Map<String, String> item = entry.value;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$subsectionName ${itemIndex + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // This will be handled in main.dart
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: item['degree'] ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Degree',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // This will be handled in main.dart
              },
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  factory EducationSection.fromMap(Map<String, dynamic> map) {
    return EducationSection(
      sectionName: map['sectionName'] ?? '',
      items: List<Map<String, String>>.from(map['items'] ?? []),
    );
  }
}

class ExperienceSection extends CvSection {
  ExperienceSection({
    required String sectionName,
    List<Map<String, String>> items = const [],
  }) : super(
            sectionName: sectionName,
            type: 'experience',
            items: items,
            subsectionName: 'Experience');

  @override
  Map<String, dynamic> toMap() {
    return {
      'sectionName': sectionName,
      'type': type,
      'items': items,
      'subsectionName': subsectionName,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Subsections
            if (items.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...items.asMap().entries.map((entry) {
                int itemIndex = entry.key;
                Map<String, String> item = entry.value;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$subsectionName ${itemIndex + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // This will be handled in main.dart
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: item['job'] ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Job',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // This will be handled in main.dart
              },
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  factory ExperienceSection.fromMap(Map<String, dynamic> map) {
    return ExperienceSection(
      sectionName: map['sectionName'] ?? '',
      items: List<Map<String, String>>.from(map['items'] ?? []),
    );
  }
}

class SectionTypes {
  static const List<String> types = ['main', 'education', 'experience'];

  static CvSection createSection(String type, String sectionName) {
    switch (type) {
      case 'main':
        return MainSection(sectionName: sectionName);
      case 'education':
        return EducationSection(sectionName: sectionName);
      case 'experience':
        return ExperienceSection(sectionName: sectionName);
      default:
        throw ArgumentError('Unknown section type: $type');
    }
  }

  static CvSection fromMap(Map<String, dynamic> map) {
    String type = map['type'] ?? '';
    switch (type) {
      case 'main':
        return MainSection.fromMap(map);
      case 'education':
        return EducationSection.fromMap(map);
      case 'experience':
        return ExperienceSection.fromMap(map);
      default:
        throw ArgumentError('Unknown section type: $type');
    }
  }
}
