import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Kelivo/desktop/desktop_settings_page.dart';
import 'package:Kelivo/shared/widgets/markdown_with_highlight.dart';

String _inlineInner(RegExpMatch match) =>
    (match.group(1) ?? match.group(2) ?? '').trim();

void main() {
  test('Desktop provider grouping compiles', () {
    expect(DesktopSettingsPage, isNotNull);
  });

  group('Markdown emphasis regex quick checks', () {
    final bold = MarkdownBoldSyntaxMd(color: const Color(0xFF000000));
    final boldItalic = MarkdownBoldItalicSyntaxMd(
      color: const Color(0xFF000000),
    );
    final italic = MarkdownItalicSyntaxMd(color: const Color(0xFF000000));
    final quoted = MarkdownQuotedSyntaxMd(color: const Color(0xFF000000));

    test('regression: **我是粗体** keeps match boundary with Chinese punctuation', () {
      const input = '内容：**我是粗体**：就是很粗';
      final m = bold.exp.firstMatch(input);
      expect(m, isNotNull);
      expect(m!.group(0), '**我是粗体**');
      expect(_inlineInner(m), '我是粗体');
      final replaced = input.replaceRange(m.start, m.end, '<BOLD>');
      expect(replaced, '内容：<BOLD>：就是很粗');
    });

    test('***bold italic*** should be parsed by boldItalic, not bold', () {
      const input = '***我是斜粗体***';
      final m = boldItalic.exp.firstMatch(input);
      expect(m, isNotNull);
      expect(_inlineInner(m!), '我是斜粗体');
      expect(bold.exp.hasMatch(input), isFalse);
    });

    test('italic should not steal **bold** markers', () {
      expect(italic.exp.hasMatch('**abc**'), isFalse);
      expect(italic.exp.hasMatch('*abc*'), isTrue);
    });

    test('quoted supports straight and chinese quotes', () {
      final m1 = quoted.exp.firstMatch('他说: "你好"');
      final m2 = quoted.exp.firstMatch('他说： “你好”');
      expect(m1, isNotNull);
      expect(m2, isNotNull);
      expect(_inlineInner(m1!), '你好');
      expect(_inlineInner(m2!), '你好');
    });
  });
}

