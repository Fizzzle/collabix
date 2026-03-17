import 'package:collabix/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Chat screen
class ChatScreen extends StatelessWidget {
  /// Constructor
  const ChatScreen({
    required DraggableScrollableController draggableScrollableController,
    super.key,
  }) : _draggableScrollableController = draggableScrollableController;

  final DraggableScrollableController _draggableScrollableController;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _draggableScrollableController,
      initialChildSize: 1,
      minChildSize: 0,
      builder: (_, scrollController) {
        return ColoredBox(
          color: AppColors.background,
          child: ListView(
            controller: scrollController,
            children: [
              SizedBox(height: 10.h),

              /// Handle
              Center(
                child: SizedBox(
                  width: 40.w,
                  child: const Divider(
                    thickness: 4,
                    color: Colors.red,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              const Center(
                child: Text(
                  "Chat panel",
                  style: TextStyle(color: AppColors.text),
                ),
              ),

              SizedBox(height: 800.h),
            ],
          ),
        );
      },
    );
  }
}
