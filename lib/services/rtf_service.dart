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
        _writeMainSectionRtf(buffer, section);
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
      buffer.writeln('}');
    }
  }
}
