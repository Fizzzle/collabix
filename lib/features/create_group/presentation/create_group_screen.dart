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

// ── Typed model для полей ──
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

                // ── Поля ──
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
  final bool? isPrivate;
  final ValueChanged<bool>? onChanged;

  const _PrivatePublicSelectorWidget({this.isPrivate, this.onChanged});

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
    isPrivate = widget.isPrivate ?? true; // приват по дефолту
  }

  void _toggle(bool value) {
    setState(() {
      isPrivate = value;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(isPrivate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10.w,
        children: [
          // Private
          GestureDetector(
            onTap: () => _toggle(true),
            child: AnimatedContainer(
              width: 150.w,
              height: 60.h,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isPrivate
                    ? AppColors.chatText.withValues(alpha: 0.5)
                    : AppColors.chatText.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14.r),
                border: Border(
                  top: BorderSide(
                    color: isPrivate
                        ? AppColors.chatText.withValues(alpha: 0.8)
                        : AppColors.chatText.withValues(alpha: 0.3),
                    width: 4.w,
                  ),
                  right: BorderSide(
                    color: isPrivate
                        ? AppColors.chatText.withValues(alpha: 0.8)
                        : AppColors.chatText.withValues(alpha: 0.3),
                    width: isPrivate ? 8.w : 4.w,
                  ),
                  bottom: BorderSide(
                    color: isPrivate
                        ? AppColors.chatText.withValues(alpha: 0.8)
                        : AppColors.chatText.withValues(alpha: 0.3),
                    width: 4.w,
                  ),
                  left: BorderSide(
                    color: isPrivate
                        ? AppColors.chatText.withValues(alpha: 0.8)
                        : AppColors.chatText.withValues(alpha: 0.3),
                    width: 4.w,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  'Private',
                  style: TextStyle(
                    color: isPrivate
                        ? AppColors.text
                        : AppColors.chatText, // серый для неактивного
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SpaceGrot',
                  ),
                ),
              ),
            ),
          ),

          // Public
          GestureDetector(
            onTap: () => _toggle(false),
            child: AnimatedContainer(
              width: 150.w,
              height: 60.h,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: !isPrivate
                    ? AppColors.chatText.withValues(alpha: 0.5)
                    : AppColors.chatText.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14.r),
                border: Border(
                  top: BorderSide(
                    color: !isPrivate
                        ? AppColors.chatText.withValues(alpha: 0.6)
                        : AppColors.chatText.withValues(alpha: 0.3),
                    width: 4.w,
                  ),
                  right: BorderSide(
                    color: !isPrivate
                        ? AppColors.chatText.withValues(alpha: 0.6)
                        : AppColors.chatText.withValues(alpha: 0.3),
                    width: 4.w,
                  ),
                  bottom: BorderSide(
                    color: !isPrivate
                        ? AppColors.chatText.withValues(alpha: 0.6)
                        : AppColors.chatText.withValues(alpha: 0.3),
                    width: 4.w,
                  ),
                  left: BorderSide(
                    color: !isPrivate
                        ? AppColors.chatText.withValues(alpha: 0.6)
                        : AppColors.chatText.withValues(alpha: 0.3),
                    width: !isPrivate ? 8.w : 4.w,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  'Public',
                  style: TextStyle(
                    color: isPrivate
                        ? AppColors.chatText
                        : AppColors.text, // серый для неактивного
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'SpaceGrot',
                  ),
                ),
              ),
            ),
          ),
        ],
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

// ── AppBar ──
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

// ── Bottom content ──
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
                  fontSize: 14.sp,
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
