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
  /// 返回值包含文件夹基础信息和该文件夹下的行程列表 (list)
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
      // 返回的数据结构比较复杂，包含 folderId, title, journeys 列表等
      return response.data['data'];
    } catch (e) {
      return null;
    }
  }

  // 6. 将行程移入文件夹
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

  // 8. 将行程添加到文件夹（不覆盖已有文件夹，支持多分类）
  Future<bool> addJourneyToFolder(String folderId, String journeyId) async {
    try {
      final response = await _apiClient.post(
        '/journey/folder/$folderId/add/$journeyId',
      );
      return response.data['code'] == 0;
    } catch (e) {
      return false;
    }
  }

  // 9. 批量设置行程的文件夹（替换式-覆盖之前的关联）
  Future<bool> setJourneyFolders(String journeyId, List<String> folderIds) async {
    try {
      final response = await _apiClient.put(
        '/journey/folders/set',
        data: {'journeyId': journeyId, 'folderIds': folderIds},
      );
      return response.data['code'] == 0;
    } catch (e) {
      return false;
    }
  }
}
