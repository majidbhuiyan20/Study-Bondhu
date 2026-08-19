# 33 — Bangladesh-Focused Onboarding

Onboarding collects the academic context once, at first launch.

## Education levels

```dart
enum ProfileLevel {
  school,
  college,
  university,
  diploma,
  madrasa,
  coaching,
}
```

Each level has different `classOptions`:

| Level       | Options                                                    |
| ----------- | ---------------------------------------------------------- |
| School      | Class 6, 7, 8, 9, 10 (SSC), 11, 12 (HSC)                   |
| College     | HSC 1st year, HSC 2nd year                                 |
| University  | 1st year, 2nd year, 3rd year, 4th year, Masters            |
| Diploma     | 1st year, 2nd year, 3rd year, 4th year                     |
| Madrasa     | Dakhil, Alim, Fazil, Kamil                                 |
| Coaching    | BCS, Medical, Engineering, University admission             |

## Onboarding flow

```
1. Welcome screen
   → "Let's set up your studies"

2. Profile
   → Name
   → Education level
   → Class / year
   → Institution (optional)

3. Semester
   → Default to current semester based on date
   → e.g. for August 2025 in Bangladesh: "Fall 2025" / "২০২৫ সেশন"

4. Subjects
   → Add first 3–5 subjects (color, name, code)

5. Daily goal
   → Slider 30min – 10h, default 3h

6. Language
   → Bangla / English

7. Theme
   → System / Light / Dark
```

## Flexibility

The app is **not** hardcoded to any specific curriculum. Users can add
custom subjects, custom syllabus, custom topics. Bangladesh-specific
defaults are conveniences, not constraints.

## Files

```
lib/features/profile/
├── models/profile.dart
├── view_models/profile_view_model.dart
├── views/profiles_view.dart
└── views/onboarding_view.dart
```

Onboarding is shown once on first launch (`firstRun == true` from
`LocalStorageService`); skipped thereafter.