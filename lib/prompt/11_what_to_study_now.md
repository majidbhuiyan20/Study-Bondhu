# 11 — "What Should I Study Now?"

The signature feature. The student enters available time (default 45 min)
and the engine builds a prioritized plan.

## Inputs

- Available time (minutes)
- Active profile + semester (filter)
- Upcoming exams (closer = higher priority)
- Weak topics (any subject)
- Revision due today
- Assignment deadlines (boost if due in 1–2 days)
- Incomplete syllabus items
- Daily goal progress (if not yet hit, fill the gap)

## Algorithm (priority weighted)

```
score = (
    exam_urgency * 4        // days_until_exam inverse
  + weak_topic_count * 3
  + revision_due * 3
  + assignment_urgency * 2
  + syllabus_incomplete * 1
  + goal_gap * 2
)
```

Pick the top subject, then within it the top topic.

## Output

```
Your 45-minute plan

🔴 25 min — Round Robin (Weak Topic)
🧠 10 min — Normalization (Revision Due)
📝 10 min — OS Practice
```

Tap "Start Plan" → opens Focus Mode for the first item; when stopped, the
next is queued.

## Files

```
lib/features/home/view_models/home_view_model.dart     # recommendation logic
lib/features/home/widgets/study_recommendation_card.dart
lib/features/study/view_models/study_view_model.dart   # queues the plan
```

## Bangla

- "What should I study now?" → "এখন কী পড়বে?"
- "Start Plan" → "প্ল্যান শুরু করো"