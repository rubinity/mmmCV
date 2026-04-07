import 'package:flutter/material.dart';
import 'models/cv_section.dart';
import 'models/custom_section.dart' as custom_section;
import 'models/education_subsection.dart';
import 'models/experience_subsection.dart';
import 'models/user_data.dart';
import 'services/csv_service.dart';
import 'services/cv_data_service.dart';
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

class _CvFormPageState extends State<CvFormPage> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  String _selectedSectionType = 'education';
  final MainSection _mainSection = MainSection(sectionName: 'Main Information');
  List<custom_section.CustomSection> _sections = [];
  bool _isLoading = false;
  List<UserData> _userDataList = [];
  final _sectionNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData(); // This now handles auto-loading from CvDataService
  }

  @override
  void dispose() {
    print('=== DEBUG: dispose() called ===');
    print('=== DEBUG: About to auto-save ===');
    WidgetsBinding.instance.removeObserver(this);
    _autoSaveData(); // Save on exit
    print('=== DEBUG: Auto-save completed ===');
    _mainSection.allControllers.forEach((controller) => controller.dispose());
    _sectionNameController.dispose();
    print('=== DEBUG: Controllers disposed ===');
    super.dispose();
    print('=== DEBUG: dispose() finished ===');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('=== DEBUG: Lifecycle state changed to: $state ===');
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.inactive) {
      print('=== DEBUG: Triggering auto-save due to lifecycle state ===');
      _autoSaveData(); // Save when app goes to background or is closed
      print('=== DEBUG: Lifecycle auto-save completed ===');
    }
  }

  Future<void> _loadUserData() async {
    try {
      // Use CvDataService instead of old CsvService
      final cvData = await CvDataService.loadCvData();
      print('🧪 Loaded CV data: ${cvData.keys}');

      // Restore data if available
      if (cvData.isNotEmpty) {
        if (cvData.containsKey('mainSection')) {
          _restoreMainSectionData(
              cvData['mainSection'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      print('Error loading CV data: $e');
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

  // Auto-save data silently
  Future<void> _autoSaveData() async {
    try {
      print('=== DEBUG: Starting auto-save ===');

      // Check if controllers exist
      final controllers = _mainSection.allControllers;
      print('=== DEBUG: Found ${controllers.length} controllers ===');

      // Check controller values
      for (int i = 0; i < controllers.length; i++) {
        print('=== DEBUG: Controller $i: "${controllers[i].text}" ===');
      }

      // Extract data using CvDataService
      final cvData = CvDataService.extractAllData(
        controllers,
        _sections,
        [], // No sectionKeys in this simplified version
      );
      print('=== DEBUG: Extracted data: $cvData ===');

      // Check if data is empty
      if (cvData.isEmpty) {
        print('=== DEBUG: No data to save - cvData is empty ===');
        return;
      }

      // *** SYNCHRONOUS BACKUP SAVE FIRST ***
      print('=== DEBUG: Starting synchronous backup save ===');
      CvDataService.syncSaveCvData(cvData); // Immediate synchronous save
      print('=== DEBUG: Synchronous backup save completed ===');

      // Also try async save (might be interrupted)
      print('=== DEBUG: Starting async save ===');
      await CvDataService.saveCvData(cvData);
      print('=== DEBUG: Async save completed ===');

      print('=== DEBUG: Auto-save completed successfully ===');
    } catch (e, stackTrace) {
      print('=== DEBUG: Auto-save failed: $e ===');
      print('=== DEBUG: Stack trace: $stackTrace ===');
    }
  }

  // Restore main section data from saved data
  void _restoreMainSectionData(Map<String, dynamic> mainSectionData) {
    final controllers = _mainSection.allControllers;
    print('🔍 Found ${controllers.length} controllers');
    print('🔍 Main section data keys: ${mainSectionData.keys}');

    // Map field paths to controller indices based on MainSection structure
    final fieldMapping = {
      'main_section.personal_info.first_name': 0, // First Name
      'main_section.personal_info.middle_name': 1, // Middle Name
      'main_section.personal_info.last_name': 2, // Last Name
      'main_section.contact.email': 3, // Email
      'main_section.contact.phone': 4, // Phone
      'main_section.contact.city': 5, // City
      'main_section.contact.country': 6, // Country
      'main_section.online.website_1': 7, // Website 1
      'main_section.online.url_1': 8, // URL 1
      'main_section.online.website_2': 9, // Website 2
      'main_section.online.url_2': 10, // URL 2
      'main_section.summary.summary': 11, // Summary
    };

    // Restore each field using the mapping
    for (final entry in mainSectionData.entries) {
      final fieldPath = entry.key;
      final value = entry.value;

      if (fieldMapping.containsKey(fieldPath)) {
        final controllerIndex = fieldMapping[fieldPath]!;
        if (controllerIndex < controllers.length) {
          controllers[controllerIndex].text = value;
          print(
              '🔍 Restored $fieldPath (controller $controllerIndex) with value: "$value"');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test save button (temporary)
            ElevatedButton(
              onPressed: () {
                print('🧪 Manual save test...');
                _autoSaveData();
              },
              child: const Text('TEST SAVE'),
            ),
            const SizedBox(height: 16),

            // Main Section
            _mainSection.build(context),

            // Custom Sections Board
            if (_sections.isNotEmpty) ...[
              const SizedBox(height: 16),
              ..._sections.asMap().entries.map((entry) {
                final index = entry.key;
                final section = entry.value;
                return custom_section.CustomSection(
                  sectionName: section.sectionName,
                  initialSubsections: section.initialSubsections,
                  subsectionType: section.subsectionType,
                  onRemoveSection: () => _removeSection(index),
                );
              }).toList(),
            ],

            // Add Section Group
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add Section FieldGroup
                    FieldGroup(
                      title: 'Add Section',
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
                          onChanged: (value) {
                            setState(() {
                              _selectedSectionType = value!;
                            });
                          },
                        ),
                        FieldDefinition(
                          label: 'Section Name',
                          type: FieldType.text,
                          width: 200,
                          controller: _sectionNameController,
                        ),
                        FieldDefinition(
                          label: '',
                          type: FieldType.button,
                          buttonText: 'Add Section',
                          buttonIcon: Icons.add,
                          onPressed: () => _addSection(),
                        ),
                      ],
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

  void _removeSection(int index) {
    setState(() {
      if (index >= 0 && index < _sections.length) {
        _sections.removeAt(index);
      }
    });

    // Auto-save after removing section
    _autoSaveData();
  }

  void _addSection() {
    // Test auto-save by calling it manually
    print('🧪 Testing auto-save before adding section...');
    _autoSaveData();

    // Get the section name from the form field or use default
    String customSectionName = _sectionNameController.text.trim();
    String sectionName;

    if (customSectionName.isNotEmpty) {
      sectionName = customSectionName;
    } else {
      // Use default name if custom name is empty
      switch (_selectedSectionType) {
        case 'education':
          sectionName = 'Education';
          break;
        case 'experience':
          sectionName = 'Experience';
          break;
        default:
          sectionName = 'Custom Section';
          break;
      }
    }

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
            ExperienceSubsection(name: '${sectionName} Entry 1'),
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

    // Auto-save after adding section
    _autoSaveData();

    // Only clear section name field if it was used
    if (_sectionNameController.text.isNotEmpty) {
      _sectionNameController.clear();
    }
  }
}
