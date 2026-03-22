import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'dashboard_screen.dart';

class StickerDetailScreen extends StatefulWidget {
  final StickerModel sticker;
  final void Function(StickerModel) onUpdate;
  final void Function(String id, StickerColor newColor)? onColorChange;

  const StickerDetailScreen({
    super.key,
    required this.sticker,
    required this.onUpdate,
    this.onColorChange,
  });

  @override
  State<StickerDetailScreen> createState() => _StickerDetailScreenState();
}

enum StickerStatus { todo, inProgress, done }

extension _StickerStatusFromColor on StickerColor {
  StickerStatus get status {
    switch (this) {
      case StickerColor.green:
        return StickerStatus.todo;
      case StickerColor.cyan:
        return StickerStatus.inProgress;
      case StickerColor.purple:
        return StickerStatus.done;
    }
  }
}

extension _StickerColorFromStatus on StickerStatus {
  StickerColor get color {
    switch (this) {
      case StickerStatus.todo:
        return StickerColor.green;
      case StickerStatus.inProgress:
        return StickerColor.cyan;
      case StickerStatus.done:
        return StickerColor.purple;
    }
  }
}

class _StickerDetailScreenState extends State<StickerDetailScreen>
    with TickerProviderStateMixin {
  late TextEditingController _descCtrl;
  late TextEditingController _commentCtrl;
  late TextEditingController _tagCtrl;

  StickerStatus get _status => widget.sticker.stickerColor.status;

  final List<String> _tags = [];
  final List<_ReactionModel> _reactions = [
    _ReactionModel(emoji: '👍', count: 3),
    _ReactionModel(emoji: '🔥', count: 1),
  ];
  final List<_CommentModel> _comments = [];

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  late AnimationController _lottieCtrlTodo;
  late AnimationController _lottieCtrlProgress;
  late AnimationController _lottieCtrlDone;

  late DateTime _createdAt;
  bool _tagEditMode = false;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.sticker.title);
    _commentCtrl = TextEditingController();
    _tagCtrl = TextEditingController();
    _createdAt = widget.sticker.createdAt;

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward();

    const dur = Duration(milliseconds: 800);
    _lottieCtrlTodo = AnimationController(vsync: this, duration: dur);
    _lottieCtrlProgress = AnimationController(vsync: this, duration: dur);
    _lottieCtrlDone = AnimationController(vsync: this, duration: dur);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controllerFor(_status).value = 1.0;
    });
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _commentCtrl.dispose();
    _tagCtrl.dispose();
    _slideCtrl.dispose();
    _lottieCtrlTodo.dispose();
    _lottieCtrlProgress.dispose();
    _lottieCtrlDone.dispose();
    super.dispose();
  }

  AnimationController _controllerFor(StickerStatus s) {
    switch (s) {
      case StickerStatus.todo:
        return _lottieCtrlTodo;
      case StickerStatus.inProgress:
        return _lottieCtrlProgress;
      case StickerStatus.done:
        return _lottieCtrlDone;
    }
  }

  Color get _statusColor {
    switch (_status) {
      case StickerStatus.todo:
        return DashBoardColor.stickerGreen;
      case StickerStatus.inProgress:
        return DashBoardColor.stickerCyan;
      case StickerStatus.done:
        return DashBoardColor.stickerPurple;
    }
  }

  void _setStatus(StickerStatus s) {
    if (_status == s) return;
    HapticFeedback.lightImpact();

    _controllerFor(_status).reverse();
    _controllerFor(s)
      ..reset()
      ..forward();

    widget.onColorChange?.call(widget.sticker.id, s.color);
    setState(() => widget.sticker.stickerColor = s.color);
    widget.onUpdate(widget.sticker);
  }

  void _toggleReaction(String emoji) {
    HapticFeedback.lightImpact();
    setState(() {
      final idx = _reactions.indexWhere((r) => r.emoji == emoji);
      if (idx < 0) return;
      final r = _reactions[idx];
      if (r.reacted) {
        r.count = math.max(0, r.count - 1);
        r.reacted = false;
      } else {
        r.count++;
        r.reacted = true;
      }
    });
  }

  void _addNewReaction(String emoji) {
    setState(() {
      final idx = _reactions.indexWhere((r) => r.emoji == emoji);
      if (idx >= 0) {
        if (!_reactions[idx].reacted) {
          _reactions[idx].count++;
          _reactions[idx].reacted = true;
        }
      } else {
        _reactions.add(_ReactionModel(emoji: emoji, count: 1, reacted: true));
      }
    });
  }

  void _addComment() {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() {
      _comments.add(
        _CommentModel(text: _commentCtrl.text.trim(), time: DateTime.now()),
      );
      _commentCtrl.clear();
    });
  }

  void _addTag(String tag) {
    final t = tag.trim();
    if (t.isEmpty) return;
    final formatted = t.startsWith('#') ? t : '#$t';
    setState(() => _tags.add(formatted));
    _tagCtrl.clear();
  }

  void _removeTag(String tag) {
    HapticFeedback.mediumImpact();
    setState(() => _tags.remove(tag));
  }

  void _reorderTag(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _tags.removeAt(oldIndex);
      _tags.insert(newIndex, item);
    });
  }

  void _saveAndPop() {
    widget.sticker.title = _descCtrl.text.trim().isNotEmpty
        ? _descCtrl.text.trim()
        : widget.sticker.title;
    widget.onUpdate(widget.sticker);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_tagEditMode) setState(() => _tagEditMode = false);
      },
      child: Scaffold(
        backgroundColor: DashBoardColor.bg,
        body: SlideTransition(
          position: _slideAnim,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),
                      _buildStatusRow(),
                      SizedBox(height: 28.h),
                      _buildDateRow(),
                      SizedBox(height: 28.h),
                      _buildTags(),
                      SizedBox(height: 28.h),
                      _buildDescription(),
                      SizedBox(height: 28.h),
                      _buildReactions(),
                      SizedBox(height: 12.h),
                      _buildComments(),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
              _buildCommentBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 52.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: DashBoardColor.bg,
        border: Border(bottom: BorderSide(color: DashBoardColor.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _saveAndPop,
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: DashBoardColor.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: DashBoardColor.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: DashBoardColor.text,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: DashBoardColor.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: DashBoardColor.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sticky_note_2_rounded,
                      size: 14.sp,
                      color: _statusColor,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'IDEA',
                      style: TextStyle(
                        color: DashBoardColor.text,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'SpaceGrot',
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    final statuses = [
      (
        StickerStatus.todo,
        'TO DO',
        Icons.radio_button_unchecked_rounded,
        DashBoardColor.stickerGreen,
        _lottieCtrlTodo,
      ),
      (
        StickerStatus.inProgress,
        'IN PROGRESS',
        Icons.timelapse_rounded,
        DashBoardColor.stickerCyan,
        _lottieCtrlProgress,
      ),
      (
        StickerStatus.done,
        'DONE',
        Icons.check_circle_outline_rounded,
        DashBoardColor.stickerPurple,
        _lottieCtrlDone,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('STATUS'),
        SizedBox(height: 10.h),
        Row(
          children: statuses.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: i < statuses.length - 1 ? 8.w : 0,
                ),
                child: _StatusButton(
                  isActive: _status == s.$1,
                  color: s.$4,
                  icon: s.$3,
                  label: s.$2,
                  lottieCtrl: s.$5,
                  onTap: () => _setStatus(s.$1),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('CREATED'),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: DashBoardColor.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: DashBoardColor.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14.sp,
                color: DashBoardColor.stickerCyan,
              ),
              SizedBox(width: 8.w),
              Text(
                '${_createdAt.day} ${_monthName(_createdAt.month)}, ${_createdAt.year}',
                style: TextStyle(
                  color: DashBoardColor.text,
                  fontSize: 13.sp,
                  fontFamily: 'SpaceGrot',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('TAGS'),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: () {},
          child: _tagEditMode ? _buildTagsEditMode() : _buildTagsNormalMode(),
        ),
      ],
    );
  }

  Widget _buildTagsNormalMode() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        ..._tags.map(
          (t) => GestureDetector(
            onLongPress: () {
              HapticFeedback.mediumImpact();
              setState(() => _tagEditMode = true);
            },
            child: _buildTagChip(t, editMode: false),
          ),
        ),
        GestureDetector(
          onTap: _showAddTagDialog,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: DashBoardColor.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  size: 14.sp,
                  color: DashBoardColor.textMuted,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Add Tag',
                  style: TextStyle(
                    color: DashBoardColor.textMuted,
                    fontSize: 12.sp,
                    fontFamily: 'SpaceGrot',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsEditMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Text(
            'Hold & drag to reorder  •  Tap ✕ to remove  •  Tap outside to finish',
            style: TextStyle(
              color: DashBoardColor.textMuted,
              fontSize: 10.sp,
              fontFamily: 'SpaceGrot',
            ),
          ),
        ),
        ReorderableWrap(
          tags: _tags,
          onRemove: _removeTag,
          onReorder: _reorderTag,
          buildTagChip: (tag) => _buildTagChip(tag, editMode: true),
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag, {required bool editMode}) {
    final colors = [
      DashBoardColor.stickerPurple,
      DashBoardColor.stickerCyan,
      DashBoardColor.stickerGreen,
    ];
    final color = colors[tag.length % colors.length];

    if (!editMode) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: color,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'SpaceGrot',
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(right: 8.w, bottom: 8.h),
      padding: EdgeInsets.only(left: 14.w, right: 6.w, top: 8.h, bottom: 8.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.6), width: 1.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'SpaceGrot',
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: Container(
              width: 18.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 11.sp, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('DESCRIPTION'),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: DashBoardColor.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: DashBoardColor.border),
          ),
          child: TextField(
            controller: _descCtrl,
            maxLines: 5,
            style: TextStyle(
              color: DashBoardColor.text,
              fontSize: 14.sp,
              fontFamily: 'SpaceGrot',
              height: 1.6,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(16.w),
              border: InputBorder.none,
              hintText: 'Add a description…',
              hintStyle: TextStyle(
                color: DashBoardColor.textMuted,
                fontSize: 14.sp,
                fontFamily: 'SpaceGrot',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReactions() {
    final emojis = ['👍', '🔥', '❤️', '😮', '🎉'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('REACTIONS'),
        SizedBox(height: 10.h),
        Row(
          children: [
            ..._reactions.map(
              (r) => GestureDetector(
                onTap: () => _toggleReaction(r.emoji),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: r.reacted
                        ? DashBoardColor.stickerGreen.withOpacity(0.15)
                        : DashBoardColor.surface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: r.reacted
                          ? DashBoardColor.stickerGreen.withOpacity(0.6)
                          : DashBoardColor.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(r.emoji, style: TextStyle(fontSize: 16.sp)),
                      SizedBox(width: 4.w),
                      Text(
                        '${r.count}',
                        style: TextStyle(
                          color: r.reacted
                              ? DashBoardColor.stickerGreen
                              : DashBoardColor.text,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SpaceGrot',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _showEmojiPicker(emojis),
              child: Container(
                width: 40.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: DashBoardColor.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: DashBoardColor.border),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 18.sp,
                  color: DashBoardColor.textMuted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_comments.isNotEmpty) ...[
          _sectionLabel('COMMENTS'),
          SizedBox(height: 10.h),
          ..._comments.map((c) => _buildComment(c)),
        ],
      ],
    );
  }

  Widget _buildComment(_CommentModel comment) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: DashBoardColor.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: DashBoardColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: DashBoardColor.stickerGreen,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'Y',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'SpaceGrot',
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'You',
                style: TextStyle(
                  color: DashBoardColor.text,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'SpaceGrot',
                ),
              ),
              const Spacer(),
              Text(
                _formatTime(comment.time),
                style: TextStyle(
                  color: DashBoardColor.textMuted,
                  fontSize: 11.sp,
                  fontFamily: 'SpaceGrot',
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            comment.text,
            style: TextStyle(
              color: DashBoardColor.text.withOpacity(0.85),
              fontSize: 13.sp,
              fontFamily: 'SpaceGrot',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
      decoration: BoxDecoration(
        color: DashBoardColor.bg,
        border: Border(top: BorderSide(color: DashBoardColor.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: DashBoardColor.surface,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: DashBoardColor.border),
              ),
              child: TextField(
                controller: _commentCtrl,
                style: TextStyle(
                  color: DashBoardColor.text,
                  fontSize: 14.sp,
                  fontFamily: 'SpaceGrot',
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  border: InputBorder.none,
                  hintText: 'Add a comment…',
                  hintStyle: TextStyle(
                    color: DashBoardColor.textMuted,
                    fontSize: 13.sp,
                    fontFamily: 'SpaceGrot',
                  ),
                ),
                onSubmitted: (_) => _addComment(),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DashBoardColor.stickerPurple,
                    DashBoardColor.stickerCyan,
                  ],
                ),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: DashBoardColor.stickerPurple.withOpacity(0.35),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 14.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'ASK AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'SpaceGrot',
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: _addComment,
            child: Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: DashBoardColor.stickerGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DashBoardColor.stickerGreen.withOpacity(0.35),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(Icons.send_rounded, size: 18.sp, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      color: DashBoardColor.textMuted,
      fontSize: 11.sp,
      fontWeight: FontWeight.w700,
      fontFamily: 'SpaceGrot',
      letterSpacing: 1.2,
    ),
  );

  void _showAddTagDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: DashBoardColor.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: DashBoardColor.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Tag',
                style: TextStyle(
                  color: DashBoardColor.text,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'SpaceGrot',
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: _tagCtrl,
                autofocus: true,
                style: TextStyle(
                  color: DashBoardColor.text,
                  fontSize: 14.sp,
                  fontFamily: 'SpaceGrot',
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: DashBoardColor.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: DashBoardColor.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: DashBoardColor.border),
                  ),
                  hintText: '#tagname',
                  hintStyle: TextStyle(color: DashBoardColor.textMuted),
                  prefixIcon: Icon(
                    Icons.tag_rounded,
                    color: DashBoardColor.textMuted,
                    size: 18.sp,
                  ),
                ),
                onSubmitted: (v) {
                  _addTag(v);
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () {
                  _addTag(_tagCtrl.text);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: DashBoardColor.stickerGreen,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'SpaceGrot',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmojiPicker(List<String> emojis) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: DashBoardColor.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: DashBoardColor.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'React',
              style: TextStyle(
                color: DashBoardColor.text,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                fontFamily: 'SpaceGrot',
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: emojis
                  .map(
                    (e) => GestureDetector(
                      onTap: () {
                        _addNewReaction(e);
                        Navigator.pop(context);
                      },
                      child: Text(e, style: TextStyle(fontSize: 32.sp)),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _StatusButton extends StatelessWidget {
  final bool isActive;
  final Color color;
  final IconData icon;
  final String label;
  final AnimationController lottieCtrl;
  final VoidCallback onTap;

  const _StatusButton({
    required this.isActive,
    required this.color,
    required this.icon,
    required this.label,
    required this.lottieCtrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 68.h,
        decoration: BoxDecoration(
          color: DashBoardColor.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isActive ? color : DashBoardColor.border,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.32),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedBuilder(
                animation: lottieCtrl,
                builder: (_, child) => Opacity(
                  opacity: lottieCtrl.value.clamp(0.0, 1.0),
                  child: child,
                ),
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [color.withOpacity(0.65), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Lottie.asset(
                    'assets/anim/buttons/idaidea.json',
                    controller: lottieCtrl,
                    onLoaded: (comp) => lottieCtrl.duration = comp.duration,
                    fit: BoxFit.fill,
                  ),
                ),
              ),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 18.sp,
                      color: isActive ? Colors.white : DashBoardColor.textMuted,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      label,
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : DashBoardColor.textMuted,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'SpaceGrot',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReorderableWrap extends StatefulWidget {
  final List<String> tags;
  final void Function(String) onRemove;
  final void Function(int oldIndex, int newIndex) onReorder;
  final Widget Function(String tag) buildTagChip;

  const ReorderableWrap({
    super.key,
    required this.tags,
    required this.onRemove,
    required this.onReorder,
    required this.buildTagChip,
  });

  @override
  State<ReorderableWrap> createState() => _ReorderableWrapState();
}

class _ReorderableWrapState extends State<ReorderableWrap> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 0,
      runSpacing: 0,
      children: widget.tags.asMap().entries.map((entry) {
        final index = entry.key;
        final tag = entry.value;
        return _DraggableTagChip(
          key: ValueKey(tag),
          tag: tag,
          index: index,
          totalTags: widget.tags,
          onRemove: () => widget.onRemove(tag),
          onAccept: (fromIndex) => widget.onReorder(fromIndex, index),
          child: widget.buildTagChip(tag),
        );
      }).toList(),
    );
  }
}

class _DraggableTagChip extends StatefulWidget {
  final String tag;
  final int index;
  final List<String> totalTags;
  final VoidCallback onRemove;
  final void Function(int fromIndex) onAccept;
  final Widget child;

  const _DraggableTagChip({
    super.key,
    required this.tag,
    required this.index,
    required this.totalTags,
    required this.onRemove,
    required this.onAccept,
    required this.child,
  });

  @override
  State<_DraggableTagChip> createState() => _DraggableTagChipState();
}

class _DraggableTagChipState extends State<_DraggableTagChip> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onAcceptWithDetails: (details) => widget.onAccept(details.data),
      builder: (context, candidateData, rejectedData) {
        final isTarget = candidateData.isNotEmpty;
        return LongPressDraggable<int>(
          data: widget.index,
          hapticFeedbackOnStart: true,
          onDragStarted: () => setState(() => _isDragging = true),
          onDragEnd: (_) => setState(() => _isDragging = false),
          onDraggableCanceled: (_, __) => setState(() => _isDragging = false),
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(opacity: 0.85, child: widget.child),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: widget.child),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            transform: isTarget
                ? (Matrix4.identity()..scale(1.05))
                : Matrix4.identity(),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _CommentModel {
  final String text;
  final DateTime time;
  _CommentModel({required this.text, required this.time});
}

class _ReactionModel {
  final String emoji;
  int count;
  bool reacted;
  _ReactionModel({
    required this.emoji,
    required this.count,
    this.reacted = false,
  });
}
