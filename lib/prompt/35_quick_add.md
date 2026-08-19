# 35 — Quick Add

A central "+" action that opens a sheet with one tap to add anything.

## Sheet options

```
+ Add

📚 Subject
📝 Task
📅 Exam
� Topic
🗒 Note
⏱ Study session
🏫 Attendance
🃏 Flashcard
💰 Expense
```

Each tile opens the relevant add form pre-filled with sensible defaults.

## Implementation

- FAB on Home / Subjects → opens the Quick Add sheet.
- The sheet is a `GridView` of icon tiles.
- Each tile calls `Navigator.push` to the appropriate Add view.

## Files

```
lib/core/widgets/quick_add_sheet.dart
lib/core/providers/quick_add_provider.dart    # optional, for analytics
```

## Why a sheet

A bottom sheet is fast (one tap to open, one tap to add), doesn't lose
context, and matches Material 3 patterns.