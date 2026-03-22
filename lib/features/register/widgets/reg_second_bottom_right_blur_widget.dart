import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegSecondBottomRightBlurWidget extends StatelessWidget {
  const RegSecondBottomRightBlurWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 420.h,
      left: 20.w,
      child: Container(
        height: 400.h,
        width: 400.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF00D3F3).withValues(alpha: 0.2),
              blurRadius: 150.r,
              offset: Offset(0, 10.r),
            ),
          ],
        ),
      ),
    );
  }
}
