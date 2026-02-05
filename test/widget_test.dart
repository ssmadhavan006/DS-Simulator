// This is a basic Flutter widget test for DSA Visualizer

import 'package:flutter_test/flutter_test.dart';

import 'package:dsa_sim/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DSAVisualizerApp());

    // Verify that the home screen title is shown.
    expect(find.text('DSA Visualizer'), findsOneWidget);

    // Verify that the 4 data structure cards are present
    expect(find.text('Stack'), findsOneWidget);
    expect(find.text('Queue'), findsOneWidget);
    expect(find.text('Tree'), findsOneWidget);
    expect(find.text('Graph'), findsOneWidget);
  });
}
