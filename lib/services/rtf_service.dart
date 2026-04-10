// import 'package:mmmcv/models/cv_section.dart'; // TODO: Fix CvSection import
import 'package:flutter/material.dart';

class RtfService {
  // static Future<String> generateRtf(List<CvSection> sections) async { // TODO: Fix CvSection type
  static Future<String> generateRtf(List<dynamic> sections) async {
    final buffer = StringBuffer();

    // RTF Header with margins (left 2.54cm=1440 twips, others 1.27cm=720 twips)
    buffer.writeln('{\\rtf1\\ansi\\ansicpg1254');
    buffer.writeln('{\\fonttbl\\f0\\fswiss\\fcharset0\\fprq2 Arial;}');
    buffer.writeln('\\margl1440\\margr720\\margt720\\margb720');

    // Document settings
    buffer.writeln('{\\colortbl;\\red0\\green0\\blue0;}');
    buffer.writeln('\\viewkind4\\uc1\\pard\\f0\\fs24');

    // Content
    if (sections.isEmpty) {
      buffer.writeln('Empty CV');
    } else {
      for (final section in sections) {
        if (section.runtimeType.toString().contains('MainSection')) {
          _writeMainSectionRtf(buffer, section);
        } else {
          _writeCustomSectionRtf(buffer, section);
        }
      }
    }

    // Close document
    buffer.writeln('}');

    return buffer.toString();
  }

  static void _writeMainSectionRtf(StringBuffer buffer, dynamic mainSection) {
    final controllers =
        mainSection.allControllers as List<TextEditingController>;

    // Extract name values from controllers (order matches field definition order)
    // First Name, Middle Name, Last Name are first 3 controllers
    String firstName = controllers.length > 0 ? controllers[0].text : '';
    String middleName = controllers.length > 1 ? controllers[1].text : '';
    String lastName = controllers.length > 2 ? controllers[2].text : '';

    // First line: full name (Arial 12, bold, centered)
    buffer.writeln('{\\pard\\plain\\f0\\fs24\\qc\\b');
    String fullName = '$firstName';
    if (middleName.isNotEmpty) {
      fullName += ' $middleName';
    }
    fullName += ' $lastName';
    buffer.writeln(fullName);
    buffer.writeln('}\\par');

    // Contact information line (Arial 11, centered, not bold)
    buffer.writeln('{\\pard\\plain\\f0\\fs22\\qc');

    List<String> parts = [];

    // Email
    if (controllers.length > 3 && controllers[3].text.isNotEmpty) {
      parts.add(controllers[3].text);
    }

    // Phone
    if (controllers.length > 4 && controllers[4].text.isNotEmpty) {
      parts.add(controllers[4].text);
    }

    // City, Country
    String cityCountry = '';
    if (controllers.length > 5 && controllers[5].text.isNotEmpty) {
      cityCountry = controllers[5].text;
    }
    if (controllers.length > 6 && controllers[6].text.isNotEmpty) {
      if (cityCountry.isNotEmpty) {
        cityCountry += ', ${controllers[6].text}';
      } else {
        cityCountry = controllers[6].text;
      }
    }
    if (cityCountry.isNotEmpty) {
      parts.add(cityCountry);
    }

    // Website 1 (hyperlink)
    if (controllers.length > 7 && controllers[7].text.isNotEmpty) {
      String websiteText = controllers[7].text;
      String url = controllers.length > 8 && controllers[8].text.isNotEmpty
          ? controllers[8].text
          : websiteText;
      // Add http:// prefix if missing
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'http://$url';
      }
      parts.add(
          '{\\field{\\*\\fldinst HYPERLINK "$url"}{\\fldrslt $websiteText}}');
    }

    // Website 2 (hyperlink)
    if (controllers.length > 9 && controllers[9].text.isNotEmpty) {
      String websiteText = controllers[9].text;
      String url = controllers.length > 10 && controllers[10].text.isNotEmpty
          ? controllers[10].text
          : websiteText;
      // Add http:// prefix if missing
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'http://$url';
      }
      parts.add(
          '{\\field{\\*\\fldinst HYPERLINK "$url"}{\\fldrslt $websiteText}}');
    }

    // Join with separators
    buffer.writeln(parts.join(' | '));
    buffer.writeln('}');

    // Empty line before summary
    buffer.writeln('\\par\\par');

    // Summary (Arial 11, italic, left-aligned)
    if (controllers.length > 11 && controllers[11].text.isNotEmpty) {
      buffer.writeln('{\\pard\\plain\\f0\\fs22\\i');
      buffer.writeln(controllers[11].text);
      buffer.writeln('}\\par\\par');
    }
  }

  static void _writeCustomSectionRtf(
      StringBuffer buffer, dynamic customSection) {
    print('=== Processing custom section: ${customSection.sectionName} ===');
    print('=== Section type: ${customSection.runtimeType.toString()} ===');

    // Section title (Arial 11, all caps, bold, left aligned, no endline after)
    buffer.writeln('{\\pard\\plain\\f0\\fs22\\scaps\\b');
    buffer.writeln(customSection.sectionName.toUpperCase());
    buffer.writeln('}');

    // Get subsections and process based on type
    try {
      // Access state via sectionKey to call toMap()
      final state = customSection.sectionKey?.currentState;
      if (state != null) {
        final sectionMap = state.toMap();
        if (sectionMap.containsKey('subsections')) {
          final subsections = sectionMap['subsections'] as List;
          print('=== Number of subsections: ${subsections.length} ===');
          final sectionType = customSection.runtimeType.toString();
          if (sectionType.contains('Education')) {
            // Get all controllers for education section
            final controllers =
                customSection.allControllers as List<TextEditingController>;
            print('=== Number of controllers: ${controllers.length} ===');
            _writeEducationSubsectionRtf(buffer, subsections, controllers);
          } else if (sectionType.contains('Experience')) {
            // Get all controllers for experience section
            final controllers =
                customSection.allControllers as List<TextEditingController>;
            print('=== Number of controllers: ${controllers.length} ===');
            _writeExperienceSubsectionRtf(buffer, subsections, controllers);
          }
        }
      }
    } catch (e) {
      print('=== Error in custom section: $e ===');
      // Skip if section doesn't support toMap()
    }

    // Endline after section
    buffer.writeln('\\par');
  }

  static void _writeEducationSubsectionRtf(StringBuffer buffer,
      List subsections, List<TextEditingController> controllers) {
    // Education has 7 fields per subsection
    // Controllers: [Institution, City/Country, Degree, Field of Study, Start, End, Description]
    int fieldsPerSubsection = 7;

    for (int i = 0; i < subsections.length; i++) {
      int startIndex = i * fieldsPerSubsection;

      String institution = startIndex + 0 < controllers.length
          ? controllers[startIndex + 0].text
          : '';
      String cityCountry = startIndex + 1 < controllers.length
          ? controllers[startIndex + 1].text
          : '';
      String degree = startIndex + 2 < controllers.length
          ? controllers[startIndex + 2].text
          : '';
      String fieldOfStudy = startIndex + 3 < controllers.length
          ? controllers[startIndex + 3].text
          : '';
      String start = startIndex + 4 < controllers.length
          ? controllers[startIndex + 4].text
          : '';
      String end = startIndex + 5 < controllers.length
          ? controllers[startIndex + 5].text
          : '';
      String description = startIndex + 6 < controllers.length
          ? controllers[startIndex + 6].text
          : '';

      // First line: degree, field of study, Institution, city/country, start - end
      buffer.writeln('\\par');
      buffer.writeln('{\\pard\\plain\\f0\\fs22');
      List<String> parts = [];
      if (degree.isNotEmpty) parts.add(degree);
      if (fieldOfStudy.isNotEmpty) parts.add(fieldOfStudy);
      if (institution.isNotEmpty) parts.add(institution);
      if (cityCountry.isNotEmpty) parts.add(cityCountry);
      String dateRange = '';
      if (start.isNotEmpty) {
        dateRange = start;
        if (end.isNotEmpty) {
          dateRange += ' - $end';
        }
      }
      if (dateRange.isNotEmpty) parts.add(dateRange);
      buffer.writeln(parts.join(', '));
      buffer.writeln('}');

      // Description (if present)
      if (description.isNotEmpty) {
        buffer.writeln('\\par');
        buffer.writeln('{\\pard\\plain\\f0\\fs22');
        buffer.writeln(description);
        buffer.writeln('}');
      }
    }
  }

  static void _writeExperienceSubsectionRtf(StringBuffer buffer,
      List subsections, List<TextEditingController> controllers) {
    // Experience has 6 fields per subsection
    // Controllers: [Company, City/Country, Job Title, Start Date, End Date, Description]
    int fieldsPerSubsection = 6;

    for (int i = 0; i < subsections.length; i++) {
      int startIndex = i * fieldsPerSubsection;

      String company = startIndex + 0 < controllers.length
          ? controllers[startIndex + 0].text
          : '';
      String cityCountry = startIndex + 1 < controllers.length
          ? controllers[startIndex + 1].text
          : '';
      String jobTitle = startIndex + 2 < controllers.length
          ? controllers[startIndex + 2].text
          : '';
      String startDate = startIndex + 3 < controllers.length
          ? controllers[startIndex + 3].text
          : '';
      String endDate = startIndex + 4 < controllers.length
          ? controllers[startIndex + 4].text
          : '';
      String description = startIndex + 5 < controllers.length
          ? controllers[startIndex + 5].text
          : '';

      // Start with endline
      buffer.writeln('\\par');

      // First line: job title | company, City/Country | start - end (Arial 11, bold)
      buffer.writeln('{\\pard\\plain\\f0\\fs22\\b');
      List<String> parts = [];
      if (jobTitle.isNotEmpty) parts.add(jobTitle);
      String companyCity = '';
      if (company.isNotEmpty) {
        companyCity = company;
        if (cityCountry.isNotEmpty) {
          companyCity += ', $cityCountry';
        }
      }
      if (companyCity.isNotEmpty) parts.add(companyCity);
      String dateRange = '';
      if (startDate.isNotEmpty) {
        dateRange = startDate;
        if (endDate.isNotEmpty) {
          dateRange += ' - $endDate';
        }
      }
      if (dateRange.isNotEmpty) parts.add(dateRange);
      buffer.writeln(parts.join(' | '));
      buffer.writeln('}');

      // Description (if present) - not bold
      if (description.isNotEmpty) {
        buffer.writeln('\\par');
        buffer.writeln('{\\pard\\plain\\f0\\fs22');
        buffer.writeln(description);
        buffer.writeln('}');
        // One new line after description
        buffer.writeln('\\par');
      }
    }
  }
}
