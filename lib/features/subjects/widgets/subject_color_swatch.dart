import 'package:flutter/material.dart';

import '../../../core/theme/theme_colors.dart';

/// 8-swatch color picker used by both [SubjectAddView] and [EditSubjectSheet]
/// (spec 02 §"Add subject form").
///
/// Use:
/// ```dart
/// String color = '#4F46E5';
/// SubjectColorSwatch(
///   selected: color,
///   onChanged: (hex) => setState(() => color = hex),
/// )
/// ```
class SubjectColorSwatch extends StatelessWidget {
  const SubjectColorSwatch({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  /// Hex color of the currently selected swatch, e.g. `'#4F46E5'`.
  final String selected;

  /// Called when the user taps a swatch. The hex string is always uppercase
  /// with a leading `#`.
  final ValueChanged<String> onChanged;

  static const List<String> palette = [
    '#4F46E5', // Indigo
    '#0EA5E9', // Sky
    '#16A34A', // Green
    '#F59E0B', // Amber
    '#DC2626', // Red
    '#A855F7', // Purple
    '#EC4899', // Pink
    '#14B8A6', // Teal
  ];

  static const double _swatchSize = 36;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: palette.map((hex) => _swatch(context, hex)).toList(),
    );
  }

  Widget _swatch(BuildContext context, String hex) {
    final isSelected = selected == hex;
    final color = _colorFromHex(hex);
    return GestureDetector(
      onTap: () => onChanged(hex),
      child: Container(
        width: _swatchSize,
        height: _swatchSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            width: isSelected ? 3 : 1,
            color: isSelected
                ? ThemeColors.textPrimary(context)
                : ThemeColors.border(context),
          ),
        ),
      ),
    );
  }

  static Color _colorFromHex(String hex) {
    final clean = hex.replaceAll('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  /// Public helper for callers that need the parsed [Color].
  static Color colorOf(String hex) => _colorFromHex(hex);
}