// test/custom_section_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mmmcv/models/custom_section.dart';
import 'package:mmmcv/models/simplest_subsection.dart';

void main() {
  group('collectControllers printed filter', () {
    test('printedOnly excludes unprinted subsections', () {
      final printedSub = SimplestSubsection(name: 'A');
      final unprintedSub = SimplestSubsection(name: 'B')..printed = false;
      final subsections = {0: printedSub, 1: unprintedSub};

      expect(collectControllers(subsections).length, 2);
      expect(collectControllers(subsections, printedOnly: true).length, 1);
    });
  });

  group('printedFlags', () {
    test("reflects each subsection's printed flag in order", () {
      final printedSub = SimplestSubsection(name: 'A');
      final unprintedSub = SimplestSubsection(name: 'B')..printed = false;
      final subsections = {0: printedSub, 1: unprintedSub};

      expect(
        subsections.values.map((s) => s.printed).toList(),
        [true, false],
      );
    });
  });
}
