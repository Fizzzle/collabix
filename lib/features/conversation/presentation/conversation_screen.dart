import 'dart:async';
import 'package:collabix/core/constants/app_colors.dart';
import 'package:collabix/core/constants/app_const.dart';
import 'package:collabix/features/conversation/screens/chat/chat_screen.dart';
import 'package:collabix/features/conversation/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

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
          const Positioned.fill(child: DashboardScreen()),

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

class _CustomTabBar extends StatefulWidget {
  final int activeIndex;
  final Function(int) onTabChanged;

  const _CustomTabBar({required this.activeIndex, required this.onTabChanged});

  @override
  State<_CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<_CustomTabBar>
    with TickerProviderStateMixin {
  late AnimationController _chatController;
  late AnimationController _boardController;
  Timer? _boardRepeatTimer;
  bool _chatLoaded = false;
  bool _boardLoaded = false;

  @override
  void initState() {
    super.initState();
    _chatController = AnimationController(vsync: this);
    _boardController = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(_CustomTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex) {
      _cancelBoardTimer();
      _cancelChatTimer();
      _playActiveAnimation(widget.activeIndex);
    }
  }

  void _playActiveAnimation(int index) {
    if (index == 0) {
      if (!_chatLoaded) return;
      _chatController.reset();
      _chatController.forward();
      _scheduleChatRepeat();
    } else {
      if (!_boardLoaded) return;
      _boardController.reset();
      _boardController.forward();
      _scheduleBoardRepeat();
    }
  }

  Timer? _chatRepeatTimer;

  void _scheduleChatRepeat() {
    _cancelChatTimer();
    _chatRepeatTimer = Timer(const Duration(seconds: 5), () {
      if (widget.activeIndex == 0 && mounted) {
        _chatController.reset();
        _chatController.forward();
        _scheduleChatRepeat();
      }
    });
  }

  void _cancelChatTimer() {
    _chatRepeatTimer?.cancel();
    _chatRepeatTimer = null;
  }

  void _scheduleBoardRepeat() {
    _cancelBoardTimer();
    _boardRepeatTimer = Timer(const Duration(seconds: 5), () {
      if (widget.activeIndex == 1 && mounted) {
        _boardController.reset();
        _boardController.forward();
        _scheduleBoardRepeat();
      }
    });
  }

  void _cancelBoardTimer() {
    _boardRepeatTimer?.cancel();
    _boardRepeatTimer = null;
  }

  @override
  void dispose() {
    _cancelBoardTimer();
    _cancelChatTimer();

    _chatController.dispose();
    _boardController.dispose();
    super.dispose();
  }

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
            final isActive = widget.activeIndex == index;
            final color = index == 0 ? AppColors.chatText : AppColors.boardText;
            final asset = index == 0
                ? 'assets/anim/icons/chat_icons.json'
                : 'assets/anim/icons/board_icons.json';
            final controller = index == 0 ? _chatController : _boardController;

            return Expanded(
              child: GestureDetector(
                onTap: () => widget.onTabChanged(index),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isActive) ...[
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [color, color],
                          ).createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: Lottie.asset(
                            asset,
                            controller: controller,
                            onLoaded: (composition) {
                              controller.duration = composition.duration;
                              if (index == 0) {
                                _chatLoaded = true;
                                if (widget.activeIndex == 0) {
                                  controller.reset();
                                  controller.forward();
                                }
                              } else {
                                _boardLoaded = true;
                                if (widget.activeIndex == 1) {
                                  controller.reset();
                                  controller.forward();
                                  _scheduleBoardRepeat();
                                }
                              }
                            },
                            width: 20.w,
                            height: 20.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: 4.w),
                      ],
                      Text(
                        titles[index],
                        style: TextStyle(
                          color: isActive ? color : Colors.grey,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SpaceGrot',
                        ),
                      ),
                    ],
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
