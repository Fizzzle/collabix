import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabix/core/constants/app_colors.dart';
import 'package:collabix/core/constants/app_const.dart';
import 'package:collabix/features/conversation/screens/chat/bloc/chat_bloc.dart';
import 'package:collabix/features/conversation/screens/chat/data/datasource/chat_remote_datasource.dart';
import 'package:collabix/features/conversation/screens/chat/data/repository/chat_repository_impl.dart';
import 'package:collabix/features/conversation/screens/chat/domain/usecase/delete_message_use_case.dart';
import 'package:collabix/features/conversation/screens/chat/domain/usecase/fetch_messages_by_chat.dart';
import 'package:collabix/features/conversation/screens/chat/domain/usecase/send_message_use_case.dart';
import 'package:collabix/features/conversation/screens/chat/domain/usecase/update_message_use_case.dart';
import 'package:collabix/features/conversation/screens/chat/presentation/chat_screen.dart';
import 'package:collabix/features/conversation/screens/dashboard/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

/// Chat screen
class ConversationScreen extends StatefulWidget {
  /// Firestore group id — same as `chats/{chatId}/messages` root.
  final String chatId;

  /// Conversation title
  final String conversationTitle;

  /// Constructor
  const ConversationScreen({
    required this.chatId,
    required this.conversationTitle,
    super.key,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final DraggableScrollableController _draggableScrollableController =
      DraggableScrollableController();

  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_restoreLastPanelAndSheet());
  }

  Future<void> _restoreLastPanelAndSheet() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _scheduleSheetJump(chatExpanded: true);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Groups')
          .doc(widget.chatId)
          .get();
      if (!mounted) return;
      final panel = (doc.data()?['lastPanel'] as String? ?? 'chat')
          .toLowerCase();
      final board = panel == 'board';
      setState(() => _activeTabIndex = board ? 1 : 0);
      _scheduleSheetJump(chatExpanded: !board);
    } catch (_) {
      if (!mounted) return;
      setState(() => _activeTabIndex = 0);
      _scheduleSheetJump(chatExpanded: true);
    }
  }

  void _scheduleSheetJump({required bool chatExpanded}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final c = _draggableScrollableController;
      if (!c.isAttached) return;
      c.jumpTo(
        chatExpanded ? AppConst.maxChildSize : AppConst.boardPeekChildSize,
      );
    });
  }

  void _changeTab(int index) {
    setState(() => _activeTabIndex = index);

    if (index == 1) {
      _draggableScrollableController.animateTo(
        AppConst.boardPeekChildSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _draggableScrollableController.animateTo(
        AppConst.maxChildSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      unawaited(
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('Groups')
            .doc(widget.chatId)
            .set({
              'lastPanel': index == 0 ? 'chat' : 'board',
            }, SetOptions(merge: true)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final chatRemote = ChatRemoteDataSourceImpl(firestore);
    final chatRepo = ChatRepositoryImpl(firestore, chatRemote);

    return BlocProvider(
      create: (_) => ChatBloc(
        SendMessageUseCase(chatRepo),
        FetchMessagesByChatUseCase(chatRepo),
        DeleteMessageUseCase(chatRepo),
        UpdateMessageUseCase(chatRepo),
      )..add(FetchMessagesByChatEvent(chatId: widget.chatId)),
      child: Scaffold(
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
              chatId: widget.chatId,
              conversationTabIndex: _activeTabIndex,
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
                conversationTitle.isNotEmpty
                    ? conversationTitle[0].toUpperCase()
                    : '?',
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
          Expanded(
            child: Text(
              conversationTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'SpaceGrot',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
