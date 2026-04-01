import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'note_controller.dart';

class NotePage extends StatelessWidget {
  const NotePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NoteController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "AI 寻迹成书",
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "选择生成风格",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),

            // 风格选择网格
            _buildStyleGrid(controller),

            // 自定义提示词输入框
            Obx(
              () => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: controller.selectedStyle.value == "custom"
                    ? Padding(
                        padding: EdgeInsets.only(top: 20.h),
                        child: TextField(
                          onChanged: (value) =>
                              controller.customPrompt.value = value,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "在这里输入您的风格需求吧...",
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: Color(0xFF009688),
                              ),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),

            SizedBox(height: 32.r),

            // 生成按钮
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isGenerating.value
                      ? null
                      : () => controller.startGenerating(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: controller.isGenerating.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "开始创作",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),

            SizedBox(height: 40.h),

            // 结果展示区域
            Obx(() {
              if (controller.generatedBody.isEmpty &&
                  !controller.isGenerating.value) {
                return _buildEmptyState();
              }
              return _buildResultCard(controller);
            }),
          ],
        ),
      ),
    );
  }

  // 风格选择小组件
  Widget _buildStyleGrid(NoteController controller) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.w,
        childAspectRatio: 2.2,
      ),
      itemCount: controller.styleOptions.length,
      itemBuilder: (context, index) {
        final style = controller.styleOptions[index];
        return Obx(() {
          bool isSelected = controller.selectedStyle.value == style['id'];
          return GestureDetector(
            onTap: () => controller.selectedStyle.value = style['id']!,
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF009688).withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF009688)
                      : Colors.transparent,
                  width: 2.w,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style['name']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF009688)
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    style['desc']!,
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildResultCard(NoteController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF009688), size: 20.r),
            SizedBox(width: 8.w),
            Text(
              "生成结果",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题部分
                controller.isEditing.value
                    ? TextField(
                        controller: controller.titleEditController,
                        maxLines: null,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "输入标题",
                        ),
                      )
                    : Text(
                        controller.generatedTitle.value,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                Divider(height: 32.h),
                // 正文部分
                controller.isEditing.value
                    ? TextField(
                        controller: controller.bodyEditController,
                        maxLines: null,
                        style: TextStyle(fontSize: 15.sp, height: 1.6),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "输入内容",
                        ),
                      )
                    : Text(
                        controller.generatedBody.value,
                        style: TextStyle(fontSize: 15.sp, height: 1.6),
                      ),
                SizedBox(height: 20.h),
                // 标签部分
                Wrap(
                  spacing: 8.w,
                  children: controller.hashtags
                      .map(
                        (t) => Text(
                          "#$t",
                          style: const TextStyle(color: Color(0xFF009688)),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (controller.isEditing.value) {
                      controller.saveEdits();
                    } else {
                      controller.enterEditMode();
                    }
                  },
                  child: Text(
                    controller.isEditing.value ? "保存修改" : "手动修改",
                    style: TextStyle(color: const Color(0xFF009688)),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.shareToClipboard(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                  ),
                  child: const Text(
                    "分享足迹",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.edit_note, size: 64.r, color: Colors.grey.shade200),
          const Text(
            "选个风格，让 AI 帮您回忆这段旅程吧",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
