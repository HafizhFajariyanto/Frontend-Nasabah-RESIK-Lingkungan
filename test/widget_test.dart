import 'package:flutter_test/flutter_test.dart';

import 'package:nasabah_resik/main.dart';

void main() {
  testWidgets('Layar login tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const ResikApp());
    await tester.pump();

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}