import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:see_near_app/main.dart';

void main() {
  testWidgets('SeeNear app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SeeNearApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}