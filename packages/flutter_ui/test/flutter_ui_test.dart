import 'package:flutter_ui/flutter_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exports are reachable', () {
    expect(MealCard, isNotNull);
    expect(StickyCheckoutBar, isNotNull);
  });
}
