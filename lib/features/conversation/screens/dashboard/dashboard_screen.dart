import 'package:collabix/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// DASHBOARD SCREEN
class DashboardScreen extends StatelessWidget {
  /// Constructor
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Dashboard',
        style: TextStyle(
          color: AppColors.text,
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'SpaceGrot',
        ),
      ),
    );
  }
}
