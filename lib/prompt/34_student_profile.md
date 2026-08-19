# 34 — Student Profile

Each profile represents one academic identity.

## Model

```dart
class Profile {
  final int? id;
  final String name;
  final ProfileLevel level;
  final String? classLabel;
  final String? institution;
  final String? department;
  final String? studentId;
  final DateTime createdAt;
}
```

## Rules

- Multiple profiles are allowed.
- Only ONE profile is **active** at a time.
- Switching profile switches the visible subjects/semesters/etc.
- Profile deletion cascades to its semesters + subjects.

## UI

- Top-level screen in More tab.
- Each profile is a card; the active one has an "Active" badge.
- Tap card → activate.
- Tap pencil → edit.
- Tap trash → confirm delete.

## Files

```
lib/features/profile/
├── models/profile.dart
├── repositories/profile_repository.dart
├── view_models/profile_view_model.dart
└── views/profiles_view.dart
```

`profileViewModelProvider.active` is read by Subjects / Semesters / Home
to filter content to the active profile.