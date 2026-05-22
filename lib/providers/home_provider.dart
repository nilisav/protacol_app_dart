import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workspace.dart';
import '../services/workspace_service.dart';

enum HomeState { loading, loaded, error }

class HomeData {
  final WorkspaceData workspace;
  final String? errorMessage;

  HomeData({required this.workspace, this.errorMessage});
}

class HomeNotifier extends StateNotifier<AsyncValue<HomeData?>> {
  final WorkspaceService _workspaceService;

  HomeNotifier(this._workspaceService) : super(const AsyncValue.loading());

  Future<void> loadWorkspace() async {
    state = const AsyncValue.loading();
    try {
      final workspace = await _workspaceService.loadWorkspace();
      state = AsyncValue.data(HomeData(workspace: workspace));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final homeProvider =
    StateNotifierProvider<HomeNotifier, AsyncValue<HomeData?>>((ref) {
  return HomeNotifier(ref.read(workspaceServiceProvider));
});