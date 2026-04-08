import 'package:flutter/material.dart';

void main() {
  print('=== TextEditingController Constructor Check ===');
  
  // Check all available constructors
  var constructors = TextEditingController().runtimeType.toString();
  print('Type: $constructors');
  
  // Check if fromValue method exists
  print('fromValue method exists: ${TextEditingController.fromValue != null}');
  
  // Try different constructor patterns
  try {
    final c1 = TextEditingController(text: 'Initial Text');
    print('TextEditingController(text): "${c1.text}"');
  } catch (e) {
    print('TextEditingController(text) error: $e');
  }
  
  // Try to find fromValue by checking common patterns
  try {
    final c2 = TextEditingController.fromValue(const TextEditingValue(text: 'From Value'));
    print('fromValue with const: "${c2.text}"');
  } catch (e) {
    print('fromValue with const error: $e');
  }
}
