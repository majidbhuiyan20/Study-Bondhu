# 10 — Smart Revision System

One of the signature features. When a student studies a topic, they
schedule revisions. Confidence from each revision adjusts the next
interval.

## Spaced-repetition schedule

After a topic is first studied, schedule revisions at:

```
Day 1, Day 3, Day 7, Day 14, Day 30
```

But the **interval doubles** if the student rates "Strong", and **halves**
if rated "Weak".

## Model

```dart
class RevisionItem {
  final int? id;
  final int? subjectId;
  final int? topicId;
  final DateTime scheduledDate;
  final int intervalDays;     // current interval
  final RevisionStatus status; // pending, completed, skipped
  final DateTime createdAt;
}
```

## Revision workflow

```
🔔 "4 topics need revision today"

(Open revision card)

   CPU Scheduling
   When: today 8 PM

   [Mark as reviewed]
```

When marked reviewed:

```
How confident are you?

😕 Weak    🙂 Okay    � Strong
```

Choice updates:

- `RevisionItem.status = completed`
- Creates next revision with new interval.
- Updates `Topic.status`:
  - Weak → status becomes `weak`
  - Strong → status becomes `mastered`
  - Okay → unchanged

## Files

```
lib/features/revision/
├── models/revision_item.dart
├── repositories/revision_repository.dart
├── view_models/revision_view_model.dart
├── views/revision_view.dart
└── widgets/revision_card.dart
```

## Linked to

- Home Dashboard "Revision Due" section.
- What Should I Study Now? (revision due → boost priority).
- Analytics (revision count, completion %).