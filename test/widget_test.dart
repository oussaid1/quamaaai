import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quamaaai/providers/app_state.dart';
import 'package:quamaaai/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: We provide AppState because QuamaaAiApp uses it.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const QuamaaAiApp(),
      ),
    );

    // Verify that login screen or main shell is shown (depending on auth state).
    // For now, just check if the app starts.
    expect(find.byType(QuamaaAiApp), findsOneWidget);
  });
}
