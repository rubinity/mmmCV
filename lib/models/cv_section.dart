abstract class CvSection {
  String sectionName;
  String type;
  List<Map<String, String>> items;
  String subsectionName;

  CvSection({
    required this.sectionName,
    required this.type,
    this.items = const [],
    required this.subsectionName,
  });

  Map<String, dynamic> toMap();

  String get displayName => sectionName.isEmpty ? type : sectionName;
}

class EducationSection extends CvSection {
  EducationSection({
    required String sectionName,
    List<Map<String, String>> items = const [],
  }) : super(
            sectionName: sectionName,
            type: 'education',
            items: items,
            subsectionName: 'Education');

  @override
  Map<String, dynamic> toMap() {
    return {
      'sectionName': sectionName,
      'type': type,
      'items': items,
      'subsectionName': subsectionName,
    };
  }

  factory EducationSection.fromMap(Map<String, dynamic> map) {
    return EducationSection(
      sectionName: map['sectionName'] ?? '',
      items: List<Map<String, String>>.from(map['items'] ?? []),
    );
  }
}

class ExperienceSection extends CvSection {
  ExperienceSection({
    required String sectionName,
    List<Map<String, String>> items = const [],
  }) : super(
            sectionName: sectionName,
            type: 'experience',
            items: items,
            subsectionName: 'Experience');

  @override
  Map<String, dynamic> toMap() {
    return {
      'sectionName': sectionName,
      'type': type,
      'items': items,
      'subsectionName': subsectionName,
    };
  }

  factory ExperienceSection.fromMap(Map<String, dynamic> map) {
    return ExperienceSection(
      sectionName: map['sectionName'] ?? '',
      items: List<Map<String, String>>.from(map['items'] ?? []),
    );
  }
}

class SectionTypes {
  static const List<String> types = ['education', 'experience'];

  static CvSection createSection(String type, String sectionName) {
    switch (type) {
      case 'education':
        return EducationSection(sectionName: sectionName);
      case 'experience':
        return ExperienceSection(sectionName: sectionName);
      default:
        throw ArgumentError('Unknown section type: $type');
    }
  }

  static CvSection fromMap(Map<String, dynamic> map) {
    String type = map['type'] ?? '';
    switch (type) {
      case 'education':
        return EducationSection.fromMap(map);
      case 'experience':
        return ExperienceSection.fromMap(map);
      default:
        throw ArgumentError('Unknown section type: $type');
    }
  }
}
