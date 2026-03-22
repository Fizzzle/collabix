import 'package:collabix/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// User chat info widget
class UserChatInfoWidget extends StatelessWidget {
  /// Name
  final String title;

  /// Category
  final String category;

  /// Last message
  final String lastMessage;

  /// Time
  final String time;

  /// Constructor
  const UserChatInfoWidget({
    required this.title,
    required this.category,
    required this.lastMessage,
    required this.time,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ///Будут аватарки тех юзеров, с которыми идет чат
        Row(
          spacing: 10.w,
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundImage: const AssetImage('assets/images/ava.png'),
            ),
            Column(
              spacing: 5.h,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  spacing: 10.w,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: category == 'Board'
                            ? AppColors.boardText.withValues(alpha: 0.15)
                            : AppColors.chatText.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        spacing: 5.w,
                        children: [
                          Icon(
                            category == 'Board' ? Icons.dashboard : Icons.chat,
                            color: category == 'Board'
                                ? AppColors.boardText
                                : AppColors.chatText,
                            size: 13.sp,
                          ),
                          Text(
                            category,
                            style: TextStyle(
                              color: category == 'Board'
                                  ? AppColors.boardText
                                  : AppColors.chatText,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      lastMessage,
                      style: TextStyle(
                        color: AppColors.upcomingMessageText,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Align(
          alignment: Alignment.topRight,
          child: Text(
            time,
            style: TextStyle(
              color: AppColors.upcomingMessageText,
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }
}
