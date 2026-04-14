import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Kelivo/core/providers/settings_provider.dart';
import 'package:Kelivo/l10n/app_localizations.dart';
import 'package:Kelivo/shared/widgets/markdown_with_highlight.dart';

Future<void> _waitForSettingsLoad() async {
  for (var i = 0; i < 25; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

Widget _buildMarkdownHost({
  required SettingsProvider settings,
  required String markdown,
}) {
  return ChangeNotifierProvider<SettingsProvider>.value(
    value: settings,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: MarkdownWithCodeHighlight(text: markdown)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Markdown code block rendering', () {
    test('normalizes list-inline fenced openings before parsing', () {
      const raw = '- ```dart\nfinal a = 1;\nfinal b = 2;\n```';

      final normalized = MarkdownWithCodeHighlight.debugPreprocessMarkdown(raw);

      expect(
        normalized,
        '- \n```dart\nfinal a = 1;\nfinal b = 2;\n```',
      );
    });

    testWidgets('renders multiline fenced code with blank lines as one code block', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final settings = SettingsProvider();
      await _waitForSettingsLoad();

      const markdown = '```dart\nfinal a = 1;\n\nfinal b = 2;\n```';

      await tester.pumpWidget(
        _buildMarkdownHost(settings: settings, markdown: markdown),
      );
      await tester.pumpAndSettle();

      final view = tester.widget<SelectableHighlightView>(
        find.byType(SelectableHighlightView),
      );
      expect(view.source, 'final a = 1;\n\nfinal b = 2;');
    });

    testWidgets('renders indented fenced code as one code block after normalization', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final settings = SettingsProvider();
      await _waitForSettingsLoad();

      const markdown = '    ```dart\nfinal a = 1;\nfinal b = 2;\n    ```';

      await tester.pumpWidget(
        _buildMarkdownHost(settings: settings, markdown: markdown),
      );
      await tester.pumpAndSettle();

      final view = tester.widget<SelectableHighlightView>(
        find.byType(SelectableHighlightView),
      );
      expect(view.source, 'final a = 1;\nfinal b = 2;');
    });
  });
}
