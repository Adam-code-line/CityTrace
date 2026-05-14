import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/journey_model.dart';
import '../models/folder_model.dart';

/// 可右滑归类的行程卡片组件
class SwipeableJourneyCard extends StatelessWidget {
  final JourneyModel journey;
  final List<FolderModel> folders;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onSwipeClassify;

  const SwipeableJourneyCard({
    super.key,
    required this.journey,
    required this.folders,
    required this.onTap,
    required this.onLongPress,
    required this.onSwipeClassify,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          // 右滑时露出的底层操作区
          _buildSlideAction(journey),
          // 上层卡片（通过 Dismissible 实现右滑效果）
          Dismissible(
            key: ValueKey('swipe_${journey.journeyId}'),
            direction: DismissDirection.startToEnd,
            confirmDismiss: (direction) async {
              onSwipeClassify();
              return false; // 不移除卡片
            },
            background: const SizedBox.shrink(),
            child: _JourneyCardContent(
              journey: journey,
              folders: folders,
            ),
          ),
        ],
      ),
    );
  }

  /// 右滑时露出的操作提示区
  Widget _buildSlideAction(JourneyModel journey) {
    final currentFolderIds = journey.getAllFolderIds();
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 160.w,
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: const Color(0xFF009688),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            bottomLeft: Radius.circular(20.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              currentFolderIds.isNotEmpty
                  ? Icons.replay_outlined
                  : Icons.folder_outlined,
              color: Colors.white,
              size: 24.r,
            ),
            SizedBox(width: 8.w),
            Text(
              currentFolderIds.isNotEmpty ? "重新归类" : "归类",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 卡片内容（纯展示）
class _JourneyCardContent extends StatelessWidget {
  final JourneyModel journey;
  final List<FolderModel> folders;

  const _JourneyCardContent({
    required this.journey,
    required this.folders,
  });

  @override
  Widget build(BuildContext context) {
    final currentFolderIds = journey.getAllFolderIds();
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // 卡片上半部分：路径缩略图或头图
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            child: Image.network(
              journey.cover,
              height: 160.h,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) =>
                  Container(color: Colors.teal.shade100, height: 160.h),
            ),
          ),
          // 卡片下半部分：信息
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        journey.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      journey.startTime.split('T')[0],
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                    if (currentFolderIds.isNotEmpty) ...[
                      SizedBox(width: 12.w),
                      // 显示已归类标记
                      ...currentFolderIds.take(2).map((fid) {
                        final folder = folders.firstWhereOrNull(
                          (f) => f.folderId == fid,
                        );
                        if (folder == null) return const SizedBox.shrink();
                        return Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF009688).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              folder.name,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: const Color(0xFF009688),
                              ),
                            ),
                          ),
                        );
                      }),
                      if (currentFolderIds.length > 2)
                        Text(
                          "+${currentFolderIds.length - 2}",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // 底部：右滑提示
          Container(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swipe,
                  size: 14.r,
                  color: Colors.grey.shade300,
                ),
                SizedBox(width: 4.w),
                Text(
                  currentFolderIds.isNotEmpty ? "右滑重新归类" : "右滑归类到文件夹",
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 空白状态
class EmptyJourneyState extends StatelessWidget {
  const EmptyJourneyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 80.r, color: Colors.grey.shade200),
          SizedBox(height: 16.h),
          const Text("这里空空如也，快去开启一段旅程吧",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}