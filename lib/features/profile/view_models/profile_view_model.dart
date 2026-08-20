import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/profile.dart';

class ProfileState {
  final bool isLoading;
  final List<Profile> profiles;
  final Profile? active;
  const ProfileState({
    this.isLoading = false,
    this.profiles = const [],
    this.active,
  });

  ProfileState copyWith({
    bool? isLoading,
    List<Profile>? profiles,
    Profile? active,
  }) =>
      ProfileState(
        isLoading: isLoading ?? this.isLoading,
        profiles: profiles ?? this.profiles,
        active: active ?? this.active,
      );
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  ProfileViewModel(this._ref) : super(const ProfileState());
  final Ref _ref;

  void bootstrap() {
    Future.microtask(load);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(profileRepositoryProvider);
    final profiles = await repo.getProfiles();
    // Ensure there is at least one profile (default if DB is empty).
    if (profiles.isEmpty) {
      await repo.addProfile(Profile(
        name: 'My studies',
        level: ProfileLevel.school,
        createdAt: DateTime.now(),
      ));
    }
    final fresh = await repo.getProfiles();

    // Restore persisted active selection when possible.
    final savedId = LocalStorageService.instance.activeProfileId;
    Profile? active;
    if (savedId != null) {
      for (final p in fresh) {
        if (p.id.toString() == savedId) {
          active = p;
          break;
        }
      }
    }
    active ??= fresh.isNotEmpty ? fresh.first : null;

    state = ProfileState(
      isLoading: false,
      profiles: fresh,
      active: active,
    );
  }

  /// Adds a profile and (optionally) makes it the active one in a single
  /// round trip. Returns the freshly-assigned [Profile] with its DB id.
  Future<Profile> addProfile(Profile p, {bool setAsActive = false}) async {
    final id =
        await _ref.read(profileRepositoryProvider).addProfile(p);
    await load();
    final created = state.profiles.firstWhere(
      (x) => x.id == id,
      orElse: () => p.copyWith(id: id),
    );
    if (setAsActive) {
      await setActive(created);
    }
    return created;
  }

  Future<void> updateProfile(Profile p) async {
    await _ref.read(profileRepositoryProvider).updateProfile(p);
    await load();
  }

  Future<void> deleteProfile(int id) async {
    await _ref.read(profileRepositoryProvider).deleteProfile(id);
    // If the deleted profile was active, clear the persisted id so the
    // next bootstrap reverts to the first profile.
    if (state.active?.id == id) {
      await LocalStorageService.instance.setActiveProfileId(null);
    }
    await load();
  }

  /// Marks [p] as the active profile and persists the choice.
  Future<void> setActive(Profile p) async {
    state = state.copyWith(active: p);
    await LocalStorageService.instance.setActiveProfileId(p.id?.toString());
  }
}

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>(
  (ref) => ProfileViewModel(ref),
);