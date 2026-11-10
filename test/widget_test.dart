import 'package:flutter_test/flutter_test.dart';
import 'package:droidlab/main.dart';

void main() {
  testWidgets('DroidLab home screen renders core navigation and actions', (tester) async {
    await tester.pumpWidget(const DroidLabApp());

    expect(find.text('DroidLab'), findsOneWidget);
    expect(find.text('Import APK'), findsOneWidget);
    expect(find.text('Import Project'), findsOneWidget);
    expect(find.text('Engine status'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
