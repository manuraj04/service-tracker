// Simple widget test to ensure the app builds and shows the home app bar title.
import 'package:flutter_test/flutter_test.dart';

import 'package:service_engineer_tracker/main.dart';

void main() {
  testWidgets('App builds and shows title', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const ServiceEngineerTrackerApp());

    // Allow widgets to settle
    await tester.pumpAndSettle();

    // Verify that the home screen shows the app bar title
    expect(find.text('Service Engineer Tracker'), findsOneWidget);
  });
}
