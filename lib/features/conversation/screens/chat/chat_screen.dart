import 'package:collabix/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

/// Chat screen
class ChatScreen extends StatefulWidget {
  /// Constructor
  const ChatScreen({
    required DraggableScrollableController draggableScrollableController,
    super.key,
  }) : _draggableScrollableController = draggableScrollableController;

  final DraggableScrollableController _draggableScrollableController;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  void _startAnimationLoop() async {
    while (mounted) {
      await _controller.forward(from: 0.0);
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final inputHeight = 60.h;
    final inputBottomOffset = 12.h;
    final inputSidePadding = 10.w;
    final inputBlockHeight = inputBottomOffset + inputHeight + bottomSafeArea;

    return DraggableScrollableSheet(
      controller: widget._draggableScrollableController,
      initialChildSize: 0.6,
      minChildSize: 0.2,
      builder: (_, scrollController) {
        return ColoredBox(
          color: AppColors.borderColor,
          child: Stack(
            children: [
              /// MESSAGES
              ListView(
                controller: scrollController,
                padding: EdgeInsets.only(bottom: inputBlockHeight + 12.h),
                children: [
                  SizedBox(height: 10.h),

                  /// DRAG HANDLE
                  Center(
                    child: Lottie.asset(
                      'assets/anim/icons/drawer_up.json',
                      controller: _controller,
                      width: 80.w,
                      height: 8.w,
                      onLoaded: (composition) {
                        _controller.duration = composition.duration;
                        _startAnimationLoop();
                      },
                    ),
                    // Container(
                    //   width: 40.w,
                    //   height: 4.h,
                    //   decoration: BoxDecoration(
                    //     color: Colors.grey,
                    //     borderRadius: BorderRadius.circular(10),
                    //   ),
                    // ),
                  ),

                  SizedBox(height: 10.h),
                ],
              ),

              /// FADE (сообщения под input приглушены как в TG)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: inputBlockHeight + 24.h,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.background.withValues(alpha: 0.95),
                          AppColors.background.withValues(alpha: 0.75),
                          AppColors.background.withValues(alpha: 0.35),
                          AppColors.background.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.35, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              /// INPUT (поверх)
              Positioned(
                left: inputSidePadding,
                right: inputSidePadding,
                bottom: inputBottomOffset,
                child: Container(
                  height: inputHeight,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundItemColor,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: AppColors.borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 12.w),

                      Icon(
                        Icons.message,
                        color: AppColors.upcomingMessageText,
                        size: 20.sp,
                      ),

                      SizedBox(width: 8.w),

                      /// TEXT FIELD
                      Expanded(
                        child: TextFormField(
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 16.sp,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Message',
                            hintStyle: TextStyle(
                              color: AppColors.upcomingMessageText,
                              fontSize: 16.sp,
                            ),
                            isCollapsed: true,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () => FocusScope.of(context).unfocus(),
                        icon: Icon(
                          Icons.send,
                          color: AppColors.upcomingMessageText,
                          size: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
