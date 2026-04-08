import 'package:collabix/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextFieldAndTitleWidget extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController controller;
  final IconData? icon;
  final bool hasError;
  final String? errorText;

  const TextFieldAndTitleWidget({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    this.icon,
    this.hasError = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10.h,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.upcomingMessageText,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'SpaceGrot',
          ),
        ),
        TextFormField(
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zа-яА-ЯёЁ ]')),
          ],
          controller: controller,
          keyboardType: TextInputType.text,
          autocorrect: true,
          cursorColor: AppColors.upcomingMessageText,
          maxLines: title.contains('Description') ? 4 : 1,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'SpaceGrot',
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.backgroundItemColor,
            hintText: hintText,
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.upcomingMessageText)
                : null,
            hintStyle: TextStyle(
              color: AppColors.upcomingMessageText,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'SpaceGrot',
            ),
            errorText: hasError
                ? (errorText ?? 'This field is required')
                : null,
            errorStyle: TextStyle(
              color: Colors.redAccent,
              fontSize: 12.sp,
              fontFamily: 'SpaceGrot',
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderColor),
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
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              borderRadius: BorderRadius.circular(14.r),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
        ),
      ],
    );
  }
}
