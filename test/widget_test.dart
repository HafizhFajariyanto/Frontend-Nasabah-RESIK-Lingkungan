import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nasabah_resik/main.dart';

void main() {
  testWidgets('Layar login tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const ResikApp());
    await tester.pump();

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('Tab setor menampilkan layout sesuai mockup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Setor'));
    await tester.pumpAndSettle();

    expect(find.text('Setor Plastik'), findsWidgets);
    expect(find.text('Pilih Kategori Sampah'), findsOneWidget);
    expect(find.text('Konfirmasi Setoran'), findsOneWidget);
  });
}
