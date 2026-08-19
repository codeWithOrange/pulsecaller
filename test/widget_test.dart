import 'package:flutter_test/flutter_test.dart';
import 'package:pulsecall/main.dart';

void main() {
  testWidgets('PulseCall full navigation & custom caller test suite', (tester) async {
    await tester.pumpWidget(const CallPromptApp());
    await tester.pumpAndSettle();

    // 1. Verify Home Keypad tab
    expect(find.text('Phone'), findsOneWidget);
    expect(find.text('Keypad'), findsOneWidget);
    expect(find.text('Contacts'), findsOneWidget);
    expect(find.text('Triggers'), findsOneWidget);
    expect(find.text('Recents'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('+ Custom'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);

    // 2. Test Dialpad digits
    await tester.tap(find.text('5').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('8').first);
    await tester.pumpAndSettle();

    // 3. Test + Custom caller bottom sheet
    await tester.tap(find.text('+ Custom'));
    await tester.pumpAndSettle();

    expect(find.text('Custom Caller'), findsOneWidget);
    expect(find.text('COUNTDOWN DELAY TIMER'), findsOneWidget);
    expect(find.text('REPEAT RINGS'), findsOneWidget);
    expect(find.text('NETWORK LINE'), findsOneWidget);
    expect(find.text('Set Active'), findsOneWidget);

    // Change to 5s delay
    await tester.tap(find.text('5s').first);
    await tester.pumpAndSettle();
    expect(find.text('Schedule in 5s'), findsOneWidget);

    // Close sheet via Set Active
    await tester.tap(find.text('Set Active'));
    await tester.pumpAndSettle();

    // 4. Test Navigation to Contacts tab
    await tester.tap(find.text('Contacts'));
    await tester.pumpAndSettle();
    expect(find.text('Add Contact'), findsOneWidget);
    expect(find.text('ALL CONTACTS'), findsOneWidget);

    // 5. Test Navigation to Triggers tab
    await tester.tap(find.text('Triggers'));
    await tester.pumpAndSettle();
    expect(find.text('Work Meeting'), findsOneWidget);

    // 6. Test Navigation to Recents tab
    await tester.tap(find.text('Recents'));
    await tester.pumpAndSettle();
    expect(find.text('No Recent Calls'), findsOneWidget);

    // 7. Test Navigation to Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('CALL APPEARANCE'), findsOneWidget);
    expect(find.text('HARDWARE & SENSORS'), findsOneWidget);
    expect(find.text('DATA & STORAGE'), findsOneWidget);
  });
}
