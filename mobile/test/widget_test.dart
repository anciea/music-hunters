import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:musicdl/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MusicDlApp()),
    );
    // App renders with ProviderScope and MusicDlApp; no crash means pass.
    expect(find.byType(MusicDlApp), findsOneWidget);
  });
}
