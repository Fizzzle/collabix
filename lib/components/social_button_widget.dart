import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialButtonWidget extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const SocialButtonWidget({required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: Image.asset(imagePath, height: 32.h, width: 32.w),
      ),
    );
  }
}
