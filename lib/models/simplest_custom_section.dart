import 'package:flutter/material.dart';
import 'custom_section.dart';
import 'simplest_subsection.dart';
import 'section_types.dart';
import '../services/cv_data_service.dart' show SubsectionData;

class SimplestCustomSection extends CustomSection {
  SimplestCustomSection({
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
          subsectionType: SectionType.simplest,
          sectionKey: sectionKey,
          sectionId: sectionId,
          preloadedSubsections: preloadedSubsections,
          onRemoveSection: onRemoveSection,
          onMoveSectionUp: onMoveSectionUp,
          onMoveSectionDown: onMoveSectionDown,
          isFirstSection: isFirstSection,
          isLastSection: isLastSection,
          allowMultipleSubsections: false, // Only allow one subsection
        );

  @override
  State<CustomSection> createState() => SimplestCustomSectionState();
}

class SimplestCustomSectionState extends CustomSectionState {
  @override
  Subsection createSubsectionFromData(SubsectionData data, int index) {
    return SimplestSubsection(
      name: data.name,
      restoredValues: data.controllerValues,
    );
  }

  @override
  Subsection createDefaultSubsection() {
    return SimplestSubsection(
      name: '${widget.sectionName} Entry 1',
      restoredValues: widget.preloadedSubsections?.isNotEmpty == true
          ? widget.preloadedSubsections!.first.controllerValues
          : null,
    );
  }

  @override
  void addSubsection() {
    // Not allowed since allowMultipleSubsections is false
  }
}
