import 'dart:io';
import '../models/user_data.dart';

class RtfService {
  static Future<String> get _outputPath async {
    final currentDir = Directory.current;
    return '${currentDir.path}/output';
  }

  static Future<File> _getRtfFile(String fileName) async {
    final path = await _outputPath;
    final outputDir = Directory(path);
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }
    return File('$path/$fileName.rtf');
  }

  static Future<File> createRtfFile(UserData userData,
      {String? fileName}) async {
    try {
      // Generate filename if not provided
      if (fileName == null || fileName.isEmpty) {
        fileName = 'cv_${userData.lastName.toLowerCase()}';
      }

      print('🔧 Generating RTF file: $fileName.rtf');

      // Create RTF from scratch
      String rtfContent = _createRtfFromScratch(
        userData.fullName,
        userData.email ?? '',
        userData.phone ?? '',
        userData.city ?? '',
        userData.country ?? '',
        userData.website1 ?? '',
        userData.url1 ?? '',
        userData.website2 ?? '',
        userData.url2 ?? '',
        userData.summary ?? '',
      );
      print('📝 Created RTF from scratch, length: ${rtfContent.length}');

      // Write to file
      final outputFile = await _getRtfFile(fileName);
      await outputFile.writeAsString(rtfContent);

      print('✅ RTF file created: ${outputFile.path}');
      return outputFile;
    } catch (e) {
      print('❌ ERROR: Failed to create RTF file: $e');
      throw Exception('Failed to create RTF file: $e');
    }
  }

  static String _escapeRtf(String text) {
    // Escape special RTF characters
    String result = text
        .replaceAll('\\', '\\\\')
        .replaceAll('{', '\\{')
        .replaceAll('}', '\\}')
        .replaceAll('"', '\\u8220?') // Use decimal code for quote with space
        .replaceAll(
            "'", '\\u8217?') // Use decimal code for apostrophe with space
        .replaceAll('\n', '\\par ')
        .replaceAll('\r', '');
    print('🧪 _escapeRtf input: "$text"');
    print('🧪 _escapeRtf output: "$result"');
    return result;
  }

  static String _createRtfFromScratch(
      String fullName,
      String email,
      String phone,
      String city,
      String country,
      String website1name,
      String website1url,
      String website2name,
      String website2url,
      String summary) {
    // RTF document with margins: left=2.03cm, right=1.27cm, top=1.27cm, bottom=1.27cm
    String opening = '{\\rtf1\\ansi\\deff0'
        '{\\fonttbl{\\f0\\fswiss\\fprq2\\fcharset0 Arial;}}'
        '\\margl1440\\margr720\\margt720\\margb720';

    String closing = '}';

    // Name group
    String nameGroup = '\\pard\\qc\\b\\f0\\fs24 $fullName\\b0\\fs20\\par';

    // Personal data group (excluding full name)
    List<String> personalData = [];
    if (email.isNotEmpty) personalData.add(email);
    if (phone.isNotEmpty) personalData.add(phone);
    if (city.isNotEmpty && country.isNotEmpty)
      personalData.add('$city, $country');

    // Handle websites as hyperlinks
    if (website1name.isNotEmpty) {
      String finalWebsite1Url =
          website1url.startsWith('http') ? website1url : 'http://$website1url';
      personalData.add(
          '{\\field{\\*\\fldinst HYPERLINK "$finalWebsite1Url" }{\\fldrslt {\\ul $website1name}}}');
    }
    if (website2name.isNotEmpty) {
      String finalWebsite2Url =
          website2url.startsWith('http') ? website2url : 'http://$website2url';
      personalData.add(
          '{\\field{\\*\\fldinst HYPERLINK "$finalWebsite2Url" }{\\fldrslt {\\ul $website2name}}}');
    }

    String personalDataGroup = '';
    if (personalData.isNotEmpty) {
      personalDataGroup =
          '\\pard\\qc\\f0\\fs22 ${personalData.join(' | ')}\\par';
    }

    // Summary section (one empty line before, cursive, left-aligned)
    String summarySection = '';
    if (summary.isNotEmpty) {
      String escapedSummary = _escapeRtf(summary);
      print('🧪 Original summary: "$summary"');
      print('🧪 Escaped summary: "$escapedSummary"');
      summarySection = '\\par\\pard\\i\\f0\\fs22 $escapedSummary\\i0\\par';
    }

    return opening + nameGroup + personalDataGroup + summarySection + closing;
  }

  static String _generateNameSection(String fullName) {
    // Simple text for name - no RTF formatting, just plain text
    return '$fullName\n\n';
  }
}
