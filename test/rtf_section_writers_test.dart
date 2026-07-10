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
}
