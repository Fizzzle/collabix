import 'package:collabix/core/constants/app_colors.dart';
import 'package:collabix/features/create_chat/bloc/create_chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateChatButtonWidget extends StatelessWidget {
  final VoidCallback onTap;

  const CreateChatButtonWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateChatBloc, CreateChatState>(
      builder: (context, state) {
        final isLoading = state is CreateChatLoading;

        return GestureDetector(
          onTap: isLoading ? null : onTap,
          child: SizedBox(
            height: 70.h,
            width: double.infinity,
            child: Stack(
              children: [
                // ── Тень-слой ──
                Positioned(
                  left: 35.w,
                  right: 15.w,
                  top: 6.h,
                  child: Container(
                    height: 64.h,
                    decoration: BoxDecoration(
                      color: AppColors.chatText,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),

                // ── Основная кнопка ──
                Container(
                  margin: EdgeInsets.only(left: 20.w, right: 20.w),
                  height: 64.h,
                  width: MediaQuery.of(context).size.width - 30.w,
                  decoration: BoxDecoration(
                    color: isLoading
                        ? AppColors.chatText.withOpacity(0.7)
                        : AppColors.chatText,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: isLoading
                      ? SizedBox(
                          height: 24.h,
                          width: 24.h,
                          child: CircularProgressIndicator(
                            color: AppColors.background,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Create Chat',
                          style: TextStyle(
                            color: AppColors.background,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SpaceGrot',
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
