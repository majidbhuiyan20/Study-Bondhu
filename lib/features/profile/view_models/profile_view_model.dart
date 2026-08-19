import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
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
    state = ProfileState(
      isLoading: false,
      profiles: fresh,
      active: fresh.isNotEmpty ? fresh.first : null,
    );
  }

  Future<void> addProfile(Profile p) async {
    await _ref.read(profileRepositoryProvider).addProfile(p);
    await load();
  }

  Future<void> updateProfile(Profile p) async {
    await _ref.read(profileRepositoryProvider).updateProfile(p);
    await load();
  }

  Future<void> deleteProfile(int id) async {
    await _ref.read(profileRepositoryProvider).deleteProfile(id);
    await load();
  }

  Future<void> setActive(Profile p) async {
    state = state.copyWith(active: p);
  }
}

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>(
  (ref) => ProfileViewModel(ref),
);