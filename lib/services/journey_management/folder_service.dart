import '../../core/net/api_client.dart';
import '../../models/folder_model.dart';

class FolderService {
  final ApiClient _apiClient = ApiClient();

  // 1. 获取全部文件夹列表
  Future<List<FolderModel>> getAllFolders() async {
    try {
      final response = await _apiClient.get('/journey/folders');
      final List list = response.data['data']['list'];
      return list.map((e) => FolderModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // 2. 新建文件夹
  Future<FolderModel?> createFolder(String name, String? desc) async {
    try {
      final response = await _apiClient.post(
        '/journey/folder',
        data: {'name': name, 'description': desc},
      );
      return FolderModel.fromJson(response.data['data']);
    } catch (e) {
      return null;
    }
  }

  // 3. 更新文件夹
  Future<FolderModel?> updateFolder(
    String folderId,
    String name,
    String? desc,
  ) async {
    try {
      final response = await _apiClient.patch(
        '/journey/folder/$folderId',
        data: {'name': name, 'description': desc},
      );
      return FolderModel.fromJson(response.data['data']);
    } catch (e) {
      return null;
    }
  }

  // 4. 删除文件夹
  Future<bool> deleteFolder(String folderId) async {
    try {
      final response = await _apiClient.delete('/journey/folder/$folderId');
      return response.data['code'] == 0;
    } catch (e) {
      return false;
    }
  }

  // 5. 获取文件夹详情及所属行程
  Future<Map<String, dynamic>?> getFolderDetail(
    String folderId, {
    int page = 1,
    int size = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/journey/folder/$folderId',
        queryParameters: {'page': page.toString(), 'size': size.toString()},
      );
      return response.data['data'];
    } catch (e) {
      return null;
    }
  }

  // 6. 将行程移入文件夹（单分类，覆盖式）
  Future<bool> moveJourneyToFolder(String folderId, String journeyId) async {
    try {
      final response = await _apiClient.post(
        '/journey/folder/$folderId/move/$journeyId',
      );
      return response.data['code'] == 0;
    } catch (e) {
      return false;
    }
  }

  // 7. 将行程移出文件夹
  Future<bool> removeJourneyFromFolder(
    String folderId,
    String journeyId,
  ) async {
    try {
      final response = await _apiClient.delete(
        '/journey/folder/$folderId/move/$journeyId',
      );
      return response.data['code'] == 0;
    } catch (e) {
      return false;
    }
  }
}