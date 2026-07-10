import 'package:flutter/material.dart';
import 'custom_section.dart';
import 'education_subsection.dart';
import 'section_types.dart';
import '../services/cv_data_service.dart' show SubsectionData;

class EducationCustomSection extends CustomSection {
  EducationCustomSection({
    super.key,
    required String sectionName,
    GlobalKey<CustomSectionState>? sectionKey,
    String? sectionId,
    List<SubsectionData>? preloadedSubsections,
    VoidCallback? onRemoveSection,
    VoidCallback? onMoveSectionUp,
    VoidCallback? onMoveSectionDown,
    bool Function()? isFirstSection,
    bool Function()? isLastSection,
  }) : super(
          sectionName: sectionName,
          subsectionType: SectionType.education,
          sectionKey: sectionKey,
          sectionId: sectionId,
          preloadedSubsections: preloadedSubsections,
          onRemoveSection: onRemoveSection,
          onMoveSectionUp: onMoveSectionUp,
          onMoveSectionDown: onMoveSectionDown,
          isFirstSection: isFirstSection,
          isLastSection: isLastSection,
        );

  @override
  State<CustomSection> createState() => EducationCustomSectionState();
}

class EducationCustomSectionState extends CustomSectionState {
  @override
  Subsection createSubsectionFromData(SubsectionData data, int index) {
    return EducationSubsection(
      name: data.name,
      restoredValues: data.controllerValues,
    );
  }

  @override
  Subsection createDefaultSubsection() {
    return EducationSubsection(
      name: '${widget.sectionName} Entry 1',
      restoredValues: widget.preloadedSubsections?.isNotEmpty == true
          ? widget.preloadedSubsections!.first.controllerValues
          : null,
    );
  }

  @override
  void addSubsection() {
    setState(() {
      final newKey = subsections.length;
      subsections[newKey] = EducationSubsection(
        name: '${widget.sectionName} Entry ${newKey + 1}',
      );
      registerControllers();
    });
  }
}
