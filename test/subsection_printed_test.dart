// test/subsection_printed_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mmmcv/models/custom_section.dart';

class _FakeSubsection extends Subsection {
  _FakeSubsection() : super(name: 'Fake', fieldGroups: const []);
}

void main() {
  test('Subsection.printed defaults to true', () {
    final subsection = _FakeSubsection();
    expect(subsection.printed, true);
  });

  test('Subsection.printed can be set to false', () {
    final subsection = _FakeSubsection()..printed = false;
    expect(subsection.printed, false);
  });
}
