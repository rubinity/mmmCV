import 'package:flutter/material.dart';
import 'custom_section.dart';
import 'language_subsection.dart';
import 'section_types.dart';
import '../services/cv_data_service.dart' show SubsectionData;

class LanguageCustomSection extends CustomSection {
  LanguageCustomSection({
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
          subsectionType: SectionType.languages,
          sectionKey: sectionKey,
          sectionId: sectionId,
          preloadedSubsections: preloadedSubsections,
          onRemoveSection: onRemoveSection,
          onMoveSectionUp: onMoveSectionUp,
          onMoveSectionDown: onMoveSectionDown,
          isFirstSection: isFirstSection,
          isLastSection: isLastSection,
          allowMultipleSubsections: true, // Allow multiple subsections
        );

  @override
  State<CustomSection> createState() => LanguageCustomSectionState();
}

class LanguageCustomSectionState extends CustomSectionState {
  @override
  Subsection createSubsectionFromData(SubsectionData data, int index) {
    return LanguageSubsection(
      name: data.name,
      restoredValues: data.controllerValues,
    );
  }

  @override
  Subsection createDefaultSubsection() {
    return LanguageSubsection(
      name: '${widget.sectionName} Entry ${subsections.length + 1}',
      restoredValues: widget.preloadedSubsections?.isNotEmpty == true
          ? widget.preloadedSubsections!.first.controllerValues
          : null,
    );
  }

  @override
  void addSubsection() {
    setState(() {
      final newKey = subsections.length;
      subsections[newKey] = LanguageSubsection(
        name: '${widget.sectionName} Entry ${newKey + 1}',
      );
      registerControllers();
    });
  }
}
