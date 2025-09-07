// Main test file for the Meal Generator app
// Runs all unit tests and integration tests

import 'package:flutter_test/flutter_test.dart';

import 'models/material_test.dart' as material_tests;
import 'models/meal_test.dart' as meal_tests;
import 'services/seed_data_service_test.dart' as seed_data_tests;

void main() {
  group('Meal Generator App Tests', () {
    group('Model Tests', () {
      material_tests.main();
      meal_tests.main();
    });

    group('Service Tests', () {
      seed_data_tests.main();
    });
  });
}
