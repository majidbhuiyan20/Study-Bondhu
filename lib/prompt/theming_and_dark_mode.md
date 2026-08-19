# Theming & Dark Mode

Theme control lives in exactly **three** files. Anywhere else, use the
helpers — never hardcode colors.

| File                                         | Role                                              |
| -------------------------------------------- | ------------------------------------------------- |
| `lib/core/theme/app_colors.dart`             | Raw color constants (light + dark palettes).      |
| `lib/core/theme/app_theme.dart`              | Light + dark `ThemeData` builders.                |
| `lib/core/theme/theme_colors.dart`           | `ThemeColors.x(context)` helpers.                 |
| `lib/core/theme/app_text_styles.dart`        | `AppTextStyles.x` — fonts + weights, **NO color**. |

## Why `AppTextStyles` must not have a color

If a `TextStyle` declares `color: AppColors.textPrimary` (which is dark), it
is a `const TextStyle` baked at compile time. The dark theme's
`textTheme.apply(bodyColor: ...)` only overrides colors **when the style is
fetched through `Theme.of(context).textTheme`**. Direct references to
`AppTextStyles.titleMedium` bypass the override and stay dark, becoming
invisible on dark backgrounds.

**Rule:** `AppTextStyles` only declares font family, size, weight, height,
letter spacing. The color is inherited from the surrounding `DefaultTextStyle`
or theme. This is what makes both modes "just work".

## Use these helpers, not raw colors

```dart
Text("Hi", style: TextStyle(color: ThemeColors.textPrimary(context)));
Text("Hint", style: AppTextStyles.bodySmall.copyWith(
  color: ThemeColors.textSecondary(context),
));
Icon(Icons.add, color: ThemeColors.textTertiary(context));
```

The helpers internally do:

```dart
Theme.of(context).brightness == Brightness.dark
    ? AppColors.darkX
    : AppColors.x;
```

## Adding a new color

1. Add the constant to `AppColors` (light) and `AppColors.darkX` (dark).
2. Add a helper to `ThemeColors` (textPrimary/Secondary/Tertiary,
   surface/surfaceAlt/border/divider).
3. Use the helper everywhere the color is needed.

## Container / surface colors

Surfaces (cards, sheets, dialogs) are wired through the theme's
`cardTheme`, `bottomSheetTheme`, `dialogTheme`. Widgets that draw their own
container must pick the correct `AppColors.surface` /
`AppColors.darkSurface` based on `Theme.of(context).brightness`.

`AppCard` already does this — prefer `AppCard` over raw `Container`s.

## Icons without explicit color

`IconThemeData(color: textSecondary)` is set on both themes so any `Icon`
without an explicit `color` arg gets a sensible foreground that contrasts
with the current background.

## Audit checklist

Before merging any UI change, grep:

```bash
grep -rE "color:\s*AppColors\.(textPrimary|textSecondary|textTertiary)\b" lib
```

It should only return matches **inside** `app_theme.dart` and
`theme_colors.dart`. Anywhere else is a regression.