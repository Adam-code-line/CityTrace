import 'package:json_annotation/json_annotation.dart';

part 'context_model.g.dart';

/// 逆地理编码返回的地理位置信息
///
/// 通过经纬度反查得到的详细地址信息，包含国家、省、市、区级行政信息
/// 以及 POI（兴趣点）名称等。
@JsonSerializable()
class GeoLocationInfo {
  /// 国家，如 "中国"
  final String country;

  /// 省份，如 "上海市"
  final String province;

  /// 城市，如 "上海市"
  final String city;

  /// 区/县，如 "黄浦区"
  final String district;

  /// POI（兴趣点）名称，如 "人民广场"
  final String? name;

  /// 详细地址描述，如 "上海市黄浦区人民大道"
  final String? address;

  GeoLocationInfo({
    required this.country,
    required this.province,
    required this.city,
    required this.district,
    this.name,
    this.address,
  });
  factory GeoLocationInfo.fromJson(Map<String, dynamic> json) =>
      _$GeoLocationInfoFromJson(json);
}

/// 当前天气信息
///
/// 包含温度、天气状况描述和天气图标标识。
@JsonSerializable()
class WeatherInfo {
  /// 当前温度（摄氏度）
  final double temp;

  /// 天气状况描述，如 "多云"、"晴"
  final String condition;

  /// 天气图标标识符，用于 UI 显示对应图标
  final String? icon;

  WeatherInfo({required this.temp, required this.condition, this.icon});
  factory WeatherInfo.fromJson(Map<String, dynamic> json) =>
      _$WeatherInfoFromJson(json);
}
