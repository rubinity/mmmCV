import 'dart:io';
import 'package:csv/csv.dart';
import '../models/user_data.dart';

class CsvService {
  static Future<String> get _dataPath async {
    final currentDir = Directory.current;
    return '${currentDir.path}/data';
  }

  static Future<File> get _localFile async {
    final path = await _dataPath;
    final dataDir = Directory(path);
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }
    return File('$path/user_data.csv');
  }

  static Future<void> saveUserData(UserData userData) async {
    try {
      final file = await _localFile;

      // Create CSV row with headers
      List<String> headers = [
        'firstName',
        'middleName',
        'lastName',
        'summary',
        'email',
        'phone',
        'address',
        'zipCode',
        'city',
        'country',
        'website1',
        'url1',
        'website2',
        'url2',
      ];

      // Convert user data to CSV row
      List<String> row = [
        userData.firstName,
        userData.middleName ?? '',
        userData.lastName,
        userData.summary ?? '',
        userData.email ?? '',
        userData.phone ?? '',
        userData.address ?? '',
        userData.zipCode ?? '',
        userData.city ?? '',
        userData.country ?? '',
        userData.website1 ?? '',
        userData.url1 ?? '',
        userData.website2 ?? '',
        userData.url2 ?? '',
      ];

      // Create CSV content (overwrite - single dataset)
      List<List<dynamic>> csvData = [headers, row];
      String csv = const ListToCsvConverter().convert(csvData);

      // Write to file (overwrite existing)
      await file.writeAsString(csv);
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

      // Convert CSV to list of rows
      List<List<dynamic>> rows = const CsvToListConverter().convert(content);

      // Skip headers, get only the data row (single dataset)
      if (rows.length <= 1) {
        return [];
      }

      List<UserData> userDataList = [];

      // Process only the first data row (single user)
      var row = rows[1]; // Skip header row
      if (row.length >= 14) {
        // Ensure we have all columns
        final userData = UserData(
          firstName: row[0]?.toString() ?? '',
          middleName:
              row[1]?.toString().isEmpty == true ? null : row[1]?.toString(),
          lastName: row[2]?.toString() ?? '',
          summary:
              row[3]?.toString().isEmpty == true ? null : row[3]?.toString(),
          email: row[4]?.toString().isEmpty == true ? null : row[4]?.toString(),
          phone: row[5]?.toString().isEmpty == true ? null : row[5]?.toString(),
          address:
              row[6]?.toString().isEmpty == true ? null : row[6]?.toString(),
          zipCode:
              row[7]?.toString().isEmpty == true ? null : row[7]?.toString(),
          city: row[8]?.toString().isEmpty == true ? null : row[8]?.toString(),
          country:
              row[9]?.toString().isEmpty == true ? null : row[9]?.toString(),
          website1:
              row[10]?.toString().isEmpty == true ? null : row[10]?.toString(),
          url1:
              row[11]?.toString().isEmpty == true ? null : row[11]?.toString(),
          website2:
              row[12]?.toString().isEmpty == true ? null : row[12]?.toString(),
          url2:
              row[13]?.toString().isEmpty == true ? null : row[13]?.toString(),
        );
        userDataList.add(userData);
      }

      return userDataList;
    } catch (e) {
      throw Exception('Failed to load user data: $e');
    }
  }
}
