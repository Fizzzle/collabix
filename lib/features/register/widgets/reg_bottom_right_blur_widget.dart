import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegBottomRightBlurWidget extends StatelessWidget {
  const RegBottomRightBlurWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 500.h,
      left: 100.w,
      child: Container(
        height: 400.h,
        width: 400.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFED6AFF).withValues(alpha: 0.3),
              blurRadius: 150.r,
              offset: Offset(0, 10.r),
            ),
          ],
        ),
      ),
    );
  }
}
