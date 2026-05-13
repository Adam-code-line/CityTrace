/// Mock 数据定义
/// 模拟所有后端 API 接口的返回数据，结构与后端一致：
/// { "code": 0, "msg": "success", "data": {...} }
class MockData {
  /// ==================== 认证相关 ====================

  /// 模拟 Token
  static const String mockToken =
      "mock_token_citytrace_eyJhbGciOiJIUzI1NiJ9.mock";

  /// 模拟用户信息
  static const Map<String, dynamic> mockUserData = {
    "userId": "user_mock_001",
    "account": "demo",
    "username": "Demo用户",
    "avatar": "https://picsum.photos/200",
  };

  /// POST /user/register - 注册
  static Map<String, dynamic> register(Map<String, dynamic> body) {
    return {
      "code": 0,
      "msg": "注册成功",
      "data": {"token": mockToken, "userId": "user_mock_001"},
    };
  }

  /// POST /user/login - 登录
  static Map<String, dynamic> login(Map<String, dynamic> body) {
    final account = body['account'];
    if (account == null || account.toString().trim().isEmpty) {
      return {"code": 1001, "msg": "账号不能为空", "data": null};
    }
    // 模拟只要密码不为空就登录成功
    return {
      "code": 0,
      "msg": "登录成功",
      "data": {"token": mockToken},
    };
  }

  /// GET /user/profile - 获取个人资料
  static const Map<String, dynamic> profile = {
    "code": 0,
    "msg": "success",
    "data": mockUserData,
  };

  /// PUT /user/profile - 更新个人资料
  static const Map<String, dynamic> updateProfile = {
    "code": 0,
    "msg": "更新成功",
    "data": null,
  };

  /// POST /user/avatar/upload - 上传头像
  static const Map<String, dynamic> uploadAvatar = {
    "code": 0,
    "msg": "上传成功",
    "data": {"avatarUrl": "https://picsum.photos/200"},
  };

  /// GET /user/check-token - 检查 Token 有效性
  static const Map<String, dynamic> checkToken = {
    "code": 0,
    "msg": "Token 有效",
    "data": null,
  };

  /// POST /user/logout - 退出登录
  static const Map<String, dynamic> logout = {
    "code": 0,
    "msg": "退出成功",
    "data": null,
  };

  /// ==================== 行程相关 ====================

  /// 模拟行程列表（支持分页）
  static List<Map<String, dynamic>> _journeyList = [
    {
      "journeyId": "journey_mock_001",
      "title": "上海外滩漫步",
      "description": "从外滩走到南京路，感受魔都的繁华",
      "cover": "https://picsum.photos/400/300?random=1",
      "status": "ended",
      "startTime": "2026-05-01 14:30:00",
      "endTime": "2026-05-01 17:45:00",
      "folderId": null,
      "moments": ["moment_mock_001", "moment_mock_002"],
    },
    {
      "journeyId": "journey_mock_002",
      "title": "北京胡同探索",
      "description": "南锣鼓巷到什刹海，感受老北京文化",
      "cover": "https://picsum.photos/400/300?random=2",
      "status": "ended",
      "startTime": "2026-05-03 09:00:00",
      "endTime": "2026-05-03 12:20:00",
      "folderId": null,
      "moments": ["moment_mock_003"],
    },
    {
      "journeyId": "journey_mock_003",
      "title": "杭州西湖骑行",
      "description": "环西湖骑行，欣赏湖光山色",
      "cover": "https://picsum.photos/400/300?random=3",
      "status": "ended",
      "startTime": "2026-05-05 10:00:00",
      "endTime": "2026-05-05 15:30:00",
      "folderId": "folder_mock_001",
      "moments": ["moment_mock_004", "moment_mock_005", "moment_mock_006"],
    },
    {
      "journeyId": "journey_mock_004",
      "title": "成都美食之旅",
      "description": "打卡锦里、宽窄巷子，品尝地道川菜",
      "cover": "https://picsum.photos/400/300?random=4",
      "status": "ended",
      "startTime": "2026-05-08 11:00:00",
      "endTime": "2026-05-08 20:00:00",
      "folderId": "folder_mock_001",
      "moments": [],
    },
    {
      "journeyId": "journey_mock_005",
      "title": "今日城市探索",
      "description": "随心漫步，记录城市角落",
      "cover": "https://picsum.photos/400/300?random=5",
      "status": "ongoing",
      "startTime": "2026-05-13 08:30:00",
      "endTime": null,
      "folderId": null,
      "moments": ["moment_mock_007"],
    },
  ];

  /// 模拟瞬间数据
  static final List<Map<String, dynamic>> _momentList = [
    {
      "momentId": "moment_mock_001",
      "journeyId": "journey_mock_001",
      "time": "2026-05-01 15:00:00",
      "type": "image",
      "title": "外滩观景台",
      "location": {
        "lat": "31.2400",
        "lon": "121.4900",
        "name": "外滩观景台",
      },
      "context": "天气很好，对面陆家嘴的建筑群清晰可见",
      "media": "https://picsum.photos/600/400?random=10",
      "mediaDescription": "外滩全景照片，黄浦江对岸是陆家嘴金融中心",
      "tags": ["外滩", "上海", "风景"],
    },
    {
      "momentId": "moment_mock_007",
      "journeyId": "journey_mock_005",
      "time": "2026-05-13 09:00:00",
      "type": "image",
      "title": "街角咖啡馆",
      "location": {
        "lat": "31.2300",
        "lon": "121.4700",
        "name": "街角咖啡馆",
      },
      "context": "一家很有格调的独立咖啡馆",
      "media": "https://picsum.photos/600/400?random=11",
      "mediaDescription": "温馨的咖啡馆内部环境",
      "tags": ["咖啡", "探店"],
    },
    {
      "momentId": "moment_mock_002",
      "journeyId": "journey_mock_001",
      "time": "2026-05-01 16:30:00",
      "type": "text",
      "title": "南京路步行街",
      "location": {
        "lat": "31.2350",
        "lon": "121.4780",
        "name": "南京路步行街",
      },
      "context": "人流如织，繁华热闹的南京路步行街，各种品牌旗舰店林立。",
      "media": null,
      "mediaDescription": null,
      "tags": ["南京路", "购物"],
    },
    {
      "momentId": "moment_mock_003",
      "journeyId": "journey_mock_002",
      "time": "2026-05-03 10:30:00",
      "type": "image",
      "title": "南锣鼓巷",
      "location": {
        "lat": "39.9370",
        "lon": "116.4030",
        "name": "南锣鼓巷",
      },
      "context": "充满文艺气息的老胡同",
      "media": "https://picsum.photos/600/400?random=20",
      "mediaDescription": "南锣鼓巷的胡同街景",
      "tags": ["胡同", "北京", "文艺"],
    },
    {
      "momentId": "moment_mock_004",
      "journeyId": "journey_mock_003",
      "time": "2026-05-05 11:00:00",
      "type": "image",
      "title": "断桥残雪",
      "location": {
        "lat": "30.2600",
        "lon": "120.1500",
        "name": "断桥残雪",
      },
      "context": "白堤上的断桥，满满的江南韵味",
      "media": "https://picsum.photos/600/400?random=30",
      "mediaDescription": "西湖断桥景观",
      "tags": ["西湖", "杭州", "江南"],
    },
    {
      "momentId": "moment_mock_005",
      "journeyId": "journey_mock_003",
      "time": "2026-05-05 12:30:00",
      "type": "audio",
      "title": "湖边鸟鸣",
      "location": {
        "lat": "30.2580",
        "lon": "120.1450",
        "name": "苏堤",
      },
      "context": "在苏堤上休息时录下的鸟叫声",
      "media": null,
      "mediaDescription": "清晰的鸟鸣声，环境安静平和",
      "tags": ["自然", "鸟鸣"],
    },
    {
      "momentId": "moment_mock_006",
      "journeyId": "journey_mock_003",
      "time": "2026-05-05 14:00:00",
      "type": "location",
      "title": "雷峰塔",
      "location": {
        "lat": "30.2400",
        "lon": "120.1550",
        "name": "雷峰塔",
      },
      "context": "登塔俯瞰整个西湖全景",
      "media": "https://picsum.photos/600/400?random=31",
      "mediaDescription": "从雷峰塔顶俯瞰西湖",
      "tags": ["雷峰塔", "西湖"],
    },
  ];

  /// POST /journey - 创建新行程
  static Map<String, dynamic> startJourney(Map<String, dynamic> body) {
    final newId = "journey_mock_${DateTime.now().millisecondsSinceEpoch}";
    final newJourney = {
      "journeyId": newId,
      "title": body['title'] ?? '未命名行程',
      "description": body['description'],
      "cover": body['cover'] ?? "https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}",
      "status": "ongoing",
      "startTime": DateTime.now().toIso8601String(),
      "endTime": null,
      "folderId": null,
      "moments": [],
    };
    _journeyList.insert(0, newJourney);
    return {
      "code": 0,
      "msg": "success",
      "data": newJourney,
    };
  }

  /// PATCH /journey/:id/end - 结束行程
  static Map<String, dynamic> endJourney(String id) {
    final idx = _journeyList.indexWhere((j) => j['journeyId'] == id);
    if (idx != -1) {
      _journeyList[idx]['status'] = 'ended';
      _journeyList[idx]['endTime'] = DateTime.now().toIso8601String();
    }
    return {"code": 0, "msg": "行程已结束", "data": null};
  }

  /// GET /journey/:id - 获取行程详情
  static Map<String, dynamic> getJourneyDetail(String id) {
    final journey =
        _journeyList.firstWhere((j) => j['journeyId'] == id, orElse: () => <String, dynamic>{});
    if (journey.isEmpty) {
      return {"code": 1004, "msg": "行程不存在", "data": null};
    }
    return {"code": 0, "msg": "success", "data": journey};
  }

  /// GET /journey/list - 获取行程列表
  static Map<String, dynamic> getJourneyList(Map<String, dynamic> params) {
    final page = params['page'] ?? 1;
    final size = params['size'] ?? 10;
    final folderId = params['folderId'] ?? '';

    var list = _journeyList;
    if (folderId.isNotEmpty) {
      list = list.where((j) => j['folderId'] == folderId).toList();
    }

    final start = ((page as int) - 1) * (size as int);
    final end = start + size;
    final paged = list.sublist(start, end > list.length ? list.length : end);

    return {
      "code": 0,
      "msg": "success",
      "data": {
        "list": paged,
        "total": list.length,
        "page": page,
        "size": size,
      },
    };
  }

  /// DELETE /journey/:id - 删除行程
  static Map<String, dynamic> deleteJourney(String id) {
    _journeyList.removeWhere((j) => j['journeyId'] == id);
    return {"code": 0, "msg": "删除成功", "data": null};
  }

  /// PATCH /journey/:id - 更新行程
  static Map<String, dynamic> updateJourney(String id, Map<String, dynamic> body) {
    final idx = _journeyList.indexWhere((j) => j['journeyId'] == id);
    if (idx != -1) {
      _journeyList[idx].addAll(body);
    }
    return {"code": 0, "msg": "更新成功", "data": _journeyList[idx]};
  }

  /// ==================== 瞬间相关 ====================

  /// POST /journey/moment - 上传瞬间
  static Map<String, dynamic> uploadMoment(Map<String, dynamic> body) {
    final newId = "moment_mock_${DateTime.now().millisecondsSinceEpoch}";
    final newMoment = {
      "momentId": newId,
      "journeyId": body['journeyId'],
      "time": DateTime.now().toIso8601String(),
      "type": body['type'] ?? 'text',
      "title": body['title'],
      "location": {
        "lat": body['lat'] ?? "31.2304",
        "lon": body['lon'] ?? "121.4737",
        "name": body['location'] ?? "当前位置",
      },
      "context": body['context'],
      "media": "https://picsum.photos/600/400?random=${DateTime.now().millisecondsSinceEpoch}",
      "mediaDescription": null,
      "tags": [],
    };
    _momentList.insert(0, newMoment);
    return {"code": 0, "msg": "上传成功", "data": newMoment};
  }

  /// GET /journey/moment/:id - 获取瞬间详情
  static Map<String, dynamic> getMomentDetail(String id) {
    final moment =
        _momentList.firstWhere((m) => m['momentId'] == id, orElse: () => <String, dynamic>{});
    if (moment.isEmpty) {
      return {"code": 1005, "msg": "瞬间不存在", "data": null};
    }
    return {"code": 0, "msg": "success", "data": moment};
  }

  /// PATCH /journey/moment/:id - 更新瞬间
  static Map<String, dynamic> updateMoment(String id, Map<String, dynamic> body) {
    final idx = _momentList.indexWhere((m) => m['momentId'] == id);
    if (idx != -1) {
      _momentList[idx].addAll(body);
    }
    return {"code": 0, "msg": "更新成功", "data": _momentList[idx]};
  }

  /// DELETE /journey/moment/:id - 删除瞬间
  static Map<String, dynamic> deleteMoment(String id) {
    _momentList.removeWhere((m) => m['momentId'] == id);
    return {"code": 0, "msg": "删除成功", "data": null};
  }

  /// ==================== 文件夹相关 ====================

  static final List<Map<String, dynamic>> _folderList = [
    {
      "folderId": "folder_mock_001",
      "name": "城市旅行",
      "description": "各个城市旅行的记录",
      "createTime": "2026-04-01 10:00:00",
      "journeyCount": "2",
    },
    {
      "folderId": "folder_mock_002",
      "name": "周末短途",
      "description": "周末到周边短途游",
      "createTime": "2026-04-15 14:00:00",
      "journeyCount": "0",
    },
  ];

  /// GET /journey/folders - 获取所有文件夹
  static const Map<String, dynamic> getAllFolders = {
    "code": 0,
    "msg": "success",
    "data": {
      "list": [
        {"folderId": "folder_mock_001", "name": "城市旅行", "description": "各个城市旅行的记录", "createTime": "2026-04-01 10:00:00", "journeyCount": "2"},
        {"folderId": "folder_mock_002", "name": "周末短途", "description": "周末到周边短途游", "createTime": "2026-04-15 14:00:00", "journeyCount": "0"},
      ],
    },
  };

  /// POST /journey/folder - 新建文件夹
  static Map<String, dynamic> createFolder(Map<String, dynamic> body) {
    final newFolder = {
      "folderId": "folder_mock_${DateTime.now().millisecondsSinceEpoch}",
      "name": body['name'],
      "description": body['description'],
      "createTime": DateTime.now().toIso8601String(),
      "journeyCount": "0",
    };
    _folderList.add(newFolder);
    return {"code": 0, "msg": "创建成功", "data": newFolder};
  }

  /// GET /journey/folder/:id - 文件夹详情及行程列表
  static Map<String, dynamic> getFolderDetail(String id) {
    final folder = _folderList.firstWhere((f) => f['folderId'] == id, orElse: () => <String, dynamic>{});
    if (folder.isEmpty) {
      return {"code": 1006, "msg": "文件夹不存在", "data": null};
    }
    final journeys = _journeyList.where((j) => j['folderId'] == id).toList();
    return {
      "code": 0,
      "msg": "success",
      "data": {
        "folder": folder,
        "journeys": journeys,
      },
    };
  }

  /// PATCH /journey/folder/:id - 更新文件夹
  static Map<String, dynamic> updateFolder(String id, Map<String, dynamic> body) {
    final idx = _folderList.indexWhere((f) => f['folderId'] == id);
    if (idx != -1) {
      _folderList[idx].addAll(body);
    }
    return {"code": 0, "msg": "更新成功", "data": _folderList[idx]};
  }

  /// DELETE /journey/folder/:id - 删除文件夹
  static Map<String, dynamic> deleteFolder(String id) {
    _folderList.removeWhere((f) => f['folderId'] == id);
    return {"code": 0, "msg": "删除成功", "data": null};
  }

  /// POST /journey/folder/:folder/move/:journey - 行程移入文件夹
  static Map<String, dynamic> moveJourneyToFolder(String folderId, String journeyId) {
    final jIdx = _journeyList.indexWhere((j) => j['journeyId'] == journeyId);
    if (jIdx != -1) {
      _journeyList[jIdx]['folderId'] = folderId;
    }
    return {"code": 0, "msg": "移入成功", "data": null};
  }

  /// DELETE /journey/folder/:folder/move/:journey - 行程移出文件夹
  static Map<String, dynamic> removeJourneyFromFolder(String folderId, String journeyId) {
    final jIdx = _journeyList.indexWhere((j) => j['journeyId'] == journeyId);
    if (jIdx != -1) {
      _journeyList[jIdx]['folderId'] = null;
    }
    return {"code": 0, "msg": "移出成功", "data": null};
  }

  /// ==================== 环境上下文 ====================

  /// GET /context/geo - 逆地理编码
  static const Map<String, dynamic> geoInfo = {
    "code": 0,
    "msg": "success",
    "data": {
      "country": "中国",
      "province": "上海市",
      "city": "上海市",
      "district": "黄浦区",
      "name": "人民广场",
      "address": "上海市黄浦区人民大道",
    },
  };

  /// GET /context/weather - 获取天气
  static const Map<String, dynamic> weather = {
    "code": 0,
    "msg": "success",
    "data": {
      "weather": {
        "temp": 24.0,
        "condition": "多云",
        "icon": "cloudy",
      }
    },
  };

  /// ==================== AI 相关 ====================

  /// POST /ai/generate/note - 生成游记
  static Map<String, dynamic> generateNote(Map<String, dynamic> body) {
    return {
      "code": 0,
      "msg": "success",
      "data": {
        "title": "城市漫步日记",
        "body": "今天是一个美好的日子，我漫步在城市的街头，感受着这座城市的脉搏。"
            "从繁华的商业街到安静的小巷，每一处都充满了惊喜。"
            "午后的阳光洒在古老的建筑上，光影交错间仿佛能听到历史的回声。"
            "这是一次难忘的城市探索之旅，期待下一次的相遇。",
        "tags": ["城市漫步", "探索", "旅行日记"],
      },
    };
  }

  /// POST /api/v1/ai/analyze/image - 图片分析
  static const Map<String, dynamic> analyzeImage = {
    "code": 0,
    "msg": "success",
    "data": {
      "description": "这是一张城市街景照片，画面中有古老的建筑和现代的高楼大厦交相辉映，"
          "街道上行人往来，充满了生活气息。天空湛蓝，光线充足，是一个晴朗的好天气。",
      "tags": ["城市", "建筑", "街景", "晴朗"],
    },
  };

  /// POST /api/v1/ai/analyze/audio - 音频分析
  static const Map<String, dynamic> analyzeAudio = {
    "code": 0,
    "msg": "success",
    "data": {
      "transcript": "今天天气真不错，微风拂面，让人心情愉悦。"
          "这条街道两旁的梧桐树特别美，秋天的叶子一定更漂亮。",
      "emotion": "平静，愉悦",
      "language": "zh",
    },
  };

  /// ==================== 工具方法 ====================

  /// 根据请求路径和方法获取对应的模拟响应
  static Map<String, dynamic>? getResponse(
      String method, String path, Map<String, dynamic>? body) {
    // ========== 认证接口 ==========
    if (path == '/user/register' && method == 'POST') {
      return register(body ?? {});
    }
    if (path == '/user/login' && method == 'POST') {
      return login(body ?? {});
    }
    if (path == '/user/profile' && method == 'GET') {
      return Map<String, dynamic>.from(profile);
    }
    if (path == '/user/profile' && method == 'PUT') {
      return Map<String, dynamic>.from(updateProfile);
    }
    if (path == '/user/avatar/upload' && method == 'POST') {
      return Map<String, dynamic>.from(uploadAvatar);
    }
    if (path == '/user/check-token' && method == 'GET') {
      return Map<String, dynamic>.from(checkToken);
    }
    if (path == '/user/logout' && method == 'POST') {
      return Map<String, dynamic>.from(logout);
    }

    // ========== 行程接口 ==========
    if (path == '/journey' && method == 'POST') {
      return startJourney(body ?? {});
    }
    if (path.startsWith('/journey/') && path.endsWith('/end') && method == 'PATCH') {
      final id = path.replaceAll('/journey/', '').replaceAll('/end', '');
      return endJourney(id);
    }
    if (path == '/journey/list' && method == 'GET') {
      return getJourneyList(body ?? {});
    }
    if (path.startsWith('/journey/') && method == 'GET') {
      final id = path.replaceAll('/journey/', '');
      if (!id.contains('/')) {
        return getJourneyDetail(id);
      }
    }
    if (path.startsWith('/journey/') && method == 'DELETE') {
      final id = path.replaceAll('/journey/', '');
      if (!id.contains('/')) {
        return deleteJourney(id);
      }
    }
    if (path.startsWith('/journey/') && method == 'PATCH') {
      final id = path.replaceAll('/journey/', '');
      if (!id.contains('/')) {
        return updateJourney(id, body ?? {});
      }
    }

    // ========== 瞬间接口 ==========
    if (path == '/journey/moment' && method == 'POST') {
      return uploadMoment(body ?? {});
    }
    if (path.startsWith('/journey/moment/') && method == 'GET') {
      final id = path.replaceAll('/journey/moment/', '');
      return getMomentDetail(id);
    }
    if (path.startsWith('/journey/moment/') && method == 'PATCH') {
      final id = path.replaceAll('/journey/moment/', '');
      return updateMoment(id, body ?? {});
    }
    if (path.startsWith('/journey/moment/') && method == 'DELETE') {
      final id = path.replaceAll('/journey/moment/', '');
      return deleteMoment(id);
    }

    // ========== 文件夹接口 ==========
    if (path == '/journey/folders' && method == 'GET') {
      return Map<String, dynamic>.from(getAllFolders);
    }
    if (path == '/journey/folder' && method == 'POST') {
      return createFolder(body ?? {});
    }
    if (path.startsWith('/journey/folder/') && path.contains('/move/') && method == 'POST') {
      // 解析 /journey/folder/:folder/move/:journey → ['', 'journey', 'folder', '{folderId}', 'move', '{journeyId}']
      final parts = path.split('/');
      if (parts.length >= 6) {
        final folderId = parts[3];
        final journeyId = parts[5];
        return moveJourneyToFolder(folderId, journeyId);
      }
    }
    if (path.startsWith('/journey/folder/') && path.contains('/move/') && method == 'DELETE') {
      final parts = path.split('/');
      if (parts.length >= 6) {
        final folderId = parts[3];
        final journeyId = parts[5];
        return removeJourneyFromFolder(folderId, journeyId);
      }
    }
    if (path.startsWith('/journey/folder/') && method == 'GET') {
      final id = path.replaceAll('/journey/folder/', '');
      if (!id.contains('/')) {
        return getFolderDetail(id);
      }
    }
    if (path.startsWith('/journey/folder/') && method == 'PATCH') {
      final id = path.replaceAll('/journey/folder/', '');
      if (!id.contains('/')) {
        return updateFolder(id, body ?? {});
      }
    }
    if (path.startsWith('/journey/folder/') && method == 'DELETE') {
      final id = path.replaceAll('/journey/folder/', '');
      if (!id.contains('/')) {
        return deleteFolder(id);
      }
    }

    // ========== 环境上下文 ==========
    if (path == '/context/geo' && method == 'GET') {
      return Map<String, dynamic>.from(geoInfo);
    }
    if (path == '/context/weather' && method == 'GET') {
      return Map<String, dynamic>.from(weather);
    }

    // ========== AI 接口 ==========
    if (path == '/ai/generate/note' && method == 'POST') {
      return generateNote(body ?? {});
    }
    if (path == '/api/v1/ai/analyze/image' && method == 'POST') {
      return Map<String, dynamic>.from(analyzeImage);
    }
    if (path == '/api/v1/ai/analyze/audio' && method == 'POST') {
      return Map<String, dynamic>.from(analyzeAudio);
    }

    return null;
  }
}