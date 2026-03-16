import 'package:collabix/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// DASHBOARD SCREEN
class DashboardScreen extends StatelessWidget {
  /// Constructor
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Dashboard',
        style: TextStyle(
          color: AppColors.text,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'SpaceGrot',
        ),
      ),
    );
  }
}
