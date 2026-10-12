import 'package:flutter_test/flutter_test.dart';
import 'package:unisecure_app/app/app.dart';

void main() {
  testWidgets('UniSecure initializes with the light login experience', (
    tester,
  ) async {
    await tester.pumpWidget(const UniSecureApp());
    expect(find.text('Sign in to UniSecure'), findsOneWidget);
    expect(
      find.text('Secure access for your university role.'),
      findsOneWidget,
    );
  });
}
