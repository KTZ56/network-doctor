import 'package:flutter_test/flutter_test.dart';

import 'package:network_doctor/main.dart';

void main() {
  testWidgets('Network Doctor app starts successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NetworkDoctorApp());

    await tester.pumpAndSettle();

    expect(find.byType(NetworkDoctorApp), findsOneWidget);
  });
}