import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'models/cv_section.dart';
import 'models/user_data.dart';
import 'services/csv_service.dart';
import 'services/rtf_service.dart';

void main() {
  runApp(const MmmCVApp());
}

class MmmCVApp extends StatelessWidget {
  const MmmCVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mmmCV - Make Me My CV',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CvFormPage(),
    );
  }
}

class CvFormPage extends StatefulWidget {
  const CvFormPage({super.key});

  @override
  State<CvFormPage> createState() => _CvFormPageState();
}

class _CvFormPageState extends State<CvFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedSectionType = 'education';
  List<CvSection> _sections = <CvSection>[];

  late CvSection _mainSection;

  bool _isLoading = false;
  List<UserData> _userDataList = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _mainSection = MainSection(
      sectionName: 'Personal Information',
    );
  }

  @override
  void dispose() {
    _mainSection.allControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userDataList = await CsvService.loadUserData();
      setState(() {
        _userDataList = userDataList;
        _sections = []; // Initialize sections list properly
        print('🧪 Loaded ${userDataList.length} user entries');
      });

      // If data exists, populate form fields
      if (userDataList.isNotEmpty) {
        // TODO: Implement data population by extracting controllers from UI elements
        print('🧪 User data loaded: ${userDataList.first.firstName}');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _saveAndGenerate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user data object
      // TODO: Extract data from UI elements instead of controllers
      final userData = UserData(
        firstName: 'TODO', // Extract from UI
        middleName: null,
        lastName: 'TODO', // Extract from UI
        summary: null,
        email: null,
        phone: null,
        address: null,
        zipCode: null,
        city: null,
        country: null,
        website1: null,
        url1: null,
        website2: null,
        url2: null,
      );

      // Save to CSV
      await CsvService.saveUserData(userData);

      // Generate RTF
      final rtfString = await RtfService.generateRtf(_sections);

      // Reload user data list
      await _loadUserData();

      if (mounted) {
        _showSuccessSnackBar('CV saved successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('mmmCV - Make Me My CV'),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Section
            _mainSection.build(context),

            // Custom Sections List
            if (_sections.isNotEmpty) ...[
              const SizedBox(height: 16),
              ..._sections.map((section) => section.build(context)).toList(),
            ],

            // Add Section Board
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add a section:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Add Section Form
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _selectedSectionType,
                            decoration: const InputDecoration(
                              labelText: 'Section Type',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'education',
                                child: Text('Education'),
                              ),
                              DropdownMenuItem(
                                value: 'experience',
                                child: Text('Experience'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedSectionType = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.label),
                              hintText: 'Enter a section name...',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: material.ElevatedButton(
                            onPressed: _addSection,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add),
                                Text('Add Section'),
                              ],
                            ),
                            style: material.ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addSection() {
    // TODO: Implement section addition by extracting name from UI element
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Section addition not implemented yet'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }
}
