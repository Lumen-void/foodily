import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mock data has cities and meals', () {
    expect(MockData.cities.isNotEmpty, true);
    expect(MockData.meals.isNotEmpty, true);
  });
}
