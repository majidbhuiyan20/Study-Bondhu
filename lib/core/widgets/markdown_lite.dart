import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Spec #18 — markdown-lite renderer with a tiny grammar:
///   `# Heading` (one leading `#`)
///   `- list item` (round bullet, indented)
///   `- [ ]` checklist (open), `- [x]` checklist (done)
///   `**bold**`, `*italic*`
///
/// This is intentionally not a full markdown parser – it covers exactly the
/// four affordances the spec lists, and we deliberately keep the surface
/// small so the editor stays a single text field.
class MarkdownLite extends StatelessWidget {
  const MarkdownLite({super.key, required this.source});
  final String source;

  @override
  Widget build(BuildContext context) {
    final blocks = _parse(source);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final b in blocks)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: _renderBlock(b),
          ),
      ],
    );
  }

  Widget _renderBlock(_Block b) {
    switch (b.kind) {
      case _BlockKind.heading:
        return Text(
          b.text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        );
      case _BlockKind.bullet:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8, right: 8),
              child: Icon(Icons.circle, size: 5),
            ),
            Expanded(
              child: _Rich(b.text),
            ),
          ],
        );
      case _BlockKind.checklistOpen:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2, right: 8),
              child: Icon(Icons.check_box_outline_blank, size: 16),
            ),
            Expanded(child: _Rich(b.text)),
          ],
        );
      case _BlockKind.checklistDone:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2, right: 8),
              child: Icon(Icons.check_box, size: 16, color: AppColors.primary),
            ),
            Expanded(
              child: _Rich(
                b.text,
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        );
      case _BlockKind.paragraph:
        return _Rich(b.text);
    }
  }

  List<_Block> _parse(String src) {
    final lines = src.split('\n');
    final out = <_Block>[];
    for (final line in lines) {
      final trimmed = line.trimRight();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('# ')) {
        out.add(_Block(_BlockKind.heading, trimmed.substring(2)));
      } else if (trimmed.startsWith('- [ ] ')) {
        out.add(_Block(_BlockKind.checklistOpen, trimmed.substring(6)));
      } else if (trimmed.startsWith('- [x] ') ||
          trimmed.startsWith('- [X] ')) {
        out.add(_Block(_BlockKind.checklistDone, trimmed.substring(6)));
      } else if (trimmed.startsWith('- ')) {
        out.add(_Block(_BlockKind.bullet, trimmed.substring(2)));
      } else {
        out.add(_Block(_BlockKind.paragraph, trimmed));
      }
    }
    return out;
  }
}

/// Single-line text with inline `**bold**` / `*italic*` markers rendered
/// as different spans. Used by [MarkdownLite] for paragraph, bullet and
/// checklist lines.
class _Rich extends StatelessWidget {
  const _Rich(this.text, {this.style});
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: inlineRichText(text, style),
    );
  }
}

/// Build a single TextSpan with inline parsing of `**bold**` and `*italic*`.
/// Returns one span per line so callers can compose them.
TextSpan inlineRichText(String src, TextStyle? base) {
  final spans = <TextSpan>[];
  final re = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*)');
  int last = 0;
  for (final m in re.allMatches(src)) {
    if (m.start > last) {
      spans.add(TextSpan(text: src.substring(last, m.start), style: base));
    }
    final token = m.group(0)!;
    if (token.startsWith('**')) {
      spans.add(TextSpan(
        text: token.substring(2, token.length - 2),
        style: (base ?? const TextStyle()).copyWith(fontWeight: FontWeight.w700),
      ));
    } else {
      spans.add(TextSpan(
        text: token.substring(1, token.length - 1),
        style: (base ?? const TextStyle()).copyWith(fontStyle: FontStyle.italic),
      ));
    }
    last = m.end;
  }
  if (last < src.length) {
    spans.add(TextSpan(text: src.substring(last), style: base));
  }
  return TextSpan(children: spans);
}

enum _BlockKind { heading, bullet, checklistOpen, checklistDone, paragraph }

class _Block {
  final _BlockKind kind;
  final String text;
  const _Block(this.kind, this.text);
}
