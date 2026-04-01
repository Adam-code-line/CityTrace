import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/map_view.dart';
import '../../core/utils/media_util.dart';
import '../../core/utils/permission_util.dart';
import '../../models/moment_model.dart';
import 'journey_detail_controller.dart';

part 'journey_moment_widgets.dart';

class JourneyDetailPage extends StatelessWidget {
  const JourneyDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JourneyDetailController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          slivers: [
            _buildAppBar(), // Header
            SliverToBoxAdapter(child: _buildSummaryCard()), // 概览卡片
            _buildTimelineList(), // 时间轴
            SliverToBoxAdapter(child: SizedBox(height: 120.h)),
          ],
        );
      }),
      floatingActionButton: _buildSpeedDialFab(context), // 快速操作菜单悬浮按钮
    );
  }

  Widget _buildAppBar() {
    JourneyDetailController controller = Get.find<JourneyDetailController>();
    return SliverAppBar(
      expandedHeight: 240.h,
      pinned: true,
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: const Color(0xFF009688),
      flexibleSpace: FlexibleSpaceBar(
        title: Obx(
          () => Text(
            controller.journey.value?.title ?? "行程详情",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              // 添加微弱阴影增强在浅色背景图上的辨识度
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 8.r,
                  offset: Offset(0, 1.h),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        titlePadding: EdgeInsets.only(bottom: 16.h),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: "journey_cover_${controller.journeyId}", // 与入口 tag 保持一致
              child: Obx(
                () => Image.network(
                  controller.journey.value?.cover ?? "",
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Container(color: const Color(0xFF80CBC4)),
                ),
              ),
            ),
            // 添加阴影让顶部的返回键和底部的标题在任何底图下都清晰
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black38, // 顶部暗色，保护返回键
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black45, // 底部暗色，保护标题
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (controller.isEnded) // 当行程结束则显示生成入口
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => controller.goToNotePage(),
          ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    JourneyDetailController controller = Get.find<JourneyDetailController>();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        // 使用更柔和的阴影，让卡片有浮起感
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: const Color(0xFF009688).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.map_outlined, color: Color(0xFF009688), size: 32.r),
              ],
            ),
          ),
          SizedBox(width: 20.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Obx(
                      () => _buildStatItem(controller.displayDuration, "累计时长"),
                    ),
                    SizedBox(width: 48.w),
                    Obx(
                      () => _buildStatItem(
                        "${controller.moments.length}",
                        "捕捉瞬间",
                      ),
                    ),
                  ],
                ),
                Divider(height: 24.h),
                Row(
                  children: [
                    Icon(
                      Icons.push_pin_outlined,
                      size: 14.r,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        controller.journey.value?.startTime.split('T')[0] ??
                            "未知时间",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace', // 时间保持等宽
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTimelineList() {
    JourneyDetailController controller = Get.find<JourneyDetailController>();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildTimelineItem(
          controller.moments[index],
          index == controller.moments.length - 1,
        ),
        childCount: controller.moments.length,
      ),
    );
  }

  Widget _buildTimelineItem(MomentModel moment, bool isLast) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: IntrinsicHeight(
        // 让 Row 的高度由内容最高的子组件决定
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, // 让轴线拉满整个高度，保证无缝连接
          children: [
            // 左侧：轴线和节点
            SizedBox(
              width: 40.w,
              child: Column(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFF009688),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconByType(moment.type),
                      color: Colors.white,
                      size: 16.r,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 2.w, color: Colors.grey.shade200),
                    ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            // 右侧：内容卡片
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 32.h), // 瞬间之间的间距
                child: _buildMomentContentCard(moment),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconByType(String type) {
    IconData icon = Icons.notes;
    switch (type) {
      case "image":
        icon = Icons.camera_alt;
        break;
      case "audio":
        icon = Icons.mic;
        break;
      case "text":
        icon = Icons.edit;
        break;
      case "location":
        icon = Icons.location_on;
        break;
    }
    return icon;
  }

  Widget _buildMomentContentCard(MomentModel moment) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题行
          if (moment.title != null && moment.title!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                moment.title!,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
              ),
            ),

          // 核心内容区域
          MomentCard.buildTypedContent(moment),

          SizedBox(height: 12.h),

          // 标签 + 地点 + 时间
          _buildMomentFooter(moment),
        ],
      ),
    );
  }

  Widget _buildMomentFooter(MomentModel moment) {
    final bool hasTags = moment.tags != null && moment.tags!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签行
        if (hasTags) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: moment.tags!
                  .map(
                    (tag) => Container(
                      margin: EdgeInsets.only(right: 8.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF009688).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        "#$tag",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Color(0xFF009688),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(height: 12.h),
          Divider(height: 1.h, thickness: 0.5), // 有标签时，用线分割
          SizedBox(height: 10.h),
        ] else ...[
          SizedBox(height: 16.h),
        ],

        // 底部地点+时间
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: moment.type == "location"
                  ? const SizedBox()
                  : Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12.r,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            moment.location.name ?? "未知地点",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
            Text(
              moment.time.split('T').last.substring(0, 5),
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade400,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpeedDialFab(BuildContext context) {
    JourneyDetailController controller = Get.find<JourneyDetailController>();
    return Obx(() {
      if (controller.isEnded) return SizedBox.shrink();
      return SpeedDial(
        heroTag: "journey_fab",
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: const Color(0xFF009688),
        foregroundColor: Colors.white,
        visible: true,
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.stop),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: CircleBorder(),
            label: '结束行程',
            onTap: () => _showEndJourneyConfirm(),
          ),
          SpeedDialChild(
            child: const Icon(Icons.mic),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: CircleBorder(),
            label: '录音感悟',
            onTap: () => MomentBottomSheet.showAudioRecorder(controller),
          ),
          SpeedDialChild(
            child: const Icon(Icons.camera_alt),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: CircleBorder(),
            label: '拍照记录',
            onTap: () => MomentBottomSheet.showImagePicker(controller),
          ),
          SpeedDialChild(
            child: const Icon(Icons.edit),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            shape: CircleBorder(),
            label: '手写日志',
            onTap: () => MomentBottomSheet.showTextEditor(controller),
          ),
          SpeedDialChild(
            child: const Icon(Icons.location_on),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: CircleBorder(),
            label: '添加标记',
            onTap: () => MomentBottomSheet.showLocationMarker(controller),
          ),
        ],
      );
    });
  }

  void _showEndJourneyConfirm() {
    JourneyDetailController controller = Get.find<JourneyDetailController>();
    Get.defaultDialog(
      title: "提示",
      middleText: "确定要结束本次城市寻迹吗？",
      textConfirm: "确定",
      textCancel: "取消",
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF009688),
      onConfirm: () {
        controller.onEndJourney();
        Get.back(); // 关弹窗
      },
    );
  }
}
