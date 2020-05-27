import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
	testWidgets('Check Main', (WidgetTester tester) async {
		await tester.pumpWidget(MyApp());
		await tester.pump();

		// タイトルログ
		expect(find.byIcon(Icons.show_chart), findsOneWidget);
		// タブバー
		expect(find.byIcon(Icons.home), findsOneWidget);
		expect(find.byIcon(Icons.history), findsOneWidget);
		expect(find.byIcon(Icons.settings), findsOneWidget);
	});
}
