import 'package:collabix/core/constants/app_colors.dart';
import 'package:collabix/core/constants/app_const.dart';
import 'package:collabix/core/ui/stable_accent_color.dart';
import 'package:collabix/features/conversation/screens/chat/bloc/chat_bloc.dart';
import 'package:collabix/features/conversation/screens/chat/data/model/message_model.dart';
import 'package:collabix/features/conversation/screens/chat/domain/entity/message_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

String _senderInitial(MessageEntity message) {
  final name = message.senderName?.trim();
  if (name != null && name.isNotEmpty) {
    return name[0].toUpperCase();
  }
  if (message.senderId.isNotEmpty) {
    return message.senderId[0].toUpperCase();
  }
  return '?';
}

/// Chat panel (messages + input) for a group. [chatId] matches `Groups` doc id and `chats/{chatId}`.
class ChatScreen extends StatefulWidget {
  /// Constructor
  const ChatScreen({
    required this.chatId,
    required this.conversationTabIndex,
    required DraggableScrollableController draggableScrollableController,
    super.key,
  }) : _draggableScrollableController = draggableScrollableController;

  /// 0 = Chat (лист на максимуме, без ручного drag), 1 = Board (узкий диапазон, тянуть только вниз).
  final int conversationTabIndex;
  final String chatId;
  final DraggableScrollableController _draggableScrollableController;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;
  final TextEditingController _messageController = TextEditingController();
  late final ValueNotifier<double> _sheetExtent;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _sheetExtent = ValueNotifier<double>(
      widget.conversationTabIndex == 0
          ? AppConst.maxChildSize
          : AppConst.boardPeekChildSize,
    );
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversationTabIndex != widget.conversationTabIndex) {
      _sheetExtent.value = widget.conversationTabIndex == 0
          ? AppConst.maxChildSize
          : AppConst.boardPeekChildSize;
    }
  }

  void _startAnimationLoop() async {
    while (mounted) {
      await _lottieController.forward(from: 0.0);
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final messageId = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc()
        .id;

    final displayName = user.displayName?.trim();
    final email = user.email?.trim();
    final senderName = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (email ?? user.uid);

    context.read<ChatBloc>().add(
          SendMessageEvent(
            message: MessageModel(
              messageId: messageId,
              content: text,
              senderId: user.uid,
              receiverId: widget.chatId,
              chatId: widget.chatId,
              isRead: false,
              createdAt: DateTime.now(),
              senderName: senderName,
            ),
          ),
        );

    _messageController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _sheetExtent.dispose();
    _lottieController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final inputHeight = 60.h;
    final inputBottomOffset = 12.h;
    final inputSidePadding = 10.w;
    final inputBlockHeight = inputBottomOffset + inputHeight + bottomSafeArea;

    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    final isChatTab = widget.conversationTabIndex == 0;
    final sheetMin = isChatTab
        ? AppConst.maxChildSize
        : AppConst.boardMinChildSize;
    final sheetMax = isChatTab
        ? AppConst.maxChildSize
        : AppConst.boardPeekChildSize;

    /// Иначе при вкладке Board маленький `maxChildSize`, а initial большой → assert.
    final sheetInitial = sheetMax;

    /// Ручка всегда у верхнего края панели; отступ списка под неё.
    const sheetTopHandleHeight = 44.0;

    return DraggableScrollableSheet(
      controller: widget._draggableScrollableController,
      initialChildSize: sheetInitial,
      minChildSize: sheetMin,
      maxChildSize: sheetMax,
      snap: false,
      builder: (_, scrollController) {
        final listTopPad = sheetTopHandleHeight.h + 8.h;

        final listPhysics = isChatTab
            ? const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              )
            : const ClampingScrollPhysics();

        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (n) {
            if ((_sheetExtent.value - n.extent).abs() > 0.002) {
              _sheetExtent.value = n.extent;
            }
            return false;
          },
          child: ColoredBox(
            color: AppColors.borderColor,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatFailure) {
                      return ListView(
                        controller: scrollController,
                        physics: listPhysics,
                      padding: EdgeInsets.only(
                        top: listTopPad,
                        bottom: inputBlockHeight + 12.h,
                      ),
                      children: [
                        SizedBox(height: 24.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            state.message,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    );
                  }

                  final messages = state is ChatLoaded ? state.messages : null;
                  final showLoading =
                      state is ChatLoading || (state is ChatInitial);

                  if (showLoading && messages == null) {
                    return ListView(
                      controller: scrollController,
                      physics: listPhysics,
                      padding: EdgeInsets.only(
                        top: listTopPad,
                        bottom: inputBlockHeight + 12.h,
                      ),
                      children: [
                        SizedBox(height: 80.h),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    );
                  }

                  final list = messages ?? const <MessageEntity>[];

                  return ListView.builder(
                    controller: scrollController,
                    physics: listPhysics,
                    reverse: true,
                    padding: EdgeInsets.only(
                      left: 12.w,
                      right: 12.w,
                      top: listTopPad,
                      bottom: inputBlockHeight + 12.h,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final message = list[index];
                      final isMine =
                          currentUid != null && message.senderId == currentUid;

                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: _MessageRow(
                          message: message,
                          isMine: isMine,
                        ),
                      );
                    },
                  );
                },
              ),

              ValueListenableBuilder<double>(
                valueListenable: _sheetExtent,
                builder: (context, ext, _) {
                  final showFooter = isChatTab ||
                      ext > AppConst.sheetShowInputThreshold;
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: inputBlockHeight + 24.h,
                    child: IgnorePointer(
                      ignoring: !showFooter,
                      child: Opacity(
                        opacity: showFooter ? 1 : 0,
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
                  );
                },
              ),

              ValueListenableBuilder<double>(
                valueListenable: _sheetExtent,
                builder: (context, ext, _) {
                  final showFooter = isChatTab ||
                      ext > AppConst.sheetShowInputThreshold;
                  return Positioned(
                    left: inputSidePadding,
                    right: inputSidePadding,
                    bottom: inputBottomOffset,
                    child: IgnorePointer(
                      ignoring: !showFooter,
                      child: Opacity(
                        opacity: showFooter ? 1 : 0,
                        child: Container(
                          height: inputHeight,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundItemColor,
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                              color: AppColors.borderColor,
                              width: 2,
                            ),
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
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontSize: 16.sp,
                                  ),
                                  minLines: 1,
                                  maxLines: 4,
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) => _sendMessage(),
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
                                onPressed: _sendMessage,
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
                    ),
                  );
                },
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: isChatTab
                    ? IgnorePointer(
                        child: _SheetDragHandle(
                          height: sheetTopHandleHeight.h,
                          lottieController: _lottieController,
                          onLottieLoaded: _startAnimationLoop,
                        ),
                      )
                    : GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onVerticalDragUpdate: (d) {
                          final c = widget._draggableScrollableController;
                          if (!c.isAttached) return;
                          final h = MediaQuery.sizeOf(context).height;
                          if (h <= 0) return;
                          final next = (c.size - d.primaryDelta! / h).clamp(
                            AppConst.boardMinChildSize,
                            AppConst.boardPeekChildSize,
                          );
                          c.jumpTo(next);
                        },
                        child: Material(
                          color: Colors.transparent,
                          child: _SheetDragHandle(
                            height: sheetTopHandleHeight.h,
                            lottieController: _lottieController,
                            onLottieLoaded: _startAnimationLoop,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }
}

class _SheetDragHandle extends StatelessWidget {
  const _SheetDragHandle({
    required this.height,
    required this.lottieController,
    required this.onLottieLoaded,
  });

  final double height;
  final AnimationController lottieController;
  final void Function() onLottieLoaded;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Center(
        child: Lottie.asset(
          'assets/anim/icons/drawer_up.json',
          controller: lottieController,
          width: 72.w,
          height: 12.h,
          fit: BoxFit.contain,
          onLoaded: (composition) {
            lottieController.duration = composition.duration;
            onLottieLoaded();
          },
        ),
      ),
    );
  }
}

class _LetterAvatar extends StatelessWidget {
  const _LetterAvatar({
    required this.userId,
    required this.letter,
  });

  final String userId;
  final String letter;

  @override
  Widget build(BuildContext context) {
    final accent = accentColorFromStableId(userId);
    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.2),
        border: Border.all(color: accent, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: accent,
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'SpaceGrot',
        ),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({
    required this.message,
    required this.isMine,
  });

  final MessageEntity message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine
        ? AppColors.boardText.withValues(alpha: 0.35)
        : AppColors.backgroundItemColor;
    final align = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: 0.72.sw),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),
      child: Text(
        message.content,
        style: TextStyle(
          color: AppColors.text,
          fontSize: 15.sp,
          height: 1.35,
          fontFamily: 'SpaceGrot',
        ),
      ),
    );

    final avatar = _LetterAvatar(
      userId: message.senderId,
      letter: _senderInitial(message),
    );

    return Column(
      crossAxisAlignment: align,
      children: [
        Row(
          mainAxisAlignment:
              isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: isMine
              ? [bubble, SizedBox(width: 8.w), avatar]
              : [avatar, SizedBox(width: 8.w), bubble],
        ),
      ],
    );
  }
}
