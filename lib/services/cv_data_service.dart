import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import '../models/custom_section.dart' as custom_section;
import '../models/cv_section.dart';
import '../models/section_types.dart';

// Data for a subsection within a custom section
class SubsectionData {
  final String name;
  final List<String> controllerValues;
  final bool printed;

  SubsectionData({
    required this.name,
    required this.controllerValues,
    required this.printed,
  });
}

// Preloaded data structure for CV restoration
class PreloadedCvData {
  final Map<String, String> mainSectionValues;
  final List<CustomSectionMetadata> customSections;
  final Map<String, List<SubsectionData>> customSectionSubsections;

  PreloadedCvData({
    required this.mainSectionValues,
    required this.customSections,
    required this.customSectionSubsections,
  });

  bool get isEmpty => mainSectionValues.isEmpty && customSections.isEmpty;
}

// Metadata for custom sections
class CustomSectionMetadata {
  final String sectionId;
  final String sectionName;
  final SectionType sectionType;
  final int order;

  CustomSectionMetadata({
    required this.sectionId,
    required this.sectionName,
    required this.sectionType,
    required this.order,
  });
}

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
  ) {
    final Map<String, dynamic> cvData = {
      'mainSection': _extractMainSectionData(mainControllers),
      'customSections': _extractCustomSectionsData(customSections),
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

  /// Extract custom sections data from CustomSection widgets using controllers
  static List<Map<String, dynamic>> _extractCustomSectionsData(
    List<custom_section.CustomSection> sections,
  ) {
    final List<Map<String, dynamic>> sectionsData = [];

    for (final section in sections) {
      // Get controllers directly from state using the controllers field
      final currentState = section.sectionKey?.currentState;
      final controllers = currentState?.controllers ?? [];

      if (controllers.isNotEmpty && currentState != null) {
        // Field count per subsection, read live off the actual subsection
        // class rather than a hardcoded/duplicated constant.
        final probe = currentState.createDefaultSubsection();
        final fieldsPerSubsection = probe.allControllers.length;
        for (final controller in probe.allControllers) {
          controller.dispose();
        }

        final sectionData = {
          'sectionId': section.sectionId, // Add section ID to saved data
          'sectionName': section.sectionName,
          'subsectionType': section.subsectionType.toString(),
          'controllers':
              controllers.map((controller) => controller.text).toList(),
          'fieldsPerSubsection': fieldsPerSubsection,
          'printedFlags': currentState.printedFlags,
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
      final csvData = convertToCsvRows(cvData);
      final csv = const ListToCsvConverter().convert(csvData);

      // Write to file asynchronously
      await file.writeAsString(csv);

      print('Async save completed');
    } catch (e) {
      throw Exception('Failed to save CV data: $e');
    }
  }

  /// Synchronous backup save (immediate write)
  static void syncSaveCvData(Map<String, dynamic> cvData) {
    try {
      // Convert CV data to CSV format
      final csvData = convertToCsvRows(cvData);
      final csv = const ListToCsvConverter().convert(csvData);

      // Write synchronously using File system directly
      final file = File('${Directory.current.path}/data/cv_data.csv');
      file.writeAsStringSync(csv); // Synchronous write

      // print('Synchronous save completed - data written to disk');
    } catch (e) {
      print('Synchronous save failed: $e');
    }
  }

  /// Load CV data from CSV and return preloaded data structure
  static Future<PreloadedCvData> loadCvData() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return PreloadedCvData(
          mainSectionValues: {},
          customSections: [],
          customSectionSubsections: {},
        );
      }

      final content = await file.readAsString();
      if (content.isEmpty) {
        return PreloadedCvData(
          mainSectionValues: {},
          customSections: [],
          customSectionSubsections: {},
        );
      }

      // Parse CSV and convert back to preloaded data structure
      final rows = const CsvToListConverter(shouldParseNumbers: false).convert(content);
      if (rows.isEmpty) {
        return PreloadedCvData(
          mainSectionValues: {},
          customSections: [],
          customSectionSubsections: {},
        );
      }

      return convertFromCsvRows(rows);
    } catch (e) {
      throw Exception('Failed to load CV data: $e');
    }
  }

  /// Convert CV data to CSV rows
  static List<List<dynamic>> convertToCsvRows(Map<String, dynamic> cvData) {
    final List<List<dynamic>> csvRows = [];

    // Add headers
    csvRows.add([
      'Section ID',
      'Section Name',
      'Section Type',
      'Field Group',
      'Field Label',
      'Field Value'
    ]);

    // Add main section data
    if (cvData.containsKey('mainSection')) {
      final mainSection = cvData['mainSection'] as Map<String, dynamic>;
      for (final entry in mainSection.entries) {
        csvRows.add([
          '',
          '',
          '',
          '',
          entry.key,
          entry.value
        ]); // 6 columns: ID, Name, Type, Field Group, Field Label, Field Value
      }
    }

    // Add custom sections data
    if (cvData.containsKey('customSections')) {
      final customSections =
          cvData['customSections'] as List<Map<String, dynamic>>;
      for (final section in customSections) {
        final sectionName = section['sectionName'] as String;
        final sectionId = section['sectionId'] as String? ?? '';
        final subsectionType = section['subsectionType'] as String;
        final controllers = section['controllers'] as List<String>;
        final fieldsPerSubsection = section['fieldsPerSubsection'] as int;
        final printedFlags = section['printedFlags'] as List<bool>;

        int printedIndex = 0;
        for (int i = 0; i < controllers.length; i++) {
          csvRows.add([
            sectionId,
            sectionName,
            subsectionType,
            'Field ${i + 1}',
            'Controller ${i + 1}',
            controllers[i]
          ]);

          // A "Printed" row closes each subsection's block of fields.
          if ((i + 1) % fieldsPerSubsection == 0) {
            final printed = printedIndex < printedFlags.length
                ? printedFlags[printedIndex]
                : true;
            csvRows.add([
              sectionId,
              sectionName,
              subsectionType,
              'Printed',
              'Printed',
              printed.toString()
            ]);
            printedIndex++;
          }
        }
      }
    }

    return csvRows;
  }

  /// Convert CSV rows back to PreloadedCvData structure
  static PreloadedCvData convertFromCsvRows(List<List<dynamic>> rows) {
    final Map<String, String> mainSectionValues = {};
    final List<CustomSectionMetadata> customSections = [];
    final Map<String, List<SubsectionData>> customSectionSubsections = {};
    final Map<String, int> sectionOrderMap = {};
    final Map<String, List<String>> currentSubsectionFieldBuffer = {};
    int orderCounter = 0;

    if (rows.length <= 1) {
      return PreloadedCvData(
        mainSectionValues: mainSectionValues,
        customSections: customSections,
        customSectionSubsections: customSectionSubsections,
      );
    }

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 6) continue;

      final sectionId = row[0]?.toString() ?? '';
      final sectionName = row[1]?.toString() ?? '';
      final sectionType = row[2]?.toString() ?? '';
      final fieldLabel = row[4]?.toString() ?? '';
      final fieldValue = row[5]?.toString() ?? '';

      // Main section rows have empty sectionId and sectionName
      if (sectionId.isEmpty && sectionName.isEmpty) {
        mainSectionValues[fieldLabel] = fieldValue;
        continue;
      }

      if (sectionId.isEmpty) continue;

      if (!sectionOrderMap.containsKey(sectionId)) {
        sectionOrderMap[sectionId] = orderCounter++;
        currentSubsectionFieldBuffer[sectionId] = [];
        customSectionSubsections[sectionId] = [];

        final typeString = sectionType.split('.').last;
        final sectionTypeEnum = SectionType.values.firstWhere(
          (type) => type.name == typeString,
          orElse: () => SectionType.education,
        );

        customSections.add(CustomSectionMetadata(
          sectionId: sectionId,
          sectionName: sectionName,
          sectionType: sectionTypeEnum,
          order: sectionOrderMap[sectionId]!,
        ));
      }

      if (fieldLabel == 'Printed') {
        // A "Printed" row closes the subsection currently being buffered.
        final subsections = customSectionSubsections[sectionId]!;
        final buffer = currentSubsectionFieldBuffer[sectionId]!;
        subsections.add(SubsectionData(
          name: '$sectionName Entry ${subsections.length + 1}',
          controllerValues: List<String>.from(buffer),
          printed: fieldValue == 'true',
        ));
        buffer.clear();
      } else {
        currentSubsectionFieldBuffer[sectionId]!.add(fieldValue);
      }
    }

    customSections.sort((a, b) => a.order.compareTo(b.order));

    return PreloadedCvData(
      mainSectionValues: mainSectionValues,
      customSections: customSections,
      customSectionSubsections: customSectionSubsections,
    );
  }
}
