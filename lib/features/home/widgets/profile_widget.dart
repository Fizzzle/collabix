import 'package:collabix/core/constants/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileWidget extends StatelessWidget {
  final void Function() onTap;

  const ProfileWidget({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SizedBox(
      width: 55.w,
      height: 55.h,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned(
              top: 4.h,
              left: 5.w,
              child: CircleAvatar(
                radius: 24.r,
                backgroundColor: AppColors.boardText,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: CircleAvatar(
                radius: 25.r,
                backgroundColor: const Color(0xFF3F3F47),
              ),
            ),
            CircleAvatar(
              radius: 24.r,
              backgroundColor: AppColors.backgroundItemColor,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? Icon(
                      Icons.person_rounded,
                      size: 22.sp,
                      color: AppColors.upcomingMessageText,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
