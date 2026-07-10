import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mmmcv/services/cv_data_service.dart';

void main() {
  group('CvDataService CSV round trip', () {
    test('single printed subsection round-trips with printed=true', () {
      final cvData = {
        'mainSection': <String, dynamic>{},
        'customSections': [
          {
            'sectionId': 'sec1',
            'sectionName': 'Skills',
            'subsectionType': 'SectionType.simplest',
            'controllers': ['Some description'],
            'fieldsPerSubsection': 1,
            'printedFlags': [true],
          },
        ],
      };

      final rows = CvDataService.convertToCsvRows(cvData);
      final result = CvDataService.convertFromCsvRows(rows);

      expect(result.customSections.length, 1);
      expect(result.customSections.first.sectionName, 'Skills');
      final subsections = result.customSectionSubsections['sec1']!;
      expect(subsections.length, 1);
      expect(subsections.first.printed, true);
      expect(subsections.first.controllerValues, ['Some description']);
    });

    test('unprinted subsection round-trips with printed=false', () {
      final cvData = {
        'mainSection': <String, dynamic>{},
        'customSections': [
          {
            'sectionId': 'sec2',
            'sectionName': 'Skills',
            'subsectionType': 'SectionType.simplest',
            'controllers': ['Hidden entry'],
            'fieldsPerSubsection': 1,
            'printedFlags': [false],
          },
        ],
      };

      final rows = CvDataService.convertToCsvRows(cvData);
      final result = CvDataService.convertFromCsvRows(rows);

      expect(result.customSectionSubsections['sec2']!.first.printed, false);
    });

    test('multiple subsections in one section round-trip independently', () {
      final cvData = {
        'mainSection': <String, dynamic>{},
        'customSections': [
          {
            'sectionId': 'sec3',
            'sectionName': 'Languages',
            'subsectionType': 'SectionType.languages',
            'controllers': ['English', 'Fluent', 'German', 'Basic'],
            'fieldsPerSubsection': 2,
            'printedFlags': [true, false],
          },
        ],
      };

      final rows = CvDataService.convertToCsvRows(cvData);
      final result = CvDataService.convertFromCsvRows(rows);

      final subsections = result.customSectionSubsections['sec3']!;
      expect(subsections.length, 2);
      expect(subsections[0].controllerValues, ['English', 'Fluent']);
      expect(subsections[0].printed, true);
      expect(subsections[1].controllerValues, ['German', 'Basic']);
      expect(subsections[1].printed, false);
    });

    test('section order is preserved via row order', () {
      final cvData = {
        'mainSection': <String, dynamic>{},
        'customSections': [
          {
            'sectionId': 'first',
            'sectionName': 'First',
            'subsectionType': 'SectionType.simplest',
            'controllers': ['A'],
            'fieldsPerSubsection': 1,
            'printedFlags': [true],
          },
          {
            'sectionId': 'second',
            'sectionName': 'Second',
            'subsectionType': 'SectionType.simplest',
            'controllers': ['B'],
            'fieldsPerSubsection': 1,
            'printedFlags': [true],
          },
        ],
      };

      final rows = CvDataService.convertToCsvRows(cvData);
      final result = CvDataService.convertFromCsvRows(rows);

      expect(result.customSections.map((s) => s.sectionId).toList(),
          ['first', 'second']);
    });

    test('full CSV string round trip preserves printed flags and multiline text', () {
      final cvData = {
        'mainSection': <String, dynamic>{},
        'customSections': [
          {
            'sectionId': 'sec4',
            'sectionName': 'Education',
            'subsectionType': 'SectionType.simplest',
            'controllers': ['Line one\nLine two, with a comma'],
            'fieldsPerSubsection': 1,
            'printedFlags': [true],
          },
        ],
      };

      final rows = CvDataService.convertToCsvRows(cvData);
      final csvString = const ListToCsvConverter().convert(rows);
      final parsedRows =
          const CsvToListConverter(shouldParseNumbers: false).convert(csvString);
      final result = CvDataService.convertFromCsvRows(parsedRows);

      final subsections = result.customSectionSubsections['sec4']!;
      expect(subsections.first.controllerValues,
          ['Line one\nLine two, with a comma']);
      expect(subsections.first.printed, true);
    });
  });
}
