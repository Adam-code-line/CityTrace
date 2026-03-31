import '../../core/net/api_client.dart';
import '../../models/journey_model.dart';

class JourneyService {
  final ApiClient _apiClient = ApiClient();

  /// 1. 开始新行程
  Future<JourneyModel?> startJourney({
    required String title,
    String? description,
    String? cover,
  }) async {
    try {
      final response = await _apiClient.post(
        '/journey',
        data: {'title': title, 'description': description, 'cover': cover},
      );
      return JourneyModel.fromJson(response.data['data']);
    } catch (e) {
      return null;
    }
  }

  /// 2. 结束行程
  Future<bool> endJourney(String journeyId, {String? description}) async {
    try {
      final response = await _apiClient.patch(
        '/journey/$journeyId/end',
        data: {'description': description},
      );
      return response.data['code'] == 0;
    } catch (e) {
      return false;
    }
  }

  /// 3. 获取行程详情 (包含瞬间列表)
  Future<JourneyModel?> getJourneyDetail(String journeyId) async {
    try {
      final response = await _apiClient.get('/journey/$journeyId');
      return JourneyModel.fromJson(response.data['data']);
    } catch (e) {
      return null;
    }
  }

  /// 4. 获取行程列表 (分页)
  Future<List<JourneyModel>> getJourneyList({
    int page = 1,
    int size = 10,
    String folderId = "",
  }) async {
    try {
      final response = await _apiClient.get(
        '/journey/list',
        queryParameters: {'page': page, 'size': size, 'folderId': folderId},
      );
      final List listData = response.data['data']['list'];
      return listData.map((item) => JourneyModel.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 5. 删除行程
  Future<bool> deleteJourney(String journeyId) async {
    try {
      final response = await _apiClient.delete('/journey/$journeyId');
      return response.data['code'] == 0;
    } catch (e) {
      return false;
    }
  }

  /// 6. 更新行程
  Future<JourneyModel?> updateJourney(
    String journeyId, {
    String? title,
    String? description,
    String? cover,
  }) async {
    try {
      final response = await _apiClient.patch(
        '/journey/$journeyId',
        data: {'title': title, 'description': description, 'cover': cover},
      );
      return JourneyModel.fromJson(response.data['data']);
    } catch (e) {
      return null;
    }
  }
}
