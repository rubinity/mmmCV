import 'package:flutter_test/flutter_test.dart';
import 'package:mmmcv/models/project_subsection.dart';

void main() {
  group('ProjectSubsection field order', () {
    test('has 6 fields in Affiliation, Start, End, Name, URL, Description order', () {
      final subsection = ProjectSubsection(
        name: 'Test',
        restoredValues: [
          'LEVEL3',
          '01.2024',
          '02.2024',
          'Build a Cloud',
          'https://example.com',
          'A description',
        ],
      );

      final controllers = subsection.allControllers;
      expect(controllers.length, 6);
      expect(controllers[0].text, 'LEVEL3');
      expect(controllers[1].text, '01.2024');
      expect(controllers[2].text, '02.2024');
      expect(controllers[3].text, 'Build a Cloud');
      expect(controllers[4].text, 'https://example.com');
      expect(controllers[5].text, 'A description');
    });

    test('defaults to 6 empty controllers when no restoredValues given', () {
      final subsection = ProjectSubsection(name: 'Test');
      final controllers = subsection.allControllers;
      expect(controllers.length, 6);
      for (final controller in controllers) {
        expect(controller.text, '');
      }
    });
  });
}
