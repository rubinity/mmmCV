import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'models/cv_section.dart';
import 'models/section_board.dart';
import 'models/custom_section.dart' as custom_section;
import 'models/education_subsection.dart';
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
  final MainSection _mainSection = MainSection(sectionName: 'Main Information');
  List<custom_section.CustomSection> _sections = [];
  bool _isLoading = false;
  List<UserData> _userDataList = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Section
            _mainSection.build(context),

            // Custom Sections Board
            if (_sections.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionBoard(
                sections: _sections,
                onSectionRemoved: _removeSection,
              ),
            ],

            // Add Section Group
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

                    // Add Section FieldGroup
                    FieldGroup(
                      title: '', // Hidden title for internal use only
                      fields: [
                        FieldDefinition(
                          label: 'Section Type',
                          type: FieldType.dropdown,
                          // width: 200,
                          initialValue: _selectedSectionType,
                          dropdownItems: const [
                            DropdownMenuItem(
                              value: 'education',
                              child: Text('Education'),
                            ),
                            DropdownMenuItem(
                              value: 'experience',
                              child: Text('Experience'),
                            ),
                          ],
                        ),
                        FieldDefinition(
                          label: 'Name',
                          type: FieldType.text,
                          width: 300,
                        ),
                        FieldDefinition(
                          label: '',
                          type: FieldType.button,
                          width: 150,
                          buttonText: 'Add Section',
                          buttonIcon: Icons.add,
                          onPressed: _addSection,
                        ),
                      ],
                      onAddEntry: null, // Button is now a field
                    ).build(context),
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
    // Get the section name from the form
    final sectionName = 'New Section'; // TODO: Get from form field

    // Create appropriate section based on type
    custom_section.CustomSection newSection;
    switch (_selectedSectionType) {
      case 'education':
        newSection = custom_section.CustomSection(
          sectionName: sectionName,
          initialSubsections: [
            EducationSubsection(name: '${sectionName} Entry 1'),
          ],
          subsectionType: custom_section.SubsectionType.education,
        );
        break;
      case 'experience':
        newSection = custom_section.CustomSection(
          sectionName: sectionName,
          initialSubsections: [
            custom_section.Subsection(
              name: '${sectionName} Entry 1',
              fieldGroups: [
                FieldGroup(
                  title: 'Position',
                  fields: [
                    FieldDefinition(
                      label: 'Job Title',
                      type: FieldType.text,
                      width: 300,
                    ),
                    FieldDefinition(
                      label: 'Company',
                      type: FieldType.text,
                      width: 300,
                    ),
                  ],
                ),
                FieldGroup(
                  title: 'Duration',
                  fields: [
                    FieldDefinition(
                      label: 'Start Date',
                      type: FieldType.text,
                      width: 150,
                    ),
                    FieldDefinition(
                      label: 'End Date',
                      type: FieldType.text,
                      width: 150,
                    ),
                  ],
                ),
              ],
            ),
          ],
          subsectionType: custom_section.SubsectionType.experience,
        );
        break;
      default:
        newSection = custom_section.CustomSection(
          sectionName: sectionName,
          subsectionType: custom_section.SubsectionType.generic,
        );
        break;
    }

    setState(() {
      _sections.add(newSection);
    });
  }

  void _removeSection(int index) {
    setState(() {
      if (index >= 0 && index < _sections.length) {
        _sections.removeAt(index);
      }
    });
  }
}
