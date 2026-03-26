import 'package:collabix/core/constants/app_colors.dart';
import 'package:collabix/features/create_chat/bloc/create_chat_bloc.dart';
import 'package:collabix/features/create_chat/widgets/create_chat_button_widget.dart';
import 'package:collabix/features/create_chat/widgets/create_chat_title_widget.dart';
import 'package:collabix/features/create_chat/widgets/text_field_and_title_widget.dart';
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

class CreateChatScreen extends StatefulWidget {
  const CreateChatScreen({super.key});

  @override
  State<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  final TextEditingController _chatNameController = TextEditingController();
  final TextEditingController _chatDescriptionController =
      TextEditingController();
  final TextEditingController _participantsController = TextEditingController();

  late final List<_FieldConfig> _fields = [
    _FieldConfig(
      title: 'Chat Name \t*',
      hintText: 'Enter chat name',
      controller: _chatNameController,
      icon: Icons.tag_rounded,
      isRequired: true,
      errorText: 'Chat name is required',
    ),
    _FieldConfig(
      title: 'Description (Optional)',
      hintText: "What's the chat about?",
      controller: _chatDescriptionController,
    ),
    _FieldConfig(
      title: 'Add Participants \t*',
      hintText: 'Type names to add participants',
      controller: _participantsController,
      icon: Icons.person_add_alt_1_outlined,
      isRequired: true,
      errorText: 'Add at least one participant',
    ),
  ];

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
    });
    return isValid;
  }

  void _onCreateChat() {
    if (!_validate()) return;

    context.read<CreateChatBloc>().add(
      CreateChatRequestedEvent(
        chatName: _chatNameController.text.trim(),
        chatDescription: _chatDescriptionController.text.trim().isEmpty
            ? null
            : _chatDescriptionController.text.trim(),
        participants: _participantsController.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      ),
    );
  }

  @override
  void dispose() {
    for (final field in _fields) {
      field.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateChatBloc, CreateChatState>(
      listener: (context, state) {
        if (state is CreateChatSuccess) {
          Navigator.pop(context);
        } else if (state is CreateChatFailure) {
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
                const _AppBarCreateChatWidget(),
                const Divider(color: AppColors.borderColor, thickness: 2),

                // ── Поля ──
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    spacing: 34.h,
                    children: [
                      ..._fields.map(
                        (field) => TextFieldAndTitleWidget(
                          title: field.title,
                          hintText: field.hintText,
                          controller: field.controller,
                          icon: field.icon,
                          hasError: field.hasError,
                          errorText: field.errorText,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(2.w, 60.h, 2.w, 0),
                  child: _BottomContent(onCreateChat: _onCreateChat),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── AppBar ──
class _AppBarCreateChatWidget extends StatelessWidget {
  const _AppBarCreateChatWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.text),
        ),
        const Expanded(child: CreateChatTitleWidget()),
      ],
    );
  }
}

// ── Bottom content ──
class _BottomContent extends StatelessWidget {
  final VoidCallback onCreateChat;

  const _BottomContent({required this.onCreateChat});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20.h,
      children: [
        CreateChatButtonWidget(onTap: onCreateChat),
        SizedBox(height: 10.h),
        const Divider(color: AppColors.borderColor, thickness: 2),
        SizedBox(height: 10.h),
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
