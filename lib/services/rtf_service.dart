// import 'package:mmmcv/models/cv_section.dart'; // TODO: Fix CvSection import

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
      buffer.writeln('{\\pard\\plain\\f0\\fs24');
      buffer.writeln('Empty CV');
      buffer.writeln('}');
    } else {
      for (final section in sections) {
        buffer.writeln('{\\pard\\plain\\f0\\fs24');
        buffer.writeln('\\qc');

        // Section title (bold)
        buffer.writeln('{\\b ${section.sectionName}\\b0}');
        buffer.writeln('}');

        // Add section content
        try {
          final sectionMap = section.toMap();
          if (sectionMap.containsKey('subsections')) {
            final subsections = sectionMap['subsections'] as List;
            for (final subsection in subsections) {
              buffer.writeln('{\\pard\\plain\\f0\\fs24');
              buffer.writeln('\\qc');
              buffer.writeln('${subsection['name']}');
              buffer.writeln('}');

              if (subsection.containsKey('fieldGroups')) {
                final fieldGroups = subsection['fieldGroups'] as List;
                for (final group in fieldGroups) {
                  buffer.writeln('{\\pard\\plain\\f0\\fs24');
                  buffer.writeln('\\qc');
                  buffer.writeln('{\\b ${group['title']}\\b0}');
                  buffer.writeln('}');

                  if (group.containsKey('fields')) {
                    final fields = group['fields'] as List;
                    for (final field in fields) {
                      buffer.writeln('{\\pard\\plain\\f0\\fs24');
                      buffer.writeln('\\qc');
                      // Field label and value
                      final label = field['label'] as String?;
                      final value = field['value'] as String?;
                      if (label != null && label.isNotEmpty) {
                        buffer.writeln('$label: ${value ?? ''}');
                      }
                      buffer.writeln('}');
                    }
                  }
                }
              }
            }
          }
        } catch (e) {
          // Skip if section doesn't support toMap()
        }
      }
    }

    // Close document
    buffer.writeln('}');

    return buffer.toString();
  }
}
