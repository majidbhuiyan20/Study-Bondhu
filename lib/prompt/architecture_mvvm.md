# Architecture — MVVM

StudyBondhu uses **MVVM** strictly. Every feature has three layers:

```
View (UI)        → ConsumerStatefulWidget / ConsumerWidget
   ↓ ref.watch / ref.read
ViewModel        → StateNotifier / AsyncNotifier
   ↓ reads
Repository       → plain Dart class on top of sqflite
   ↓ owns
Data Source      → AppDatabase (sqflite handle)
```

## Folder layout

```
lib/features/<feature>/
├── models/           # plain Dart classes (Subject, Topic, Assignment, ...)
├── repositories/     # CRUD over the database
├── view_models/      # StateNotifier + State class
├── views/            # Top-level screens (one Widget per route)
└── widgets/          # Smaller reusable UI pieces used inside views
```

## Hard rules

1. **Views never touch the database or repository directly.** They must go
   through `ref.read(featureViewModelProvider.notifier).someAction(...)`.
2. **Repositories never touch Riverpod.** They take an `AppDatabase`
   parameter and stay pure Dart so they can be unit-tested.
3. **Models are immutable.** Use `copyWith` to mutate. Equality is generated
   (`equatable` or manual hashCode/==).
4. **One ViewModel per feature.** A "feature" is a unit the user can see on
   the bottom nav or as a top-level section in `More`.

## Naming

- `XxxState` → immutable state for the ViewModel
- `XxxViewModel extends StateNotifier<XxxState>` → the ViewModel
- `xxxViewModelProvider` → the Riverpod provider exposing it
- `XxxView extends ConsumerStatefulWidget` → the top-level screen
- `XxxCard / XxxRow / XxxTile` → leaf widgets used inside the view

## State mutation rules

- ViewModels mutate state ONLY inside action methods, never in the
  constructor.
- Constructors may read from `LocalStorageService` synchronously to seed
  initial state, but they MUST NOT trigger DB reads or write other providers.
- DB reads belong in `load()`. `load()` is called from `bootstrap()`, which
  is invoked from the view's `initState` via
  `WidgetsBinding.instance.addPostFrameCallback`.

See `architecture_riverpod.md` for the gory details of why.