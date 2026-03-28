import 'package:collabix/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateGroupTitleWidget extends StatelessWidget {
  const CreateGroupTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10.w,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/iimg.png'),
        Text(
          'Create Group',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'SpaceGrot',
          ),
        ),
        SizedBox(),
      ],
    );
  }
}
