# CityTrace（城市足迹）

一款基于 **Flutter** 开发的移动端城市足迹记录应用，帮助你记录在城市中漫游的每一段旅程与精彩瞬间。

## 功能特性

- **足迹录制** — 实时 GPS 定位，记录行走轨迹，支持行程开始/结束控制
- **瞬间记录** — 在行程中插入照片、录音、文字标注、位置等多模态内容
- **行程管理** — 对行程进行 CRUD 操作，支持文件夹分类组织
- **AI 增强** — AI 生成游记、图片描述、音频转写
- **环境感知** — 自动获取当前位置的地理信息（城市、区）和天气

## 技术栈

| 类别 | 技术 |
|------|------|
| 框架 | Flutter (SDK ^3.10.3) |
| 状态管理 | GetX |
| 网络请求 | Dio |
| 地图 | flutter_map（高德瓦片） |
| 定位 | geolocator + latlong2 |
| 本地存储 | SharedPreferences |
| 序列化 | json_annotation + json_serializable |
| 多媒体 | image_picker / record / audioplayers |

## 架构概览

采用**分层架构**，自上而下分为四层：

```
┌────────────────────────────────────┐
│           页面层 (pages)            │
│  Home / Auth / Journey / Profile   │
├────────────────────────────────────┤
│         全局控制器 (controllers)     │
│  UserController / MapTraceController│
├────────────────────────────────────┤
│          服务层 (services)          │
│  Auth / Journey / AI / Context     │
├────────────────────────────────────┤
│      基础设施层 (core / models)      │
│  ApiClient / Utils / Models        │
└────────────────────────────────────┘
```

- **页面层**：每个页面模块采用 View + Controller 模式
- **全局控制器**：应用级单例，管理用户登录态和地图轨迹状态
- **服务层**：封装具体业务 API 调用
- **基础设施层**：网络客户端（Dio 封装）、工具类、数据模型

## 项目结构

```
lib/
├── main.dart                        # 应用入口
├── common/                          # 公共常量与配置
│   ├── routes/app_routes.dart       # 路由表定义
│   └── values/server.dart           # 服务器配置
├── components/                      # 可复用 UI 组件
│   └── map_view.dart                # 地图组件
├── controllers/                     # 全局控制器
│   ├── user_controller.dart         # 用户状态管理
│   └── map_trace_controller.dart    # 轨迹录制管理
├── core/                            # 基础设施层
│   ├── net/api_client.dart          # Dio HTTP 客户端
│   └── utils/                       # 工具类
│       ├── storage_util.dart        # 本地存储
│       ├── location_util.dart       # 定位工具
│       ├── permission_util.dart     # 权限管理
│       ├── media_util.dart          # 多媒体工具
│       ├── crypto_util.dart         # 密码加密
│       └── metadata_util.dart       # 应用元数据
├── models/                          # 数据模型
│   ├── user_model.dart
│   ├── journey_model.dart
│   ├── moment_model.dart
│   ├── folder_model.dart
│   └── context_model.dart
├── pages/                           # 页面层
│   ├── home/                        # 主页
│   ├── auth/                        # 登录/注册
│   ├── journey/                     # 行程详情与列表
│   ├── profile/                     # 个人主页
│   └── about/                       # 关于页面
├── services/                        # 业务服务层
│   ├── auth_service.dart
│   ├── ai_service.dart
│   ├── context_service.dart
│   └── journey_management/          # 行程管理服务
│       ├── journey_service.dart
│       ├── moment_service.dart
│       └── folder_service.dart
└── mock/                            # 模拟数据（开发环境）
    ├── mock_config.dart
    ├── mock_data.dart
    └── mock_interceptor.dart
```

## 快速开始

### 环境要求

- Flutter SDK ^3.10.3
- Dart SDK

### 安装运行

```bash
# 克隆项目
git clone https://github.com/Adam-code-line/CityTrace.git
cd CityTrace

# 安装依赖
flutter pub get

# 生成 JSON 序列化代码
flutter pub run build_runner build

# 运行应用
flutter run
```

## 开发环境

- 后端 API 使用 Apifox 模拟接口进行开发
- Mock 数据位于 `lib/mock/` 目录下，支持拦截器模式
- 详细架构文档见 `docs/项目架构文档.md`

## 路由列表

| 路径 | 页面 | 说明 |
|------|------|------|
| `/` | HomePage | 主页 |
| `/login` | LoginPage | 登录/注册 |
| `/journey` | JourneyDetailPage | 行程详情 |
| `/note` | NotePage | AI 游记 |
| `/list` | ListPage | 行程列表 |
| `/profile` | ProfilePage | 个人主页 |
| `/about` | AboutView | 关于页面 |

## License

MIT