// This is a basic Flutter widget test.
//
// To perform an interaction with a widget test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:kelola_katering/main.dart';

void main() {
  testWidgets('App menampilkan Dashboard sebagai halaman awal', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KelolaKateringApp());

    // Verify that Dashboard AppBar title is shown.
    expect(find.text('Dashboard'), findsNWidgets(2));

    // Verify that NavigationBar labels are present.
    expect(find.text('Pesanan'), findsWidgets);
  });
}
