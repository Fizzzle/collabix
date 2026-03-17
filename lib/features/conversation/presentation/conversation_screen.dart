import 'package:collabix/core/constants/app_colors.dart';
import 'package:collabix/core/constants/app_const.dart';
import 'package:collabix/features/conversation/screens/chat/chat_screen.dart';
import 'package:collabix/features/conversation/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Chat screen
class ConversationScreen extends StatefulWidget {
  /// Conversation title
  final String conversationTitle;

  /// Constructor
  const ConversationScreen({required this.conversationTitle, super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final DraggableScrollableController _draggableScrollableController =
      DraggableScrollableController();

  int _activeTabIndex = 0;

  void _changeTab(int index) {
    setState(() => _activeTabIndex = index);

    if (index == 1) {
      ///  свернуть чат
      _draggableScrollableController.animateTo(
        AppConst.minChildSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      /// раскрыть чат
      _draggableScrollableController.animateTo(
        AppConst.maxChildSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.upcomingMessageText,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _CustomAppBar(conversationTitle: widget.conversationTitle),
      ),
      body: Stack(
        children: [
          ///  BOARD НА ФОНЕ
          const Positioned.fill(
            child: DashboardScreen(),
          ),

          /// CHAT PANEL
          ChatScreen(
            draggableScrollableController: _draggableScrollableController,
          ),

          /// Custom tab bar
          Positioned(
            top: 16.h,
            left: 0,
            right: 0,
            child: _CustomTabBar(
              activeIndex: _activeTabIndex,
              onTabChanged: _changeTab,
            ),
          ),
        ],
      ),
    );
  }
}

/// CUSTOM TAB BAR
class _CustomTabBar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTabChanged;

  const _CustomTabBar({
    required this.activeIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final titles = ['Chat', 'Board'];

    return Center(
      child: Container(
        width: 192.w,
        height: 45.h,
        decoration: BoxDecoration(
          color: const Color(0xFF18181B),
          borderRadius: BorderRadius.all(Radius.circular(22.r)),
        ),
        child: Row(
          children: List.generate(2, (index) {
            final isActive = activeIndex == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTabChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.borderColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    titles[index],
                    style: TextStyle(
                      color: isActive
                          ? (index == 0
                                ? AppColors.chatText
                                : AppColors.boardText)
                          : Colors.grey,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SpaceGrot',
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// CUSTOM APP BAR
class _CustomAppBar extends StatelessWidget {
  final String conversationTitle;

  const _CustomAppBar({required this.conversationTitle});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: AppColors.text),
      backgroundColor: AppColors.background,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 15.6.r,
            backgroundColor: AppColors.boardText,
            child: Center(
              child: Text(
                conversationTitle[0].toUpperCase(),
                style: TextStyle(
                  color: AppColors.background,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SpaceGrot',
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            conversationTitle,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'SpaceGrot',
            ),
          ),
        ],
      ),
    );
  }
}
