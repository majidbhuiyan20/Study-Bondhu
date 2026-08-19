import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../models/local_resource.dart';
import '../repositories/resources_repository.dart';

class ResourcesState {
  final bool isLoading;
  final List<LocalResource> resources;
  const ResourcesState(
      {this.isLoading = false, this.resources = const []});

  ResourcesState copyWith({bool? isLoading, List<LocalResource>? resources}) =>
      ResourcesState(
        isLoading: isLoading ?? this.isLoading,
        resources: resources ?? this.resources,
      );
}

class ResourcesViewModel extends StateNotifier<ResourcesState> {
  ResourcesViewModel(this._ref) : super(const ResourcesState());
  final Ref _ref;

  void bootstrap() => Future.microtask(load);

  Future<void> load({int? subjectId}) async {
    state = state.copyWith(isLoading: true);
    final list = await _ref
        .read(resourcesRepositoryProvider)
        .getResources(subjectId: subjectId);
    state = state.copyWith(isLoading: false, resources: list);
  }

  Future<void> add(LocalResource r) async {
    await _ref.read(resourcesRepositoryProvider).addResource(r);
    await load();
  }

  Future<void> delete(int id) async {
    await _ref.read(resourcesRepositoryProvider).deleteResource(id);
    await load();
  }
}

final resourcesRepositoryProvider = Provider<ResourcesRepository>(
  (ref) => ref.watch(resourcesRepositoryGlobalProvider),
);

final resourcesViewModelProvider =
    StateNotifierProvider<ResourcesViewModel, ResourcesState>(
  (ref) => ResourcesViewModel(ref),
);

/// Filtered view for a specific subject (or null = all).
final resourcesForSubjectProvider =
    FutureProvider.family<List<LocalResource>, int?>(
  (ref, subjectId) async =>
      ref.watch(resourcesRepositoryProvider).getResources(subjectId: subjectId),
);
