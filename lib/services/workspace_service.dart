import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/dio_client.dart';
import '../models/workspace.dart';

final workspaceServiceProvider = Provider<WorkspaceService>((ref) {
  return WorkspaceService(dio: ref.read(dioProvider));
});

class WorkspaceService {
  final Dio dio;

  WorkspaceService({required this.dio});

  Future<WorkspaceData> loadWorkspace() async {
    try {
      final response = await dio.post('/workspace/load-new', data: {});
      return WorkspaceData.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Ошибка загрузки данных';
      throw Exception(message);
    }
  }
}
