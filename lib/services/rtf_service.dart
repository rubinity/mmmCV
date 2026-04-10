// import 'package:mmmcv/models/cv_section.dart'; // TODO: Fix CvSection import

class RtfService {
  // static Future<String> generateRtf(List<CvSection> sections) async { // TODO: Fix CvSection type
  static Future<String> generateRtf(List<dynamic> sections) async {
    final buffer = StringBuffer();

    // RTF Header
    buffer.writeln('{\\rtf1\\ansi\\ansicpg1252\\deff0');

    // Font table
    buffer.writeln('{\\fonttbl{\\f0\\fswiss Arial;}}');

    // Document settings
    buffer.writeln('{\\colortbl;\\red0\\green0\\blue0;}');
    buffer.writeln('\\viewkind4\\uc1\\pard\\f0\\fs24');

    // Content
    if (sections.isEmpty) {
      buffer.writeln('Empty CV');
    } else {
      for (final section in sections) {
        // Section title (bold)
        buffer.writeln('{\\b ${section.sectionName}\\b0}\\par');

        // Add section content
        try {
          final sectionMap = section.toMap();
          if (sectionMap.containsKey('subsections')) {
            final subsections = sectionMap['subsections'] as List;
            for (final subsection in subsections) {
              // Subsection name
              buffer.writeln('${subsection['name']}\\par');

              if (subsection.containsKey('fieldGroups')) {
                final fieldGroups = subsection['fieldGroups'] as List;
                for (final group in fieldGroups) {
                  // Field group title
                  buffer.writeln('{\\b ${group['title']}\\b0}\\par');

                  if (group.containsKey('fields')) {
                    final fields = group['fields'] as List;
                    for (final field in fields) {
                      // Field label and value
                      final label = field['label'] as String?;
                      final value = field['value'] as String?;
                      if (label != null && label.isNotEmpty) {
                        buffer.writeln('$label: ${value ?? ''}\\par');
                      }
                    }
                  }
                }
              }
            }
          }
        } catch (e) {
          // Skip if section doesn't support toMap()
        }

        buffer.writeln('\\par');
      }
    }

    // Close document
    buffer.writeln('}');

    return buffer.toString();
  }
}
