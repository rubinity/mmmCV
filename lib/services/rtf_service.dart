import 'package:flutter/material.dart';
import '../models/cv_section.dart';
import '../models/section_types.dart';
import 'rtf_section_writers.dart';

class RtfService {
  static const Map<SectionType, RtfSectionWriter> _writers = {
    SectionType.education: EducationWriter(),
    SectionType.experience: ExperienceWriter(),
    SectionType.projects: ProjectsWriter(),
    SectionType.simplest: SimplestWriter(),
    SectionType.languages: LanguageWriter(),
  };

  static Future<String> generateRtf(List<dynamic> sections) async {
    final buffer = StringBuffer();

    // RTF Header with margins (left 2.54cm=1440 twips, others 1.27cm=720 twips)
    buffer.writeln('{\\rtf1\\ansi\\ansicpg1254');
    buffer.writeln('{\\fonttbl\\f0\\fswiss\\fcharset0\\fprq2 Arial;}');
    buffer.writeln('\\margl1440\\margr720\\margt720\\margb720');
    buffer.writeln('{\\colortbl;\\red0\\green0\\blue0;}');
    buffer.writeln('\\viewkind4\\uc1\\pard\\f0\\fs24');

    if (sections.isEmpty) {
      buffer.writeln('Empty CV');
    } else {
      for (final section in sections) {
        if (section is MainSection) {
          _writeMainSectionRtf(buffer, section);
        } else {
          _writeCustomSectionRtf(buffer, section);
        }
      }
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  static void _writeMainSectionRtf(StringBuffer buffer, MainSection mainSection) {
    final controllers = mainSection.allControllers;

    // First Name, Middle Name, Last Name
    final firstName = controllers.isNotEmpty ? controllers[0].text : '';
    final middleName = controllers.length > 1 ? controllers[1].text : '';
    final lastName = controllers.length > 2 ? controllers[2].text : '';

    // Full name line (Arial 12, bold, centered)
    buffer.writeln('{\\pard\\plain\\f0\\fs24\\qc\\b');
    String fullName = firstName;
    if (middleName.isNotEmpty) fullName += ' $middleName';
    fullName += ' $lastName';
    buffer.writeln(fullName);
    buffer.writeln('}\\par');

    // Contact line (Arial 11, centered)
    buffer.writeln('{\\pard\\plain\\f0\\fs22\\qc');
    final parts = <String>[];

    if (controllers.length > 3 && controllers[3].text.isNotEmpty) {
      parts.add(controllers[3].text); // Email
    }
    if (controllers.length > 4 && controllers[4].text.isNotEmpty) {
      parts.add(controllers[4].text); // Phone
    }

    final city = controllers.length > 5 ? controllers[5].text : '';
    final country = controllers.length > 6 ? controllers[6].text : '';
    final cityCountry = [city, country].where((s) => s.isNotEmpty).join(', ');
    if (cityCountry.isNotEmpty) parts.add(cityCountry);

    // Website 1
    if (controllers.length > 7 && controllers[7].text.isNotEmpty) {
      parts.add(buildHyperlinkField(controllers[7].text,
          controllers.length > 8 ? controllers[8].text : '',
          fallbackToTextAsUrl: true));
    }
    // Website 2
    if (controllers.length > 9 && controllers[9].text.isNotEmpty) {
      parts.add(buildHyperlinkField(controllers[9].text,
          controllers.length > 10 ? controllers[10].text : '',
          fallbackToTextAsUrl: true));
    }

    buffer.writeln(parts.join(' | '));
    buffer.writeln('}');

    buffer.writeln('\\par\\par');

    // Summary (Arial 11, italic)
    if (controllers.length > 11 && controllers[11].text.isNotEmpty) {
      buffer.writeln('{\\pard\\plain\\f0\\fs22\\i');
      buffer.writeln(controllers[11].text);
      buffer.writeln('}\\par\\par');
    }
  }

  static void _writeCustomSectionRtf(StringBuffer buffer, dynamic customSection) {
    final controllers = customSection.getControllers(printedOnly: true)
        as List<TextEditingController>;
    if (controllers.isEmpty) return;

    buffer.writeln('{\\pard\\plain\\f0\\fs22\\scaps\\b');
    buffer.writeln(customSection.sectionName.toUpperCase());
    buffer.writeln('}');

    _writers[customSection.subsectionType]?.writeRtf(buffer, controllers);
  }
}
