import 'package:collabix/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Chat screen
class ChatScreen extends StatelessWidget {
  /// Constructor
  const ChatScreen({
    required DraggableScrollableController draggableScrollableController,
    super.key,
  }) : _draggableScrollableController = draggableScrollableController;

  final DraggableScrollableController _draggableScrollableController;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _draggableScrollableController,
      initialChildSize: 1,
      minChildSize: 0,
      builder: (_, scrollController) {
        return ColoredBox(
          color: AppColors.background,
          child: ListView(
            controller: scrollController,
            children: const [
              SizedBox(height: 10),

              /// Handle
              Center(
                child: SizedBox(
                  width: 40,
                  child: Divider(
                    thickness: 4,
                    color: Colors.red,
                  ),
                ),
              ),

              SizedBox(height: 20),

              Center(
                child: Text(
                  "Chat panel",
                  style: TextStyle(color: AppColors.text),
                ),
              ),

              SizedBox(height: 800),
            ],
          ),
        );
      },
    );
  }
}
