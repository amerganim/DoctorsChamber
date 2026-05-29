import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:doctors_chamber/app.dart';

void main() {
  testWidgets('Role select screen renders', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DoctorInsideApp()));
    expect(find.text('Doctor Inside'), findsOneWidget);
    expect(find.text('Patient'), findsOneWidget);
    expect(find.text('Doctor'), findsOneWidget);
    expect(find.text('Chamber Admin'), findsOneWidget);
  });
}
