import 'dart:async';

import 'package:collabix/core/auth/models/app_user.dart';
import 'package:collabix/core/constants/app_colors.dart';
import 'package:collabix/features/create_group/bloc/create_group_bloc/create_group_bloc.dart';
import 'package:collabix/features/create_group/bloc/fetch_all_users_bloc/fetch_all_users_bloc.dart';
import 'package:collabix/features/create_group/widgets/create_group_button_widget.dart';
import 'package:collabix/features/create_group/widgets/create_group_title_widget.dart';
import 'package:collabix/features/create_group/widgets/text_field_and_title_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class _FieldConfig {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final IconData? icon;
  final bool isRequired;
  final String? errorText;
  bool hasError;

  _FieldConfig({
    required this.title,
    required this.hintText,
    required this.controller,
    this.icon,
    this.isRequired = false,
    this.errorText,
    this.hasError = false,
  });
}

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _chatNameController = TextEditingController();
  final TextEditingController _chatDescriptionController =
      TextEditingController();
  final TextEditingController _participantsController = TextEditingController();
  Timer? _searchDebounce;
  final List<AppUser> _selectedUsers = [];
  bool _participantsHasError = false;
  bool? _isPrivate;
  late final List<_FieldConfig> _fields = [
    _FieldConfig(
      title: 'Group Name \t*',
      hintText: 'Enter group name',
      controller: _chatNameController,
      icon: Icons.tag_rounded,
      isRequired: true,
      errorText: 'Group name is required',
      hasError: false,
    ),
    _FieldConfig(
      title: 'Description (Optional)',
      hintText: "What's the group about?",
      controller: _chatDescriptionController,
      hasError: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _participantsController.addListener(_onParticipantsChanged);
  }

  bool _validate() {
    bool isValid = true;
    setState(() {
      for (final field in _fields) {
        if (field.isRequired && field.controller.text.trim().isEmpty) {
          field.hasError = true;
          isValid = false;
        } else {
          field.hasError = false;
        }
      }
      if (_selectedUsers.isEmpty) {
        _participantsHasError = true;
        isValid = false;
      } else {
        _participantsHasError = false;
      }
    });
    return isValid;
  }

  void _onParticipantsChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      final query = _participantsController.text.trim();
      context.read<FetchAllUsersBloc>().add(
        FetchUsersByNicknameRequestedEvent(query: query),
      );
    });
  }

  void _onSelectUser(AppUser user) {
    if (_selectedUsers.any((selected) => selected.uid == user.uid)) return;
    setState(() {
      _selectedUsers.add(user);
      _participantsHasError = false;
      _participantsController.clear();
    });
    context.read<FetchAllUsersBloc>().add(FetchAllUsersRequestedEvent());
  }

  void _onRemoveUser(String uid) {
    setState(() {
      _selectedUsers.removeWhere((user) => user.uid == uid);
    });
  }

  void _onCreateGroup() {
    if (!_validate()) return;
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    final participantsIds = _selectedUsers.map((u) => u.uid).toSet();
    if (currentUserUid != null && currentUserUid.isNotEmpty) {
      participantsIds.add(currentUserUid);
    }
    context.read<CreateGroupBloc>().add(
      CreateGroupRequestedEvent(
        chatName: _chatNameController.text.trim(),
        chatDescription: _chatDescriptionController.text.trim().isEmpty
            ? null
            : _chatDescriptionController.text.trim(),
        participantsIds: participantsIds.toList(),
        currentUserUid: currentUserUid ?? '',
        isPrivate: _isPrivate ?? true,
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _participantsController.removeListener(_onParticipantsChanged);
    for (final field in _fields) {
      field.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateGroupBloc, CreateGroupState>(
      listener: (context, state) {
        if (state is CreateGroupSuccess) {
          Navigator.pop(context);
        } else if (state is CreateGroupFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.background,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            child: Column(
              spacing: 10.h,
              children: [
                const SizedBox(),
                const _AppBarCreateGroupWidget(),
                const Divider(color: AppColors.borderColor, thickness: 2),
                _PrivatePublicSelectorWidget(
                  onChanged: (isPrivate) => _isPrivate = isPrivate,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    spacing: 34.h,
                    children: [
                      ..._fields.map((field) {
                        return TextFieldAndTitleWidget(
                          title: field.title,
                          hintText: field.hintText,
                          controller: field.controller,
                          icon: field.icon,
                          hasError: field.hasError,
                          errorText: field.errorText,
                        );
                      }),
                      _ParticipantsSelectorSection(
                        controller: _participantsController,
                        selectedUsers: _selectedUsers,
                        hasError: _participantsHasError,
                        onSelectUser: _onSelectUser,
                        onRemoveUser: _onRemoveUser,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(2.w, 40.h, 2.w, 0),
                  child: _BottomContent(onCreateGroup: _onCreateGroup),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivatePublicSelectorWidget extends StatefulWidget {
  final ValueChanged<bool>? onChanged;

  const _PrivatePublicSelectorWidget({this.onChanged});

  @override
  State<_PrivatePublicSelectorWidget> createState() =>
      _PrivatePublicSelectorWidgetState();
}

class _PrivatePublicSelectorWidgetState
    extends State<_PrivatePublicSelectorWidget> {
  late bool isPrivate;

  @override
  void initState() {
    super.initState();
    isPrivate = true;
  }

  void _toggle(bool value) {
    setState(() => isPrivate = value);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PressButton(
            label: 'Private',
            lottiePath: 'assets/anim/buttons/button_private.json',
            isActive: isPrivate,
            onTap: () => _toggle(true),
          ),
          SizedBox(width: 10.w),
          _PressButton(
            label: 'Public',
            lottiePath: 'assets/anim/buttons/button_public.json',
            isActive: !isPrivate,
            onTap: () => _toggle(false),
            appColor: AppColors.boardText,
          ),
        ],
      ),
    );
  }
}

class _PressButton extends StatefulWidget {
  const _PressButton({
    required this.label,
    required this.lottiePath,
    required this.isActive,
    required this.onTap,
    this.appColor,
  });

  final String label;
  final String lottiePath;
  final bool isActive;
  final VoidCallback onTap;
  final Color? appColor;
  @override
  State<_PressButton> createState() => _PressButtonState();
}

class _PressButtonState extends State<_PressButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  bool _pressed = false;

  static const double _pressOffset = 5.0;
  static const Duration _pressDuration = Duration(milliseconds: 80);
  static const Duration _releaseDuration = Duration(milliseconds: 120);

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(_PressButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _lottieController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  Future<void> _onTapDown() async {
    setState(() => _pressed = true);
  }

  Future<void> _onTapUp() async {
    widget.onTap();
    await Future.delayed(_pressDuration);
    if (mounted) setState(() => _pressed = false);
  }

  void _onTapCancel() {
    if (mounted) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: _onTapCancel,
      child: SizedBox(
        width: 150.w,
        height: 70.h,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              bottom: 0,
              child: Container(
                width: 150.w,
                height: 60.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  color: widget.isActive
                      ? widget.appColor?.withValues(alpha: 0.6) ??
                            AppColors.chatText.withValues(alpha: 0.6)
                      : widget.appColor?.withValues(alpha: 0.2) ??
                            AppColors.chatText.withValues(alpha: 0.2),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: _pressed ? _pressDuration : _releaseDuration,
              curve: _pressed ? Curves.easeIn : Curves.easeOut,
              top: _pressed ? _pressOffset : 0,
              child: SizedBox(
                width: 150.w,
                height: 60.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: Lottie.asset(
                        widget.lottiePath,
                        controller: _lottieController,
                        width: 150.w,
                        height: 60.h,
                        fit: BoxFit.cover,
                        onLoaded: (composition) {
                          _lottieController.duration = composition.duration;
                          if (widget.isActive) {
                            _lottieController.forward(from: 0);
                          }
                        },
                      ),
                    ),
                    if (!widget.isActive)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          color: Colors.black.withValues(alpha: 0.35),
                        ),
                      ),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        color: widget.isActive
                            ? AppColors.text
                            : AppColors.upcomingMessageText,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'SpaceGrot',
                      ),
                      child: Text(widget.label),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantsSelectorSection extends StatelessWidget {
  final TextEditingController controller;
  final List<AppUser> selectedUsers;
  final bool hasError;
  final ValueChanged<AppUser> onSelectUser;
  final ValueChanged<String> onRemoveUser;

  const _ParticipantsSelectorSection({
    required this.controller,
    required this.selectedUsers,
    required this.hasError,
    required this.onSelectUser,
    required this.onRemoveUser,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Participants \t*',
          style: TextStyle(
            color: AppColors.upcomingMessageText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'SpaceGrot',
          ),
        ),
        SizedBox(height: 10.h),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.text,
          cursorColor: AppColors.upcomingMessageText,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'SpaceGrot',
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.backgroundItemColor,
            hintText: 'Type names to add participants',
            prefixIcon: const Icon(
              Icons.person_add_alt_1_outlined,
              color: AppColors.upcomingMessageText,
            ),
            errorText: hasError ? 'Add at least one participant' : null,
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(14.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? Colors.redAccent : AppColors.boardText,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? Colors.redAccent : AppColors.borderColor,
                width: hasError ? 1.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        if (selectedUsers.isNotEmpty)
          SizedBox(
            height: 44.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: selectedUsers.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final user = selectedUsers[index];
                return Chip(
                  label: Text(user.name),
                  onDeleted: () => onRemoveUser(user.uid),
                  deleteIconColor: AppColors.text,
                  backgroundColor: AppColors.backgroundItemColor,
                  side: const BorderSide(color: AppColors.borderColor),
                  labelStyle: TextStyle(
                    color: AppColors.text,
                    fontSize: 13.sp,
                    fontFamily: 'SpaceGrot',
                  ),
                );
              },
            ),
          ),
        if (selectedUsers.isNotEmpty) SizedBox(height: 10.h),
        BlocBuilder<FetchAllUsersBloc, FetchAllUsersState>(
          builder: (context, state) {
            if (state is FetchAllUsersLoading) {
              return const Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            if (state is FetchAllUsersFailure) {
              return Text(
                state.error,
                style: TextStyle(color: Colors.redAccent, fontSize: 12.sp),
              );
            }

            if (state is! FetchAllUsersSuccess) {
              return const SizedBox.shrink();
            }

            final filtered = state.users.where((user) {
              final isCurrent =
                  currentUserUid != null && user.uid == currentUserUid;
              final alreadySelected = selectedUsers.any(
                (u) => u.uid == user.uid,
              );
              return !isCurrent && !alreadySelected;
            }).toList();

            if (filtered.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              constraints: BoxConstraints(maxHeight: 180.h),
              decoration: BoxDecoration(
                color: AppColors.backgroundItemColor,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.borderColor),
                itemBuilder: (context, index) {
                  final user = filtered[index];
                  return ListTile(
                    dense: true,
                    onTap: () => onSelectUser(user),
                    title: Text(
                      user.name,
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 14.sp,
                        fontFamily: 'SpaceGrot',
                      ),
                    ),
                    subtitle: Text(
                      user.email,
                      style: TextStyle(
                        color: AppColors.upcomingMessageText,
                        fontSize: 12.sp,
                        fontFamily: 'SpaceGrot',
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AppBarCreateGroupWidget extends StatelessWidget {
  const _AppBarCreateGroupWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.text),
        ),
        const Expanded(child: CreateGroupTitleWidget()),
      ],
    );
  }
}

class _BottomContent extends StatelessWidget {
  final VoidCallback onCreateGroup;

  const _BottomContent({required this.onCreateGroup});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20.h,
      children: [
        SizedBox(height: 15.h),
        CreateGroupButtonWidget(onTap: onCreateGroup),
        const Divider(color: AppColors.borderColor, thickness: 2),
        Container(
          width: 250,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w),
          decoration: BoxDecoration(
            color: AppColors.backgroundItemColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            spacing: 15.w,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 5.r, backgroundColor: AppColors.chatText),
              Text(
                'Sync across all devices',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'SpaceGrot',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
