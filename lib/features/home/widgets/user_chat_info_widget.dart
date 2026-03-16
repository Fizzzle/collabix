import 'package:collabix/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

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
          spacing: 10,
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/ava.png'),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  spacing: 10,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: category == 'Board'
                            ? AppColors.boardText.withValues(alpha: 0.15)
                            : AppColors.chatText.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          Icon(
                            category == 'Board' ? Icons.dashboard : Icons.chat,
                            color: category == 'Board'
                                ? AppColors.boardText
                                : AppColors.chatText,
                            size: 15,
                          ),
                          Text(
                            category,
                            style: TextStyle(
                              color: category == 'Board'
                                  ? AppColors.boardText
                                  : AppColors.chatText,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      lastMessage,
                      style: const TextStyle(
                        color: AppColors.upcomingMessageText,
                        fontSize: 14,
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
            style: const TextStyle(
              color: AppColors.upcomingMessageText,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
