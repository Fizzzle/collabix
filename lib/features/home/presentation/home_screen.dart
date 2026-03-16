import 'package:collabix/core/constants/app_colors.dart';
import 'package:collabix/features/conversation/presentation/conversation_screen.dart';
import 'package:collabix/features/home/widgets/name_and_logo_widget.dart';
import 'package:collabix/features/home/widgets/profile_widget.dart';
import 'package:collabix/features/home/widgets/user_chat_info_widget.dart';
import 'package:flutter/material.dart';

/// Home screen
class HomeScreen extends StatefulWidget {
  /// Constructor
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();

  //!Fake DATA for while development
  final List<Map<String, dynamic>> chatInfo = [
    {
      'title': 'Project Neo',
      'lastMessage': 'Last message',
      'category': 'Chat',
      'time': '12:00',
    },

    {
      'title': 'Weekend Trip',
      'lastMessage': 'Last message',
      'category': 'Board',
      'time': '12:00',
    },

    {
      'title': 'Project Neo',
      'lastMessage': 'Last message',
      'category': 'Chat',
      'time': '12:00',
    },

    {
      'title': 'Project Neo',
      'lastMessage': 'Last message',
      'category': 'Chat',
      'time': '12:00',
    },

    {
      'title': 'Project Neo',
      'lastMessage': 'Last message',
      'category': 'Board',
      'time': '12:00',
    },
    {
      'title': 'Project Neo',
      'lastMessage': 'Last message',
      'category': 'Chat',
      'time': '12:00',
    },
    {
      'title': 'Project Neo',
      'lastMessage': 'Last message',
      'category': 'Board',
      'time': '12:00',
    },
    {
      'title': 'Project Neo',
      'lastMessage': 'Last message',
      'category': 'Board',
      'time': '12:00',
    },
    {
      'title': 'Project Neo',
      'lastMessage': 'Last message',
      'category': 'Chat',
      'time': '12:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 51.0, 15.0, 8.0),
          child: SingleChildScrollView(
            child: Column(
              spacing: 28,
              children: [
                const _AppBarWidget(),
                _FindSpacesWidget(
                  searchController: searchController,
                ),
                ...List.generate(
                  chatInfo.length,
                  (index) => _DiscussionWidget(
                    chatInfo: chatInfo[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => ConversationScreen(
                            conversationTitle:
                                chatInfo[index]['title'] as String,
                          ),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: AppColors.boardText,
        onPressed: () {
          ///TODO: implement create space screen
        },
        child: Image.asset('assets/images/plus.png'),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

class _DiscussionWidget extends StatelessWidget {
  final Map<String, dynamic> chatInfo;
  final VoidCallback? onTap;
  const _DiscussionWidget({
    required this.onTap,
    required this.chatInfo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.backgroundItemColor,
          border: Border.all(color: AppColors.borderColor, width: 2),
        ),
        child: UserChatInfoWidget(
          title: chatInfo['title'] as String,
          category: chatInfo['category'] as String,
          lastMessage: chatInfo['lastMessage'] as String,
          time: chatInfo['time'] as String,
        ),
      ),
    );
  }
}

class _FindSpacesWidget extends StatelessWidget {
  final TextEditingController searchController;

  const _FindSpacesWidget({
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(
        color: AppColors.text,
      ),
      controller: searchController,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.boardText,
          ),

          borderRadius: BorderRadius.circular(16),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: AppColors.backgroundItemColor,
        hintText: 'Search spaces...',
        hintStyle: const TextStyle(
          color: AppColors.upcomingMessageText,
          fontSize: 16,
        ),

        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.boardText,
        ),
      ),
    );
  }
}

class _AppBarWidget extends StatelessWidget {
  const _AppBarWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 10,
      children: [
        const NameAndLogoWidget(),
        ProfileWidget(
          onTap: () {
            ///TODO: implement profile screen
          },
        ),
      ],
    );
  }
}
