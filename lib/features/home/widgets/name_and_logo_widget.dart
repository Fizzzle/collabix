import 'package:collabix/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Name and logo widget
class NameAndLogoWidget extends StatelessWidget {
  /// Constructor
  const NameAndLogoWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'CollaBix',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 36.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'SpaceGrot',
          ),
        ),
        Image.asset('assets/images/img.png'),
      ],
    );
  }
}
