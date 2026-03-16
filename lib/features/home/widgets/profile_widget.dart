import 'package:collabix/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Profile widget
class ProfileWidget extends StatelessWidget {
  /// On tap callback
  final void Function() onTap;

  /// Constructor
  const ProfileWidget({
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 55,
      height: 55,
      child: GestureDetector(
        onTap: onTap,
        child: const Stack(
          children: [
            Positioned(
              top: 4,
              left: 5,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.boardText,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFF3F3F47),
              ),
            ),

            CircleAvatar(
              radius: 22,
              backgroundImage: AssetImage('assets/images/ava.png'),
            ),
          ],
        ),
      ),
    );
  }
}
