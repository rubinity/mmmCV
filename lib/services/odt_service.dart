import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import '../models/user_data.dart';

class OdtService {
  static Future<String> get _outputPath async {
    final currentDir = Directory.current;
    return '${currentDir.path}/output';
  }

  static Future<File> _getOdtFile(String fileName) async {
    final path = await _outputPath;
    final outputDir = Directory(path);
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }
    return File('$path/$fileName.odt');
  }

  // Add user data to template
  static Future<File> createOdtFile(UserData userData,
      {String? fileName}) async {
    try {
      // Generate filename if not provided
      if (fileName == null || fileName.isEmpty) {
        fileName = 'cv_${userData.lastName.toLowerCase()}';
      }

      print('🔧 Generating ODT file: $fileName.odt');

      // Read the template
      final templateFile = File('templates/template.odt');
      if (!await templateFile.exists()) {
        print('❌ ERROR: Template file not found: ${templateFile.path}');
        throw Exception('Template file not found');
      }

      final templateBytes = await templateFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(templateBytes);

      // Find content.xml in template
      ArchiveFile? contentFile;
      for (final file in archive) {
        if (file.name == 'content.xml') {
          contentFile = file;
          break;
        }
      }

      if (contentFile == null) {
        print('❌ ERROR: content.xml not found in template');
        throw Exception('content.xml not found in template');
      }

      // Parse existing content.xml
      String contentXml = utf8.decode(contentFile.content as List<int>);
      print('📝 Original template content:');
      print(contentXml.substring(0, 300)); // Show first 300 chars

      // Generate user data
      String contactLine = _formatContactLine(userData);
      String websiteLine = _formatWebsiteLine(userData);
      String summary = userData.summary ?? '';

      print('👤 User data to add:');
      print('  Name: ${userData.fullName}');
      print('  Contact: $contactLine');
      print('  Websites: $websiteLine');
      print('  Summary: $summary');

      // Find where to insert our data - look for the first empty paragraph after name
      int insertPoint = contentXml.indexOf('</text:p>');
      if (insertPoint != -1) {
        // Insert our data after the first paragraph (which should be the name)
        String beforeInsert = contentXml.substring(0, insertPoint + 9);
        String afterInsert = contentXml.substring(insertPoint + 9);

        // Create new content with our data
        String newContent = '''$beforeInsert
            <text:p text:style-name="Standard">$contactLine</text:p>
            <text:p text:style-name="Standard">$websiteLine</text:p>
            <text:p text:style-name="Standard"/>
            <text:p text:style-name="Standard">$summary</text:p>
            <text:p text:style-name="Standard">Additional Information</text:p>
$afterInsert''';

        contentXml = newContent;
      } else {
        print('❌ ERROR: Could not find insertion point in template');
        throw Exception(
            'Invalid template structure: could not find where to insert data');
      }

      // Create new archive with our content
      final newArchive = Archive();

      // Copy all files except content.xml
      for (final file in archive) {
        if (file.name != 'content.xml') {
          newArchive.addFile(file);
        }
      }

      // Add our new content.xml
      newArchive.addFile(ArchiveFile(
          'content.xml', newContent.length, utf8.encode(newContent)));

      // Encode and write ZIP file
      final zipData = ZipEncoder().encode(newArchive);
      final outputFile = await _getOdtFile(fileName);

      if (zipData != null) {
        await outputFile.writeAsBytes(zipData);
        print('✅ ODT file created successfully: ${outputFile.path}');
        print('📊 File size: ${zipData.length} bytes');
      } else {
        print('❌ ERROR: Failed to encode ZIP archive');
        throw Exception('Failed to encode ZIP archive');
      }

      return outputFile;
    } catch (e) {
      print('❌ ERROR: Failed to create ODT file: $e');
      throw Exception('Failed to create ODT file: $e');
    }
  }

  static String _formatContactLine(UserData userData) {
    List<String> contactFields = [];

    if (userData.email != null && userData.email!.isNotEmpty) {
      contactFields.add(userData.email!);
    }
    if (userData.phone != null && userData.phone!.isNotEmpty) {
      contactFields.add(userData.phone!);
    }
    if (userData.address != null && userData.address!.isNotEmpty) {
      contactFields.add(userData.address!);
    }
    if (userData.zipCode != null && userData.zipCode!.isNotEmpty) {
      contactFields.add(userData.zipCode!);
    }
    if (userData.city != null && userData.city!.isNotEmpty) {
      contactFields.add(userData.city!);
    }
    if (userData.country != null && userData.country!.isNotEmpty) {
      contactFields.add(userData.country!);
    }

    if (contactFields.isEmpty) {
      return '';
    }

    // Join with | separators and capitalize first word after each |
    String contactLine = contactFields.join(' | ');
    List<String> parts = contactLine.split(' | ');

    for (int i = 0; i < parts.length; i++) {
      if (i > 0 && parts[i].isNotEmpty) {
        // Capitalize first word after |
        List<String> words = parts[i].split(' ');
        if (words.isNotEmpty) {
          words[0] = words[0][0].toUpperCase() + words[0].substring(1);
          parts[i] = words.join(' ');
        }
      }
    }

    return parts.join(' | ');
  }

  static String _formatWebsiteLine(UserData userData) {
    List<String> websites = [];

    if (userData.website1 != null && userData.website1!.isNotEmpty) {
      websites.add(userData.website1!);
    }

    if (userData.website2 != null && userData.website2!.isNotEmpty) {
      websites.add(userData.website2!);
    }

    if (websites.isEmpty) {
      return '';
    }

    return websites.join(' | ');
  }
}
