import 'package:flutter/material.dart';

void main() {
  // Test TextEditingController constructors
  print('=== Testing TextEditingController constructors ===');

  // Standard constructor
  final controller1 = TextEditingController();
  print('Standard constructor: "${controller1.text}"');

  // Test if fromValue exists
  try {
    final controller2 =
        TextEditingController.fromValue(TextEditingValue(text: 'Test Value'));
    print('fromValue constructor: "${controller2.text}"');
  } catch (e) {
    print('fromValue constructor ERROR: $e');
  }

  // Test available constructors
  print('Available constructors:');
  print('TextEditingController() exists');
  print(
      'TextEditingController.fromValue() exists: ${TextEditingController.fromValue != null}');
}
