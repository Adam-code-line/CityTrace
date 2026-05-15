import 'package:citytrace/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatelessWidget {
  final List<LatLng> points;
  final LatLng? center;

  const MapView({super.key, this.points = const [], this.center});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center ?? const LatLng(39.909, 116.397), // 默认天安门
        initialZoom: 15,
        maxZoom: 18,
        minZoom: 3,
      ),
      children: [
        // 加载瓦片图层
        TileLayer(
          urlTemplate:
              'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
          subdomains: const ['1', '2', '3', '4'],
        ),

        // 绘制轨迹线
        PolylineLayer(
          polylines: [
            if (points.isNotEmpty)
              Polyline(
                points: points,
                color: AppColors.primary,
                strokeWidth: 5,
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              ),
          ],
        ),

        // 绘制当前位置标记 (Marker)
        if (center != null)
          MarkerLayer(
            markers: [
              Marker(
                point: center!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_history,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
