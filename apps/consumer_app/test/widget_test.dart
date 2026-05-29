import 'package:consumer_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders Foodily login title', (tester) async {
    await tester.pumpWidget(const ConsumerBootstrap());

    expect(find.text('Foodily'), findsOneWidget);
  });
}
