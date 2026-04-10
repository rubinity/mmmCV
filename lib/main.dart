import 'package:flutter/material.dart';
import 'models/cv_section.dart';
import 'models/custom_section.dart' as custom_section;
import 'models/education_custom_section.dart';
import 'models/experience_custom_section.dart';
import 'models/projects_custom_section.dart';
import 'models/section_types.dart';
import 'models/user_data.dart';
import 'services/csv_service.dart';
import 'services/rtf_service.dart';
import 'services/cv_data_service.dart';

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
  late MainSection _mainSection;
  Map<String, custom_section.CustomSection> _sections =
      {}; // Changed from List to Map
  Map<String, GlobalKey<custom_section.CustomSectionState>> _sectionKeys = {};
  Map<String, custom_section.CustomSection> _sectionWidgets =
      {}; // Store widget instances
  Map<String, List<TextEditingController>> _sectionControllers =
      {}; // Parent-managed controllers
  bool _isLoading = false;
  List<UserData> _userDataList = [];
  final _sectionNameController = TextEditingController();
  bool _isDisposed = false; // Add disposal flag

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mainSection = MainSection(sectionName: 'Main Information');
    _loadUserData(); // This now handles auto-loading from CvDataService
  }

  @override
  void dispose() {
    print('=== DEBUG: dispose() called ===');
    _isDisposed = true; // Set disposal flag
    WidgetsBinding.instance.removeObserver(this);

    print('=== DEBUG: About to auto-save BEFORE disposing controllers ===');
    // Save BEFORE disposing controllers
    _autoSaveData();
    print('=== DEBUG: Auto-save completed ===');

    // Dispose controllers AFTER saving
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

    // Don't save if widget is disposed
    if (_isDisposed) {
      print('=== DEBUG: Widget disposed, skipping lifecycle save ===');
      return;
    }

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
      // Load preloaded CV data structure
      final preloadedData = await CvDataService.loadCvData();
      print('🧪 Loaded preloaded CV data');
      print('🧪 Main section values: ${preloadedData.mainSectionValues}');
      print('🧪 Custom sections count: ${preloadedData.customSections.length}');

      // Rebuild MainSection with preloaded values
      _mainSection = MainSection(
        sectionName: 'Main Information',
        preloadedValues: preloadedData.mainSectionValues,
      );
      setState(() {}); // Trigger rebuild to show updated MainSection

      // Build custom sections from preloaded data
      if (!preloadedData.isEmpty) {
        for (final sectionMetadata in preloadedData.customSections) {
          final subsections = preloadedData
                  .customSectionSubsections[sectionMetadata.sectionId] ??
              [];
          print(
              '🔍 Building section: ${sectionMetadata.sectionName} (ID: ${sectionMetadata.sectionId}) with ${subsections.length} subsections');

          _createSectionFromPreloadedData(
            sectionMetadata.sectionType.name,
            sectionMetadata.sectionName,
            sectionMetadata.sectionId,
            subsections,
          );
        }
      } else {
        print('🔍 No preloaded CV data found');
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
      final rtfString = await RtfService.generateRtf(_sections.values.toList());

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
      print('=== DEBUG: Number of sections: ${_sections.length} ===');

      // Check if controllers exist
      final controllers = _mainSection.allControllers;
      print('=== DEBUG: Found ${controllers.length} main controllers ===');

      // Check main controller values
      for (int i = 0; i < controllers.length; i++) {
        print('=== DEBUG: Main Controller $i: "${controllers[i].text}" ===');
      }

      // Check custom sections
      int sectionIndex = 0;
      for (final section in _sections.values) {
        final sectionControllers = section.allControllers;
        print(
            '=== DEBUG: Section $sectionIndex (${section.sectionName}): ${sectionControllers.length} controllers ===');
        for (int j = 0; j < sectionControllers.length; j++) {
          print(
              '=== DEBUG: Section $sectionIndex Controller $j: "${sectionControllers[j].text}" ===');
        }
        sectionIndex++;
      }

      // Extract data using CvDataService
      final cvData = CvDataService.extractAllData(
        controllers,
        _sections.values.toList(),
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
      // print('=== DEBUG: Starting async save ===');
      // await CvDataService.saveCvData(cvData);
      // print('=== DEBUG: Async save completed ===');

      print('=== DEBUG: Auto-save completed successfully ===');
    } catch (e, stackTrace) {
      print('=== DEBUG: Auto-save failed: $e ===');
      print('=== DEBUG: Stack trace: $stackTrace ===');
    }
  }

  // Create section from preloaded data
  void _createSectionFromPreloadedData(
    String type,
    String name,
    String sectionId,
    List<SubsectionData> subsections,
  ) {
    // Create section using helper function with preloaded subsections
    _createSection(type, name,
        sectionId: sectionId, preloadedSubsections: subsections);
    print(
        '🔍 Created section with ${subsections.length} preloaded subsections ===');
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
              ..._sections.values.toList(),
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
                            DropdownMenuItem(
                              value: 'projects',
                              child: Text('Projects'),
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

  void _removeSectionById(String sectionId) {
    setState(() {
      final removedSection = _sections.remove(sectionId);
      if (removedSection != null) {
        _sectionKeys.remove(removedSection.sectionName);
      }
    });

    // Auto-save after removing section
    _autoSaveData();
  }

  // Helper function to extract section name from type and custom name
  String _extractSectionName(String selectedType, String customName) {
    if (customName.isNotEmpty) {
      return customName;
    } else {
      switch (selectedType) {
        case 'education':
          return 'Education';
        case 'experience':
          return 'Experience';
        case 'projects':
          return 'Projects';
        default:
          return selectedType;
      }
    }
  }

  // Helper function to create sections (used for both manual creation and restoration)
  custom_section.CustomSection _createSection(String type, String name,
      {String? sectionId, List<SubsectionData>? preloadedSubsections}) {
    final sectionKey = GlobalKey<custom_section.CustomSectionState>();
    _sectionKeys[name] = sectionKey;

    // Direct mapping from string to SectionType using global enum
    final sectionType = SectionType.values.firstWhere(
      (sectionType) => sectionType.name == type,
    );

    final actualSectionId =
        sectionId ?? DateTime.now().millisecondsSinceEpoch.toString();

    // Create appropriate subclass based on section type
    custom_section.CustomSection newSection;
    switch (sectionType) {
      case SectionType.education:
        newSection = EducationCustomSection(
          key: sectionKey,
          sectionName: name,
          sectionKey: sectionKey,
          sectionId: actualSectionId,
          preloadedSubsections: preloadedSubsections,
          onRemoveSection: () => _removeSectionById(actualSectionId),
        );
        break;
      case SectionType.experience:
        newSection = ExperienceCustomSection(
          key: sectionKey,
          sectionName: name,
          sectionKey: sectionKey,
          sectionId: actualSectionId,
          preloadedSubsections: preloadedSubsections,
          onRemoveSection: () => _removeSectionById(actualSectionId),
        );
        break;
      case SectionType.projects:
        newSection = ProjectsCustomSection(
          key: sectionKey,
          sectionName: name,
          sectionKey: sectionKey,
          sectionId: actualSectionId,
          preloadedSubsections: preloadedSubsections,
          onRemoveSection: () => _removeSectionById(actualSectionId),
        );
        break;
    }

    // Add section to map and trigger rebuild
    setState(() {
      _sections[actualSectionId] = newSection;
    });

    return newSection;
  }

  void _addSection() {
    // Test auto-save by calling it manually
    print('🧪 Testing auto-save before adding section...');
    _autoSaveData();

    // Get the section name using helper function
    final sectionName = _extractSectionName(
        _selectedSectionType, _sectionNameController.text.trim());

    // Create section using helper function (setState is inside)
    _createSection(_selectedSectionType, sectionName);

    // Auto-save after adding section
    _autoSaveData();

    // Only clear section name field if it was used
    if (_sectionNameController.text.isNotEmpty) {
      _sectionNameController.clear();
    }
  }
}
