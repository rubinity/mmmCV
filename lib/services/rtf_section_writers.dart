import 'package:flutter/material.dart';

/// Builds RTF HYPERLINK markup for [text]. When [url] is empty and
/// [fallbackToTextAsUrl] is false (the default), returns [text] unchanged
/// with no hyperlink markup — used where the display text isn't URL-like
/// (e.g. a project name). When [fallbackToTextAsUrl] is true, falls back to
/// using [text] itself as the URL — used where the display text usually IS
/// URL-like (e.g. a website name like "github").
String buildHyperlinkField(String text, String url,
    {bool fallbackToTextAsUrl = false}) {
  if (url.isEmpty && !fallbackToTextAsUrl) {
    return text;
  }
  final resolvedUrl = url.isNotEmpty ? url : text;
  final fullUrl = resolvedUrl.startsWith('http://') ||
          resolvedUrl.startsWith('https://')
      ? resolvedUrl
      : 'http://$resolvedUrl';
  return '{\\field{\\*\\fldinst HYPERLINK "$fullUrl"}{\\fldrslt $text}}';
}

abstract class RtfSectionWriter {
  const RtfSectionWriter();
  void writeRtf(StringBuffer buffer, List<TextEditingController> controllers);
}

class EducationWriter extends RtfSectionWriter {
  const EducationWriter();

  @override
  void writeRtf(StringBuffer buffer, List<TextEditingController> controllers) {
    // 7 fields per entry: Institution, City/Country, Degree, Field of Study, Start, End, Description
    const fieldsPerEntry = 7;
    final totalEntries = controllers.length ~/ fieldsPerEntry;

    for (int i = 0; i < totalEntries; i++) {
      if (i == 0) buffer.writeln('\\par');
      final s = i * fieldsPerEntry;
      final institution = controllers[s].text;
      final cityCountry = controllers[s + 1].text;
      final degree = controllers[s + 2].text;
      final fieldOfStudy = controllers[s + 3].text;
      final start = controllers[s + 4].text;
      final end = controllers[s + 5].text;
      final description = controllers[s + 6].text;

      buffer.writeln('{\\pard\\plain\\f0\\fs22');
      final parts = <String>[];
      if (degree.isNotEmpty) parts.add(degree);
      if (fieldOfStudy.isNotEmpty) parts.add(fieldOfStudy);
      if (institution.isNotEmpty) parts.add(institution);
      if (cityCountry.isNotEmpty) parts.add(cityCountry);
      if (start.isNotEmpty) parts.add(end.isNotEmpty ? '$start - $end' : start);
      buffer.writeln(parts.join(', '));
      buffer.writeln('}');
      buffer.writeln('\\par');

      if (description.isNotEmpty) {
        buffer.writeln('{\\pard\\plain\\f0\\fs22');
        buffer.writeln(description);
        buffer.writeln('}');
        buffer.writeln('\\par');
      }

      final needsBlankLine = !(totalEntries == 1 && description.isEmpty);
      if (needsBlankLine) buffer.writeln('\\par');
    }
  }
}

class ExperienceWriter extends RtfSectionWriter {
  const ExperienceWriter();

  @override
  void writeRtf(StringBuffer buffer, List<TextEditingController> controllers) {
    // 6 fields per entry: Company, City/Country, Job Title, Start Date, End Date, Description
    const fieldsPerEntry = 6;
    final totalEntries = controllers.length ~/ fieldsPerEntry;

    for (int i = 0; i < totalEntries; i++) {
      if (i == 0) buffer.writeln('\\par');
      final s = i * fieldsPerEntry;
      final company = controllers[s].text;
      final cityCountry = controllers[s + 1].text;
      final jobTitle = controllers[s + 2].text;
      final startDate = controllers[s + 3].text;
      final endDate = controllers[s + 4].text;
      final description = controllers[s + 5].text;

      buffer.writeln('{\\pard\\plain\\f0\\fs22\\b');
      final parts = <String>[];
      if (jobTitle.isNotEmpty) parts.add(jobTitle);
      final companyLocation =
          [company, cityCountry].where((s) => s.isNotEmpty).join(', ');
      if (companyLocation.isNotEmpty) parts.add(companyLocation);
      if (startDate.isNotEmpty) {
        parts.add(endDate.isNotEmpty ? '$startDate - $endDate' : startDate);
      }
      buffer.writeln(parts.join(' | '));
      buffer.writeln('}');
      buffer.writeln('\\par');

      if (description.isNotEmpty) {
        buffer.writeln('{\\pard\\plain\\f0\\fs22');
        buffer.writeln(description);
        buffer.writeln('}');
        buffer.writeln('\\par');
      }

      final needsBlankLine = !(totalEntries == 1 && description.isEmpty);
      if (needsBlankLine) buffer.writeln('\\par');
    }
  }
}

class ProjectsWriter extends RtfSectionWriter {
  const ProjectsWriter();

  @override
  void writeRtf(StringBuffer buffer, List<TextEditingController> controllers) {
    // 4 fields per entry: Project Name, Start, End, Description
    const fieldsPerEntry = 4;
    final totalEntries = controllers.length ~/ fieldsPerEntry;

    for (int i = 0; i < totalEntries; i++) {
      if (i == 0) buffer.writeln('\\par');
      final s = i * fieldsPerEntry;
      final projectName = controllers[s].text;
      final start = controllers[s + 1].text;
      final end = controllers[s + 2].text;
      final description = controllers[s + 3].text;

      buffer.writeln('{\\pard\\plain\\f0\\fs22\\b');
      final parts = <String>[];
      if (projectName.isNotEmpty) parts.add(projectName);
      if (start.isNotEmpty) parts.add(end.isNotEmpty ? '$start - $end' : start);
      buffer.writeln(parts.join(', '));
      buffer.writeln('}');
      buffer.writeln('\\par');

      if (description.isNotEmpty) {
        buffer.writeln('{\\pard\\plain\\f0\\fs22');
        buffer.writeln(description);
        buffer.writeln('}');
        buffer.writeln('\\par');
      }

      final needsBlankLine = !(totalEntries == 1 && description.isEmpty);
      if (needsBlankLine) buffer.writeln('\\par');
    }
  }
}

class LanguageWriter extends RtfSectionWriter {
  const LanguageWriter();

  @override
  void writeRtf(StringBuffer buffer, List<TextEditingController> controllers) {
    // 2 fields per entry: Language, Level — all entries on one line, never a blank line after
    const fieldsPerEntry = 2;
    buffer.write('{\\pard\\plain\\f0\\fs22\\u32?');
    final entries = <String>[];
    for (int i = 0; i < controllers.length ~/ fieldsPerEntry; i++) {
      final s = i * fieldsPerEntry;
      final language = controllers[s].text;
      final level = controllers[s + 1].text;
      if (language.isNotEmpty) {
        entries.add(level.isNotEmpty ? '$language ($level)' : language);
      }
    }
    buffer.write(entries.join(', '));
    buffer.writeln('}');
    buffer.writeln('\\par');
  }
}

class SimplestWriter extends RtfSectionWriter {
  const SimplestWriter();

  @override
  void writeRtf(StringBuffer buffer, List<TextEditingController> controllers) {
    // 1 field per entry: Description — each entry is always single-line
    final totalEntries = controllers.length;

    for (int i = 0; i < totalEntries; i++) {
      final text = controllers[i].text;
      if (text.isNotEmpty) {
        buffer.write('{\\pard\\plain\\f0\\fs22\\u32?');
        buffer.write(text);
        buffer.writeln('}');
        buffer.writeln('\\par');
      }
    }
    if (totalEntries > 1) buffer.writeln('\\par');
  }
}
