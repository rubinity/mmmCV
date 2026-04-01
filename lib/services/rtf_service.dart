// import 'package:mmmcv/models/cv_section.dart'; // TODO: Fix CvSection import

class RtfService {
  // static Future<String> generateRtf(List<CvSection> sections) async { // TODO: Fix CvSection type
  static Future<String> generateRtf(List<dynamic> sections) async {
    // Temporary fix
    final buffer = StringBuffer();

    buffer.writeln('{\\rtf1\\ansi\\ansicpg1254');
    buffer.writeln('{\\fonttbl\\f0\\fswiss\\fcharset0\\fprq2');

    for (final section in sections) {
      buffer.writeln('{\\pard\\plain\\f0\\fs24');
      buffer.writeln('\\qc');

      // Add section title
      buffer.writeln('{\\fs24\\b\\i0\\fs20\\b\\i0}');
      buffer.writeln('${section.sectionName}');
      buffer.writeln('{\\fs24\\b\\i0\\fs20\\b\\i0}');

      // Add section content
      final sectionMap = section.toMap();
      if (sectionMap.containsKey('subsections')) {
        final subsections = sectionMap['subsections'] as List;
        for (final subsection in subsections) {
          buffer.writeln('{\\pard\\plain\\f0\\fs24');
          buffer.writeln('\\qc');
          buffer.writeln('{\\fs24\\b\\i0\\fs20\\b\\i0}');
          buffer.writeln('${subsection['name']}');
          buffer.writeln('{\\fs24\\b\\i0\\fs20\\b\\i0}');

          if (subsection.containsKey('fieldGroups')) {
            final fieldGroups = subsection['fieldGroups'] as List;
            for (final group in fieldGroups) {
              buffer.writeln('{\\pard\\plain\\f0\\fs24');
              buffer.writeln('\\qc');
              buffer.writeln('{\\fs24\\b\\i0\\fs20\\b\\i0}');
              buffer.writeln('${group['title']}');
              buffer.writeln('{\\fs24\\b\\i0\\fs20\\b\\i0}');

              if (group.containsKey('fields')) {
                final fields = group['fields'] as List;
                for (final field in fields) {
                  buffer.writeln('{\\pard\\plain\\f0\\fs24');
                  buffer.writeln('\\qc');
                  buffer.writeln('{\\fs24\\b\\i0\\fs20\\b\\i0}');
                  buffer.writeln('${field['label']}');
                  buffer.writeln('{\\fs24\\b\\i0\\fs20\\b\\i0}');
                }
              }
            }
          }
        }
      }

      buffer.writeln('{\\pard}');
      buffer.writeln('}');
    }

    buffer.writeln('}');

    return buffer.toString();
  }
}
