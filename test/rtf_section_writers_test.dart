import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mmmcv/services/rtf_section_writers.dart';

void main() {
  group('buildHyperlinkField', () {
    test('returns plain text when url is empty and no fallback requested', () {
      expect(buildHyperlinkField('Build a Cloud', ''), 'Build a Cloud');
    });

    test('wraps in HYPERLINK markup when url is provided', () {
      final result = buildHyperlinkField('Build a Cloud', 'https://example.com');
      expect(result,
          '{\\field{\\*\\fldinst HYPERLINK "https://example.com"}{\\fldrslt Build a Cloud}}');
    });

    test('prefixes http:// when url has no scheme', () {
      final result = buildHyperlinkField('Build a Cloud', 'example.com');
      expect(result,
          '{\\field{\\*\\fldinst HYPERLINK "http://example.com"}{\\fldrslt Build a Cloud}}');
    });

    test('falls back to text as url when fallbackToTextAsUrl is true and url is empty', () {
      final result =
          buildHyperlinkField('github', '', fallbackToTextAsUrl: true);
      expect(result,
          '{\\field{\\*\\fldinst HYPERLINK "http://github"}{\\fldrslt github}}');
    });
  });

  group('ProjectsWriter', () {
    List<TextEditingController> controllersFrom(List<String> values) =>
        values.map((v) => TextEditingController(text: v)).toList();

    test('prints affiliation - hyperlinked name, start - end, description', () {
      final buffer = StringBuffer();
      const ProjectsWriter().writeRtf(
        buffer,
        controllersFrom([
          'LEVEL3',
          '01.2024',
          '02.2024',
          'Build a Cloud',
          'https://example.com',
          'A description',
        ]),
      );
      final output = buffer.toString();
      expect(
          output,
          contains(
              'LEVEL3 - {\\field{\\*\\fldinst HYPERLINK "https://example.com"}{\\fldrslt Build a Cloud}}, 01.2024 - 02.2024'));
      expect(output, contains('A description'));
    });

    test('omits dash when affiliation is empty', () {
      final buffer = StringBuffer();
      const ProjectsWriter().writeRtf(
        buffer,
        controllersFrom(
            ['', '01.2024', '02.2024', 'Build a Cloud', 'https://example.com', '']),
      );
      expect(
          buffer.toString(),
          contains(
              '{\\field{\\*\\fldinst HYPERLINK "https://example.com"}{\\fldrslt Build a Cloud}}, 01.2024 - 02.2024'));
    });

    test('prints name as plain text when url is empty', () {
      final buffer = StringBuffer();
      const ProjectsWriter().writeRtf(
        buffer,
        controllersFrom(['LEVEL3', '01.2024', '02.2024', 'Build a Cloud', '', '']),
      );
      final output = buffer.toString();
      expect(output, contains('LEVEL3 - Build a Cloud, 01.2024 - 02.2024'));
      expect(output, isNot(contains('HYPERLINK')));
    });

    test('omits heading entirely when both affiliation and name are empty', () {
      final buffer = StringBuffer();
      const ProjectsWriter().writeRtf(
        buffer,
        controllersFrom(['', '01.2024', '02.2024', '', '', '']),
      );
      expect(buffer.toString(), contains('01.2024 - 02.2024'));
    });
  });
}
