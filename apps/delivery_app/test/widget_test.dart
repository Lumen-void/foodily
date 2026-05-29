import 'package:delivery_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders partner title', (tester) async {
    await tester.pumpWidget(const DeliveryBootstrap());
    expect(find.text('Foodily Restaurant'), findsOneWidget);
  });
}
