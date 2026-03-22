import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LogTopLeftBlurWidget extends StatelessWidget {
  const LogTopLeftBlurWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 50.w,
      child: Container(
        height: 500.h,
        width: 500.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF9AE600).withValues(alpha: 0.3),
              blurRadius: 120.r,
              offset: Offset(0, 10.r),
            ),
          ],
        ),
      ),
    );
  }
}
