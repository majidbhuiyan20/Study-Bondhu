# Localization — Bangla + English

StudyBondhu ships in two natural languages:

- **English** — `locale: en`
- **Bangla** — `locale: bn` (using TriooBangla font for proper rendering)

## Where strings live

| Layer                                      | Mechanism                                    |
| ------------------------------------------ | -------------------------------------------- |
| Static UI strings (tabs, buttons, labels)  | `lib/l10n/app_localizations.dart` (ARB-generated). |
| Within widgets                            | `context.l10n.someKey`                       |
| Bangla detection                           | `context.l10n.isBangla` (extension)          |
| Dynamic content (notes, syllabus, etc.)    | Stored in database as the user enters them.  |

## Adding a new key

1. Add the key to `lib/l10n/app_en.arb`:
   ```json
   { "todayTasks": "Today's Tasks" }
   ```
2. Add the Bangla translation to `lib/l10n/app_bn.arb`:
   ```json
   { "todayTasks": "আজকের কাজ" }
   ```
3. Run `flutter pub get` — the generation tool rebuilds `AppLocalizations`.
4. Use it in code: `Text(context.l10n.todayTasks)`.

## Bangla font

- Single font family: **TriooBangla** (Tiro Bangla).
- Has solid Latin **and** Bangla glyph coverage, so we don't need a separate
  Latin fallback.
- Configured globally in `AppTheme.lightTheme.fontFamily` and
  `AppTheme.darkTheme.fontFamily`.

## Natural Bangla policy

The Bangla strings must read naturally, **not** as literal translations:

| English               | Bad (literal)         | Good (natural)            |
| --------------------- | --------------------- | ------------------------- |
| Today's tasks         | আজকের কাজগুলো         | আজকের কাজ                 |
| Study progress        | পড়াশোনার অগ্রগতি      | পড়ার অগ্রগতি               |
| Revision due          | পুনরাবৃত্তি বাকি       | আজ রিভিশন দিতে হবে          |
| Upcoming exam         | আসন্ন পরীক্ষা           | আসছে পরীক্ষা               |
| Weak topics           | দুর্বল বিষয়            | যেগুলো কঠিন লাগছে           |

## Date and number formatting

- Use `intl` package for date/number formatting.
- Locale-aware: `DateFormat.yMMMd(AppLocalizationsX.currentLocale)`.
- Currency: `৳` symbol (Bangladeshi Taka), prefixed.

## What NOT to translate

- Brand name: "StudyBondhu" stays English.
- Subject names — users enter them as-is, no translation.
- External API names (e.g. "FCFS", "BCNF") — keep as-is.