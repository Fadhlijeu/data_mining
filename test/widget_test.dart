import 'package:flutter_test/flutter_test.dart';
import 'package:data_mining/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ClusterLabApp());
    expect(find.byType(ClusterLabApp), findsOneWidget);
  });
}
