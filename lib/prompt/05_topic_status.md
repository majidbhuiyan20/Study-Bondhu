# 05 — Topic Status

Every topic has a learning status. This is the data the **Weakness Radar** and
"What Should I Study Now?" engine consume.

## Status enum

```dart
enum TopicStatus {
  notStarted,   // ⚪
  learning,     // 🟡
  weak,         // 🔴
  mastered,     // 🟢
}
```

## Model

```dart
class Topic {
  final int? id;
  final int subjectId;
  final int? parentId;     // for sub-topics (FCFS under CPU Scheduling)
  final String name;
  final TopicStatus status;
  final DateTime createdAt;
}
```

## UI (per subject)

```
Operating System — Topics

CPU Scheduling                  [Add topic]
  FCFS              🟢 Mastered
  SJF               🟢 Mastered
  Priority          🟡 Learning
  Round Robin       🔴 Weak
Memory Management              [Add topic]
  Paging            ⚪ Not started
  ...
```

Topics can be nested (parent topic → sub-topics). Status is set via
`ChoiceChip` row when adding/editing.

## How status changes

- **Manual**: user taps a chip to set the status.
- **From session**: if focus rating is "Weak" (1–2), the topic moves to
  `weak`; if "Strong" (5), it moves to `mastered`.
- **From revision**: revision performance updates status (see
  `10_smart_revision.md`).

## Files

```
lib/features/subjects/
├── models/topic.dart
└── (lives inside SubjectsViewModel)
```

`SubjectsViewModel.addTopic/updateTopic/deleteTopic/getTopics`.

## Aggregations

- A subject is "Weak" if it has ≥ 1 topic with `status == weak`.
- A subject is "Mastered" if ALL topics are `mastered`.