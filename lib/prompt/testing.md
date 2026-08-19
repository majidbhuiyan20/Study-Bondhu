# Testing

## Layers

| Layer        | Test type      | Tooling                          |
| ------------ | -------------- | -------------------------------- |
| Models       | Unit           | `test` + `flutter_test`          |
| Repositories | Unit (in-mem sqflite) | `sqflite_common_ffi`     |
| ViewModels   | Unit           | `test` + `riverpod` test harness |
| Views        | Widget tests   | `flutter_test`                   |
| E2E happy-path smoke | Manual on device | —                          |

## Conventions

- One test file per source file: `subjects_repository.dart` →
  `test/subjects/subjects_repository_test.dart`.
- Test names follow the pattern: `"methodName: scenario"`. Example:
  `addSubject: stores name and returns id`.
- Use `group` for related tests, `setUp` for shared fixtures.

## ViewModel tests

```dart
test('load() reads from repository', () async {
  final container = ProviderContainer(
    overrides: [
      subjectsRepositoryProvider.overrideWithValue(fakeRepo),
    ],
  );
  await container.read(subjectsViewModelProvider.notifier).bootstrap();
  await container.read(subjectsViewModelProvider.notifier).future; // settles
  final state = container.read(subjectsViewModelProvider);
  expect(state.subjects, hasLength(2));
});
```

## Run all tests

```bash
flutter test
```

## Static checks before shipping

```bash
flutter analyze   # must be 0 errors
flutter test      # must be 0 failures
```

A PR isn't mergeable until both pass.