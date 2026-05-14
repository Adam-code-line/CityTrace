import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../models/journey_model.dart';
import '../models/folder_model.dart';

/// 可右滑归类的行程卡片（视差效果：封面图=背景层，遮罩+日期=前景层）
class SwipeableJourneyCard extends StatefulWidget {
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
  State<SwipeableJourneyCard> createState() => _SwipeableJourneyCardState();
}

class _SwipeableJourneyCardState extends State<SwipeableJourneyCard>
    with SingleTickerProviderStateMixin {
  double _dragX = 0;

  static const double _maxDragWidth = 100;
  static const double _triggerThreshold = 60;

  @override
  Widget build(BuildContext context) {
    final journey = widget.journey;
    final hasFolder = journey.folderId != null;

    // 视差偏移
    final bgOffset = -_dragX * 0.5;
    final fgOffset = _dragX * 0.9;

    // 提示进度
    final hintProgress = (_dragX / _maxDragWidth).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragX = (_dragX + details.delta.dx).clamp(0, _maxDragWidth);
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragX >= _triggerThreshold) {
          widget.onSwipeClassify();
        }
        setState(() => _dragX = 0);
      },
      child: Container(
        // 固定高度 = 160(封面) + padding*2 + title + folderTag + 底部提示 ≈ 320
        height: 320.h,
        margin: EdgeInsets.only(bottom: 20.h),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 背景层：卡片左侧的归类提示（在卡片外部，随卡片右滑而露出）
            if (hintProgress > 0)
              Positioned(
                left: -50.w + _dragX * 0.3, // 跟随卡片缓慢移动
                top: 0,
                bottom: 80,
                child: Opacity(
                  opacity: hintProgress,
                  child: Container(
                    width: 80.w,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 12.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasFolder
                              ? Icons.replay_outlined
                              : Icons.folder_outlined,
                          size: 24.r,
                          color: Color.lerp(
                            Colors.grey.shade400,
                            Colors.black87,
                            hintProgress,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          hasFolder ? "重新归类" : "归类",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Color.lerp(
                              Colors.grey.shade400,
                              Colors.black87,
                              hintProgress,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 前景层：可滑动的卡片
            AnimatedContainer(
              duration: const Duration(milliseconds: 30),
              transform: Matrix4.translationValues(_dragX, 0, 0),
              width: 411.4.w,
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
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildParallaxCover(journey, bgOffset, fgOffset),
                  _buildInfoSection(journey, hasFolder),
                  _buildSwipeHint(hasFolder),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParallaxCover(
      JourneyModel journey, double bgOffset, double fgOffset) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      child: SizedBox(
        height: 160.h,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned(
              left: bgOffset,
              top: 0,
              bottom: 0,
              child: Image.network(
                journey.cover,
                height: 160.h,
                width: 411.4.w,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: Colors.teal.shade100,
                  height: 160.h,
                  width: 411.4.w,
                ),
              ),
            ),
            Positioned(
              left: fgOffset,
              right: 0,
              bottom: 0,
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: EdgeInsets.all(12.r),
                alignment: Alignment.bottomLeft,
                child: Text(
                  journey.startTime.split('T')[0],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(JourneyModel journey, bool hasFolder) {
    String? folderName;
    if (hasFolder && journey.folderId != null) {
      final folder = widget.folders.firstWhereOrNull(
        (f) => f.folderId == journey.folderId,
      );
      folderName = folder?.name;
    }

    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  journey.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            ],
          ),
          SizedBox(height: 4.h),
          if (folderName != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 2.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF009688).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                folderName,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFF009688),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSwipeHint(bool hasFolder) {
    return Container(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swipe, size: 14.r, color: Colors.grey.shade300),
          SizedBox(width: 4.w),
          Text(
            hasFolder ? "右滑重新归类" : "右滑归类到文件夹",
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey.shade300,
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