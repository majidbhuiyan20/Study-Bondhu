# Architecture — Riverpod

We use **Riverpod 2.x** with `StateNotifierProvider` for screen-level state
and `FutureProvider` / `FutureProvider.autoDispose` for one-shot reads.

## The single most important rule

> **A provider must NEVER mutate the state of another provider during its own
> initialization.**

Violation looks like this:

```dart
class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel(this._ref) : super(const HomeState()) {
    load(); // ❌ BAD — load() awaits other providers' .load()
  }
}
```

Riverpod throws:

```
Providers are not allowed to modify other providers during their initialization.
```

### The pattern that fixes it

1. ViewModels are **silent in the constructor** — no `load()` call.
2. Each ViewModel exposes a `bootstrap()` method:
   ```dart
   void bootstrap() {
     Future.microtask(load);
   }
   ```
3. The view calls `bootstrap()` from `initState`, after the first frame:
   ```dart
   @override
   void initState() {
     super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
       if (mounted) ref.read(xxxViewModelProvider.notifier).bootstrap();
     });
   }
   ```

This guarantees the load runs *after* the current build cycle completes, so
Riverpod's "currently building" check passes.

## Required view structure

Every view that watches a `StateNotifierProvider` must be a
`ConsumerStatefulWidget` (not `ConsumerWidget`) so it can drive `bootstrap()`
in `initState`. Pure `ConsumerWidget` is acceptable only for views that
consume already-loaded providers (e.g. card widgets).

## Provider discovery

- `Provider` — for synchronous derived state (e.g. `todayAssignmentsProvider`).
- `StateNotifierProvider` — for screen-level state with mutations.
- `FutureProvider` — for one-shot async reads that don't need mutations.
- `FutureProvider.autoDispose` — same, but cleans up when no listeners.

When a `FutureProvider` reads from another provider, mark it as `autoDispose`
unless the data is genuinely global.

## What NOT to do

- ❌ `await ref.read(provider.future)` inside another provider's action body
  if it can be avoided — prefer `ref.watch` for derived state.
- ❌ Calling `load()` synchronously in a constructor.
- ❌ Mutating `state` from inside `build()` callbacks.
- ❌ Using `ChangeNotifier` — we standardized on `StateNotifier`.

## Selecting a derived provider

```dart
final pendingAssignmentsProvider = Provider<List<Assignment>>((ref) {
  final all = ref.watch(assignmentsViewModelProvider).assignments;
  return all.where((a) => a.status == AssignmentStatus.pending).toList();
});
```

This pattern composes well with the bootstrap fix — when the upstream
StateNotifier is later loaded, the derived provider rebuilds automatically.