// This is a basic Flutter widget test.
//
// To perform an interaction with a widget test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kelola_katering/main.dart';

void main() {
  testWidgets('App menampilkan Dashboard sebagai halaman awal', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KelolaKateringApp());

    // Layar uji bawaan 800 x 600 termasuk layar lebar: "Dashboard" tampil
    // sebagai judul halaman dan sebagai menu sidebar.
    expect(find.text('Dashboard'), findsNWidgets(2));

    // Menu kedua memakai nama halaman final "Daftar Pesanan".
    expect(find.byKey(const Key('nav-daftar-pesanan')), findsOneWidget);
  });
}
