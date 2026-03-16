import 'package:collabix/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Chat screen
class ChatScreen extends StatefulWidget {
  /// Constructor
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Text('Chat'),
        ],
      ),
      backgroundColor: AppColors.background,
    );
  }
}
