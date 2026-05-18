import 'package:flutter_test/flutter_test.dart';

import 'package:pulsecall/main.dart';

void main() {
  testWidgets('PulseCall home renders scheduler controls', (tester) async {
    await tester.pumpWidget(const CallPromptApp());

    expect(find.text('PulseCall'), findsOneWidget);
    expect(find.text('Caller Setup'), findsOneWidget);
    expect(find.text('Schedule Smart Call'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
  });
}
