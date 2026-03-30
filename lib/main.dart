import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/user_data.dart';
import 'models/cv_section.dart';
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
        // appBarTheme: const AppBarTheme(
        //   backgroundColor: Color.fromARGB(255, 9, 70, 120),
        //   foregroundColor: Colors.white,
        // ),
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
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _noteController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _website1Controller = TextEditingController();
  final _url1Controller = TextEditingController();
  final _website2Controller = TextEditingController();
  final _url2Controller = TextEditingController();

  // Section management
  final _sectionNameController = TextEditingController();
  String _selectedSectionType = 'education';
  List<CvSection> _sections =
      <CvSection>[]; // Explicitly initialize as mutable list

  bool _isLoading = false;
  List<UserData> _userDataList = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _noteController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _website1Controller.dispose();
    _url1Controller.dispose();
    _website2Controller.dispose();
    _url2Controller.dispose();
    _sectionNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userDataList = await CsvService.loadUserData();
      setState(() {
        _userDataList = userDataList;
        _sections = []; // Initialize sections list properly
        print('🧪 Loaded ${userDataList.length} user entries');

        // If data exists, populate form fields
        if (userDataList.isNotEmpty) {
          final userData = userDataList.first;
          _firstNameController.text = userData.firstName;
          _middleNameController.text = userData.middleName ?? '';
          _lastNameController.text = userData.lastName;
          _noteController.text = userData.summary ?? '';
          _emailController.text = userData.email ?? '';
          _phoneController.text = userData.phone ?? '';
          _addressController.text = userData.address ?? '';
          _zipCodeController.text = userData.zipCode ?? '';
          _cityController.text = userData.city ?? '';
          _countryController.text = userData.country ?? '';
          _website1Controller.text = userData.website1 ?? '';
          _url1Controller.text = userData.url1 ?? '';
          _website2Controller.text = userData.website2 ?? '';
          _url2Controller.text = userData.url2 ?? '';
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load user data: $e');
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
      final userData = UserData(
        firstName: _firstNameController.text.trim(),
        middleName: _middleNameController.text.trim().isEmpty
            ? null
            : _middleNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        summary: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        zipCode: _zipCodeController.text.trim().isEmpty
            ? null
            : _zipCodeController.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        country: _countryController.text.trim().isEmpty
            ? null
            : _countryController.text.trim(),
        website1: _website1Controller.text.trim().isEmpty
            ? null
            : _website1Controller.text.trim(),
        url1: _url1Controller.text.trim().isEmpty
            ? null
            : _url1Controller.text.trim(),
        website2: _website2Controller.text.trim().isEmpty
            ? null
            : _website2Controller.text.trim(),
        url2: _url2Controller.text.trim().isEmpty
            ? null
            : _url2Controller.text.trim(),
      );

      // Save to CSV
      await CsvService.saveUserData(userData);

      // Generate RTF
      final rtfFile = await RtfService.createRtfFile(userData);

      // Reload user data list
      await _loadUserData();

      if (mounted) {
        _showSuccessSnackBar('CV saved successfully! File: ${rtfFile.path}');
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

  void _addSection() {
    if (_sectionNameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a custom name for section');
      return;
    }

    try {
      print('🧪 Creating section of type: $_selectedSectionType');
      print('🧪 Section name: "${_sectionNameController.text.trim()}"');

      final newSection = SectionTypes.createSection(
        _selectedSectionType,
        _sectionNameController.text.trim(),
      );

      // Auto-create first subsection
      if (newSection is EducationSection) {
        final newItems = List<Map<String, String>>.from(newSection.items);
        newItems.add({'degree': ''});
        newSection.items = newItems;
      } else if (newSection is ExperienceSection) {
        final newItems = List<Map<String, String>>.from(newSection.items);
        newItems.add({'job': ''});
        newSection.items = newItems;
      }

      setState(() {
        final newSections = List<CvSection>.from(_sections);
        newSections.add(newSection);
        _sections = newSections;
        print(
            '🧪 Added section: ${newSection.displayName} (Type: ${newSection.type})');
        print('🧪 Total sections: ${_sections.length}');
      });

      // Clear form
      _sectionNameController.clear();
      _selectedSectionType = 'education';
    } catch (e) {
      print('❌ ERROR: Failed to add section: $e');
      _showErrorSnackBar('Failed to add section: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('mmmCV - Make Me My CV'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Section (Personal Information)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Fill out the form to create your CV',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 16,
                        runSpacing: 10,
                        children: [
                          SizedBox(
                            width: 200,
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your first name';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: TextFormField(
                              controller: _middleNameController,
                              decoration: const InputDecoration(
                                labelText: 'Middle Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your last name';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'Note',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 10,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.home),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 10,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _zipCodeController,
                              decoration: const InputDecoration(
                                labelText: 'Zip Code',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.mail),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_city),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _countryController,
                              decoration: const InputDecoration(
                                labelText: 'Country',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.flag),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 10,
                        children: [
                          SizedBox(
                            width: 200,
                            child: TextFormField(
                              controller: _website1Controller,
                              decoration: const InputDecoration(
                                labelText: 'Website 1',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.language),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: TextFormField(
                              controller: _url1Controller,
                              decoration: const InputDecoration(
                                labelText: 'URL 1',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.link),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: TextFormField(
                              controller: _website2Controller,
                              decoration: const InputDecoration(
                                labelText: 'Website 2',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.language),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            child: TextFormField(
                              controller: _url2Controller,
                              decoration: const InputDecoration(
                                labelText: 'URL 2',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.link),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Custom Sections List
                      if (_sections.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const SizedBox(height: 8),
                        ..._sections.asMap().entries.map((entry) {
                          int index = entry.key;
                          CvSection section = entry.value;
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        section.type == 'education'
                                            ? Icons.school
                                            : Icons.work,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          section.displayName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (section is EducationSection) ...[
                                    const SizedBox(height: 16),
                                    // Subsections
                                    if (section.items.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      ...section.items
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        int itemIndex = entry.key;
                                        Map<String, String> item = entry.value;
                                        return Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      '${section.subsectionName} ${itemIndex + 1}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red),
                                                      onPressed: () {
                                                        setState(() {
                                                          final newItems = List<
                                                                  Map<String,
                                                                      String>>.from(
                                                              section.items);
                                                          newItems.removeAt(
                                                              itemIndex);
                                                          section.items =
                                                              newItems;

                                                          // Auto-delete section if no subsections left
                                                          if (section
                                                              .items.isEmpty) {
                                                            final newSections =
                                                                List<CvSection>.from(
                                                                    _sections);
                                                            newSections
                                                                .removeAt(
                                                                    index);
                                                            _sections =
                                                                newSections;
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                TextFormField(
                                                  initialValue:
                                                      item['degree'] ?? '',
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Degree',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      final newItems = List<
                                                              Map<String,
                                                                  String>>.from(
                                                          section.items);
                                                      newItems[itemIndex]
                                                              ['degree'] =
                                                          value.trim();
                                                      section.items = newItems;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          final newItems =
                                              List<Map<String, String>>.from(
                                                  section.items);
                                          newItems.add({'degree': ''});
                                          section.items = newItems;
                                        });
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                  if (section is ExperienceSection) ...[
                                    const SizedBox(height: 16),
                                    // Subsections
                                    if (section.items.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      ...section.items
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        int itemIndex = entry.key;
                                        Map<String, String> item = entry.value;
                                        return Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      '${section.subsectionName} ${itemIndex + 1}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red),
                                                      onPressed: () {
                                                        setState(() {
                                                          final newItems = List<
                                                                  Map<String,
                                                                      String>>.from(
                                                              section.items);
                                                          newItems.removeAt(
                                                              itemIndex);
                                                          section.items =
                                                              newItems;

                                                          // Auto-delete section if no subsections left
                                                          if (section
                                                              .items.isEmpty) {
                                                            final newSections =
                                                                List<CvSection>.from(
                                                                    _sections);
                                                            newSections
                                                                .removeAt(
                                                                    index);
                                                            _sections =
                                                                newSections;
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                TextFormField(
                                                  initialValue:
                                                      item['job'] ?? '',
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Job',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      final newItems = List<
                                                              Map<String,
                                                                  String>>.from(
                                                          section.items);
                                                      newItems[itemIndex]
                                                              ['job'] =
                                                          value.trim();
                                                      section.items = newItems;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          final newItems =
                                              List<Map<String, String>>.from(
                                                  section.items);
                                          newItems.add({'job': ''});
                                          section.items = newItems;
                                        });
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
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
                                    fontSize: 18, fontWeight: FontWeight.bold),
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
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 3,
                                    child: TextFormField(
                                      controller: _sectionNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Name',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.label),
                                        hintText: 'Enter a section name...',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton.icon(
                                    onPressed: _addSection,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Section'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
