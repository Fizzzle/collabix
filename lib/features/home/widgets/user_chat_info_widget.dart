import 'package:collabix/core/constants/app_colors.dart';
import 'package:collabix/core/ui/stable_accent_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

/// User chat info widget
class UserChatInfoWidget extends StatelessWidget {
  /// Name
  final String title;

  /// `Chat` or `Board` — от последней вкладки в разговоре
  final String category;

  /// Last message
  final String lastMessage;

  /// Time
  final String time;

  /// Group id — для цвета «буквы»
  final String groupId;

  /// Constructor
  const UserChatInfoWidget({
    required this.title,
    required this.category,
    required this.lastMessage,
    required this.time,
    required this.groupId,
    super.key,
  });

  String get _letter {
    final t = title.trim();
    if (t.isEmpty) return '?';
    return t[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final accent = accentColorFromStableId(groupId);
    final isBoard = category == 'Board';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.2),
            border: Border.all(color: accent, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            _letter,
            style: TextStyle(
              color: accent,
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'SpaceGrot',
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            spacing: 3.h,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isBoard)
                    Lottie.asset(
                      'assets/anim/board_menu_table.json',
                      width: 40.w,
                      height: 24.h,
                    )
                  else
                    Lottie.asset(
                      'assets/anim/chat_menu_table.json',
                      width: 40.w,
                      height: 24.h,
                    ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.upcomingMessageText,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          time,
          style: TextStyle(
            color: AppColors.upcomingMessageText,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}
