import 'package:flutter/material.dart';

import '../icons/lucide_adapter.dart';
import '../l10n/app_localizations.dart';

Future<String?> showMessageAppendDesktopDialog(
  BuildContext context, {
  required String initialValue,
}) async {
  return showDialog<String?>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => _MessageAppendDesktopDialog(initialValue: initialValue),
  );
}

class _MessageAppendDesktopDialog extends StatefulWidget {
  const _MessageAppendDesktopDialog({required this.initialValue});

  final String initialValue;

  @override
  State<_MessageAppendDesktopDialog> createState() =>
      _MessageAppendDesktopDialogState();
}

class _MessageAppendDesktopDialogState
    extends State<_MessageAppendDesktopDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 520,
          maxWidth: 720,
          maxHeight: 680,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: cs.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                  child: Row(
                    children: [
                      Text(
                        l10n.contentAppendPageTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop<String>(_controller.text);
                        },
                        icon: Icon(Lucide.Check, size: 18, color: cs.primary),
                        label: Text(
                          l10n.messageEditPageSave,
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.mcpPageClose,
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: Icon(
                          Lucide.X,
                          size: 18,
                          color: cs.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      keyboardType: TextInputType.multiline,
                      minLines: 10,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: l10n.contentAppendPageHint,
                        filled: true,
                        fillColor: isDark
                            ? Colors.white10
                            : const Color(0xFFF7F7F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.18),
                            width: 0.6,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: cs.outlineVariant.withValues(alpha: 0.18),
                            width: 0.6,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: cs.primary.withValues(alpha: 0.35),
                            width: 0.8,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
