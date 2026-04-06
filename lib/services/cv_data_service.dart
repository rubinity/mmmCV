import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import '../models/custom_section.dart' as custom_section;
import '../models/cv_section.dart';

class CvDataService {
  static Future<String> get _dataPath async {
    final currentDir = Directory.current;
    return '${currentDir.path}/data';
  }

  static Future<File> get _localFile async {
    final path = await _dataPath;
    final dataDir = Directory(path);
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }
    return File('$path/cv_data.csv');
  }

  /// Extract all data from controllers and organize for CSV export
  static Map<String, dynamic> extractAllData(
    List<TextEditingController> mainControllers,
    List<custom_section.CustomSection> customSections,
    List<GlobalKey<custom_section.CustomSectionState>> sectionKeys,
  ) {
    final Map<String, dynamic> cvData = {
      'mainSection': _extractMainSectionData(mainControllers),
      'customSections': _extractCustomSectionsData(customSections, sectionKeys),
    };
    return cvData;
  }

  /// Extract main section data from controllers
  static Map<String, dynamic> _extractMainSectionData(
      List<TextEditingController> controllers) {
    final Map<String, dynamic> mainData = {};

    // Use controller index to create field paths based on MainSection structure
    final fieldPaths = [
      'main_section.personal_info.first_name', // Controller 0
      'main_section.personal_info.middle_name', // Controller 1
      'main_section.personal_info.last_name', // Controller 2
      'main_section.contact.email', // Controller 3
      'main_section.contact.phone', // Controller 4
      'main_section.contact.city', // Controller 5
      'main_section.contact.country', // Controller 6
      'main_section.online.website_1', // Controller 7
      'main_section.online.url_1', // Controller 8
      'main_section.online.website_2', // Controller 9
      'main_section.online.url_2', // Controller 10
      'main_section.summary.summary', // Controller 11
    ];

    for (int i = 0; i < controllers.length && i < fieldPaths.length; i++) {
      final controller = controllers[i];
      final fieldPath = fieldPaths[i];
      mainData[fieldPath] = controller.text;
    }

    return mainData;
  }

  /// Extract custom sections data from CustomSection widgets
  static List<Map<String, dynamic>> _extractCustomSectionsData(
    List<custom_section.CustomSection> sections,
    List<GlobalKey<custom_section.CustomSectionState>> sectionKeys,
  ) {
    final List<Map<String, dynamic>> sectionsData = [];

    for (int i = 0; i < sections.length; i++) {
      final section = sections[i];
      final sectionKey = i < sectionKeys.length ? sectionKeys[i] : null;

      if (sectionKey?.currentState != null) {
        final sectionData = {
          'sectionName': section.sectionName,
          'subsectionType': section.subsectionType.toString(),
          'subsections':
              _extractSubsectionsData(sectionKey!.currentState!.subsections),
        };
        sectionsData.add(sectionData);
      }
    }

    return sectionsData;
  }

  /// Extract subsections data from subsections map
  static List<Map<String, dynamic>> _extractSubsectionsData(
    Map<int, custom_section.Subsection> subsections,
  ) {
    final List<Map<String, dynamic>> subsectionsData = [];

    for (final entry in subsections.entries) {
      final subsection = entry.value;
      final subsectionData = {
        'name': subsection.name,
        'fieldGroups': _extractFieldGroupsData(subsection.fieldGroups),
      };
      subsectionsData.add(subsectionData);
    }

    return subsectionsData;
  }

  /// Extract field groups data from field groups
  static List<Map<String, dynamic>> _extractFieldGroupsData(
      List<FieldGroup> fieldGroups) {
    final List<Map<String, dynamic>> fieldGroupsData = [];

    for (final fieldGroup in fieldGroups) {
      final fieldGroupData = {
        'title': fieldGroup.title,
        'fields': _extractFieldsData(fieldGroup.fields),
      };
      fieldGroupsData.add(fieldGroupData);
    }

    return fieldGroupsData;
  }

  /// Extract fields data from field definitions
  static List<Map<String, dynamic>> _extractFieldsData(
      List<FieldDefinition> fields) {
    final List<Map<String, dynamic>> fieldsData = [];

    for (final field in fields) {
      final fieldData = {
        'label': field.label,
        'type': field.type.toString(),
        'value': field.effectiveController.text,
        'placeholder': field.placeholder,
        'width': field.width,
      };
      fieldsData.add(fieldData);
    }

    return fieldsData;
  }

  /// Save CV data to CSV
  static Future<void> saveCvData(Map<String, dynamic> cvData) async {
    try {
      final file = await _localFile;

      // Convert CV data to CSV format
      final csvData = _convertToCsvRows(cvData);
      final csv = const ListToCsvConverter().convert(csvData);

      // Write to file
      await file.writeAsString(csv);

      print('✅ CV data saved successfully');
    } catch (e) {
      throw Exception('Failed to save CV data: $e');
    }
  }

  /// Load CV data from CSV
  static Future<Map<String, dynamic>> loadCvData() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return {};
      }

      final content = await file.readAsString();
      if (content.isEmpty) {
        return {};
      }

      // Parse CSV and convert back to data structure
      final rows = const CsvToListConverter().convert(content);
      if (rows.isEmpty) {
        return {};
      }

      return _convertFromCsvRows(rows);
    } catch (e) {
      throw Exception('Failed to load CV data: $e');
    }
  }

  /// Convert CV data to CSV rows
  static List<List<dynamic>> _convertToCsvRows(Map<String, dynamic> cvData) {
    final List<List<dynamic>> csvRows = [];

    // Add headers
    csvRows.add(
        ['Section', 'Subsection', 'Field Group', 'Field Label', 'Field Value']);

    // Add main section data
    if (cvData.containsKey('mainSection')) {
      final mainSection = cvData['mainSection'] as Map<String, dynamic>;
      for (final entry in mainSection.entries) {
        csvRows.add(['Main Section', '', '', entry.key, entry.value]);
      }
    }

    // Add custom sections data
    if (cvData.containsKey('customSections')) {
      final customSections =
          cvData['customSections'] as List<Map<String, dynamic>>;
      for (final section in customSections) {
        final sectionName = section['sectionName'] as String;
        final subsections =
            section['subsections'] as List<Map<String, dynamic>>;

        for (final subsection in subsections) {
          final subsectionName = subsection['name'] as String;
          final fieldGroups =
              subsection['fieldGroups'] as List<Map<String, dynamic>>;

          for (final fieldGroup in fieldGroups) {
            final fieldGroupTitle = fieldGroup['title'] as String;
            final fields = fieldGroup['fields'] as List<Map<String, dynamic>>;

            for (final field in fields) {
              final fieldLabel = field['label'] as String;
              final fieldValue = field['value'] as String;
              csvRows.add([
                sectionName,
                subsectionName,
                fieldGroupTitle,
                fieldLabel,
                fieldValue
              ]);
            }
          }
        }
      }
    }

    return csvRows;
  }

  /// Convert CSV rows back to CV data structure
  static Map<String, dynamic> _convertFromCsvRows(List<List<dynamic>> rows) {
    final Map<String, dynamic> cvData = {};

    // Skip header row
    if (rows.length <= 1) {
      return cvData;
    }

    final Map<String, dynamic> mainSection = {};
    final List<Map<String, dynamic>> customSections = [];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 5) continue;

      final sectionName = row[0]?.toString() ?? '';
      final subsectionName = row[1]?.toString() ?? '';
      final fieldGroupTitle = row[2]?.toString() ?? '';
      final fieldLabel = row[3]?.toString() ?? '';
      final fieldValue = row[4]?.toString() ?? '';

      if (sectionName == 'Main Section') {
        mainSection[fieldLabel] = fieldValue;
      } else {
        // Find or create custom section
        var section = customSections.firstWhere(
          (s) => s['sectionName'] == sectionName,
          orElse: () => {'sectionName': sectionName, 'subsections': []},
        );

        // Find or create subsection
        final subsections =
            section['subsections'] as List<Map<String, dynamic>>;
        var subsection = subsections.firstWhere(
          (s) => s['name'] == subsectionName,
          orElse: () => {'name': subsectionName, 'fieldGroups': []},
        );

        // Find or create field group
        final fieldGroups =
            subsection['fieldGroups'] as List<Map<String, dynamic>>;
        var fieldGroup = fieldGroups.firstWhere(
          (fg) => fg['title'] == fieldGroupTitle,
          orElse: () => {'title': fieldGroupTitle, 'fields': []},
        );

        // Find or create field
        final fields = fieldGroup['fields'] as List<Map<String, dynamic>>;
        var field = fields.firstWhere(
          (f) => f['label'] == fieldLabel,
          orElse: () => {'label': fieldLabel, 'value': fieldValue},
        );

        field['value'] = fieldValue;
      }
    }

    if (mainSection.isNotEmpty) {
      cvData['mainSection'] = mainSection;
    }
    if (customSections.isNotEmpty) {
      cvData['customSections'] = customSections;
    }

    return cvData;
  }
}
