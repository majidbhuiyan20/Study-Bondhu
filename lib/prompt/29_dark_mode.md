# 29 — Dark Mode

Full dark mode for every screen. See `theming_and_dark_mode.md` for the
engineering rules.

## Surfaces

Dark palette:

```
background     #0B0F12
surface        #161B1F
surfaceAlt     #1C2328
surfaceVariant #222A30
textPrimary    #E6EAEE
textSecondary  #98A2AB
textTertiary   #6B7480
border         #26303A
divider        #1F262C
```

## Theme entry point

`lib/core/theme/app_theme.dart` — both `lightTheme` and `darkTheme`
are `ThemeData` with `useMaterial3: true`, `fontFamily: 'TriooBangla'`,
and full component theming.

## User setting

Settings → Theme: System / Light / Dark. Persisted in
`LocalStorageService.themeMode`.

## Auditing new UI

Before merging a UI change, ensure:

1. All Text widgets use either `AppTextStyles.x` (no color baked in) or
   `ThemeColors.x(context)`.
2. Icons either have an explicit color via `ThemeColors` or rely on the
   theme's `iconTheme` / `primaryIconTheme`.
3. Containers pick `AppColors.darkSurface` when in dark mode (or use
   `AppCard`).

Audit command:

```bash
grep -rE "color:\s*AppColors\.(textPrimary|textSecondary|textTertiary)\b" lib
```

Should return only matches inside `app_theme.dart` and
`theme_colors.dart`.