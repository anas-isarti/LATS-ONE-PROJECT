import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:the_last_one/main.dart';
import 'package:the_last_one/controllers/game_controller.dart';
import 'package:the_last_one/controllers/quest_controller.dart';
import 'package:the_last_one/controllers/nfc_controller.dart';

void main() {
  testWidgets('TheLastOneApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GameController()),
          ChangeNotifierProvider(create: (_) => QuestController()),
          ChangeNotifierProvider(create: (_) => NfcController()),
        ],
        child: const TheLastOneApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
