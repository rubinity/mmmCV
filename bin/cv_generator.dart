import 'dart:io';
import 'dart:convert';

class UserData {
  final String firstName;
  final String? middleName;
  final String lastName;
  final String note;

  UserData({
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.note,
  });

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'middleName': middleName ?? '',
      'lastName': lastName,
      'note': note,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      firstName: map['firstName'] ?? '',
      middleName: map['middleName']?.isEmpty == true ? null : map['middleName'],
      lastName: map['lastName'] ?? '',
      note: map['note'] ?? '',
    );
  }

  String toCsvRow() {
    return '"$firstName","${middleName ?? ''}","$lastName","$note"';
  }

  static UserData fromCsvRow(String row) {
    List<String> fields = row.split(',').map((f) => 
      f.replaceAll('"', '').trim()
    ).toList();
    
    return UserData(
      firstName: fields.length > 0 ? fields[0] : '',
      middleName: fields.length > 1 && fields[1].isNotEmpty ? fields[1] : null,
      lastName: fields.length > 2 ? fields[2] : '',
      note: fields.length > 3 ? fields[3] : '',
    );
  }
}

class CsvService {
  static Future<File> get _localFile async {
    final currentDir = Directory.current;
    return File('${currentDir.path}/user_data.csv');
  }

  static Future<void> saveUserData(UserData userData) async {
    try {
      final file = await _localFile;
      
      // Check if file exists to determine if we need headers
      bool fileExists = await file.exists();
      
      // Read existing content
      List<String> lines = [];
      if (fileExists) {
        String content = await file.readAsString();
        lines = content.split('\n').where((line) => line.isNotEmpty).toList();
      } else {
        // Add headers for new file
        lines.add('firstName,middleName,lastName,note');
      }
      
      // Add new row
      lines.add(userData.toCsvRow());
      
      // Write back to file
      String csv = lines.join('\n');
      await file.writeAsString(csv);
      
      print('✓ Data saved to CSV file');
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  static Future<List<UserData>> loadUserData() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }

      String content = await file.readAsString();
      if (content.isEmpty) {
        return [];
      }

      List<String> lines = content.split('\n').where((line) => line.isNotEmpty).toList();
      
      // Skip header row and convert to UserData objects
      List<UserData> userDataList = [];
      for (int i = 1; i < lines.length; i++) {
        userDataList.add(UserData.fromCsvRow(lines[i]));
      }
      
      return userDataList;
    } catch (e) {
      throw Exception('Failed to load user data: $e');
    }
  }
}

class OdtService {
  static Future<File> _getOdtFile(String fileName) async {
    final currentDir = Directory.current;
    return File('${currentDir.path}/$fileName.odt');
  }

  static Future<String> generateOdtContent(UserData userData) async {
    String fullName = userData.fullName.toUpperCase();
    String note = userData.note;
    
    // Capitalize first letter of note
    if (note.isNotEmpty) {
      note = note[0].toUpperCase() + note.substring(1);
    }

    // Basic ODT content.xml structure
    String contentXml = '''<?xml version="1.0" encoding="UTF-8"?>
<office:document-content 
    xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    office:version="1.2">
    
    <office:body>
        <office:text>
            <text:p text:style-name="Standard">$fullName</text:p>
            <text:p text:style-name="Standard"/>
            <text:p text:style-name="Standard">$note</text:p>
        </office:text>
    </office:body>
    
</office:document-content>''';

    return contentXml;
  }

  static Future<File> createOdtFile(UserData userData, {String? fileName}) async {
    try {
      // Generate filename if not provided
      if (fileName == null || fileName.isEmpty) {
        fileName = 'cv_${userData.lastName.toLowerCase()}';
      }

      final file = await _getOdtFile(fileName);
      
      // For now, create a simple XML file that can be opened as ODT
      // In a real implementation, we'd need to create a proper ZIP file
      // with all required ODT structure files
      
      String content = await generateOdtContent(userData);
      await file.writeAsString(content);
      
      print('✓ ODT file created: ${file.path}');
      return file;
    } catch (e) {
      throw Exception('Failed to create ODT file: $e');
    }
  }
}

void main() async {
  print('=== CV Generator ===');
  print('First step: Basic CV with name and note\n');

  while (true) {
    print('\n1. Add new user data');
    print('2. View existing data');
    print('3. Generate CV');
    print('4. Exit');
    print('Choose an option: ');

    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await _addUserData();
        break;
      case '2':
        await _viewExistingData();
        break;
      case '3':
        await _generateCv();
        break;
      case '4':
        print('Goodbye!');
        return;
      default:
        print('Invalid option. Please try again.');
    }
  }
}

Future<void> _addUserData() async {
  print('\n--- Add User Data ---');
  
  print('First Name: ');
  String? firstName = stdin.readLineSync();
  
  print('Middle Name (optional, press Enter to skip): ');
  String? middleName = stdin.readLineSync();
  
  print('Last Name: ');
  String? lastName = stdin.readLineSync();
  
  print('Note: ');
  String? note = stdin.readLineSync();

  if (firstName == null || firstName.trim().isEmpty ||
      lastName == null || lastName.trim().isEmpty ||
      note == null || note.trim().isEmpty) {
    print('❌ First name, last name, and note are required!');
    return;
  }

  final userData = UserData(
    firstName: firstName.trim(),
    middleName: middleName?.trim().isEmpty == true ? null : middleName?.trim(),
    lastName: lastName.trim(),
    note: note.trim(),
  );

  try {
    await CsvService.saveUserData(userData);
    print('✓ User data saved successfully!');
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<void> _viewExistingData() async {
  print('\n--- Existing User Data ---');
  
  try {
    List<UserData> userDataList = await CsvService.loadUserData();
    
    if (userDataList.isEmpty) {
      print('No user data found.');
      return;
    }

    for (int i = 0; i < userDataList.length; i++) {
      final userData = userDataList[i];
      print('${i + 1}. ${userData.fullName} - Note: ${userData.note}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<void> _generateCv() async {
  print('\n--- Generate CV ---');
  
  try {
    List<UserData> userDataList = await CsvService.loadUserData();
    
    if (userDataList.isEmpty) {
      print('No user data found. Please add user data first.');
      return;
    }

    print('Select user data:');
    for (int i = 0; i < userDataList.length; i++) {
      final userData = userDataList[i];
      print('${i + 1}. ${userData.fullName}');
    }
    
    print('Enter choice (number): ');
    String? choice = stdin.readLineSync();
    
    int? index = int.tryParse(choice ?? '');
    if (index == null || index < 1 || index > userDataList.length) {
      print('❌ Invalid choice!');
      return;
    }

    final selectedUserData = userDataList[index - 1];
    
    print('Enter filename (optional, press Enter for default): ');
    String? fileName = stdin.readLineSync();
    
    await OdtService.createOdtFile(selectedUserData, fileName: fileName);
    
    print('\n✓ CV generated successfully!');
    print('Format: Full name in ALL CAPS, empty line, note with capital first letter');
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
