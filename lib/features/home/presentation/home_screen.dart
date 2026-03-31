import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabix/core/constants/app_colors.dart';
import 'package:collabix/features/conversation/presentation/conversation_screen.dart';
import 'package:collabix/features/conversation/screens/profile/profile_page.dart';
import 'package:collabix/features/create_group/presentation/create_group_screen.dart';
import 'package:collabix/features/home/widgets/name_and_logo_widget.dart';
import 'package:collabix/features/home/widgets/profile_widget.dart';
import 'package:collabix/features/home/widgets/user_chat_info_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Home screen
class HomeScreen extends StatefulWidget {
  /// Constructor
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  bool _isReloading = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: RefreshIndicator(
          onRefresh: _reloadChats,
          color: AppColors.boardText,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 20.0),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                spacing: 28,
                children: [
                  _AppBarWidget(
                    onReload: _reloadChats,
                    isReloading: _isReloading,
                  ),
                  _FindSpacesWidget(searchController: searchController),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _chatsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Text(
                          'Failed to load chats',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 14.sp,
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return Text(
                          'No chats yet. Create your first one.',
                          style: TextStyle(
                            color: AppColors.upcomingMessageText,
                            fontSize: 14.sp,
                          ),
                        );
                      }

                      final query = searchController.text.trim().toLowerCase();
                      final filteredDocs = docs.where((doc) {
                        if (query.isEmpty) return true;
                        final data = doc.data();
                        final title = (data['chatName'] ?? '')
                            .toString()
                            .toLowerCase();
                        return title.contains(query);
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        return Text(
                          'No chats match your search.',
                          style: TextStyle(
                            color: AppColors.upcomingMessageText,
                            fontSize: 14.sp,
                          ),
                        );
                      }

                      return Column(
                        children: List.generate(filteredDocs.length, (index) {
                          final doc = filteredDocs[index];
                          final chat = doc.data();
                          final groupId = chat['groupId'] as String? ?? doc.id;
                          final title = (chat['chatName'] ?? 'Untitled Chat')
                              .toString();
                          final lastPanel =
                              (chat['lastPanel'] as String? ?? 'chat');

                          return _HomeGroupTile(
                            groupId: groupId,
                            title: title,
                            lastPanelRaw: lastPanel,
                            membership: chat,
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      ConversationScreen(
                                        chatId: groupId,
                                        conversationTitle: title,
                                      ),
                                  transitionsBuilder:
                                      (_, animation, __, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                ),
                              );
                            },
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: AppColors.boardText,
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ____) => const CreateGroupScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        child: Image.asset('assets/images/plus.png'),
      ),
    );
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _reloadChats() async {
    if (_isReloading) return;
    setState(() => _isReloading = true);
    try {
      final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserUid == null || currentUserUid.isEmpty) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserUid)
          .collection('Groups')
          .get(const GetOptions(source: Source.server));
      if (mounted) setState(() {});
    } finally {
      if (mounted) setState(() => _isReloading = false);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _chatsStream() {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserUid == null || currentUserUid.isEmpty) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .collection('Groups')
        .orderBy('joinedAt', descending: true)
        .snapshots();
  }
}

String _formatFirestoreTime(Timestamp? t) {
  if (t == null) return '';
  final d = t.toDate();
  final now = DateTime.now();
  final diff = now.difference(d);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inHours < 24 && d.day == now.day) {
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}d';
  }
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year.toString().substring(2)}';
}

class _HomeGroupTile extends StatelessWidget {
  const _HomeGroupTile({
    required this.groupId,
    required this.title,
    required this.lastPanelRaw,
    required this.membership,
    required this.onTap,
  });

  final String groupId;
  final String title;
  final String lastPanelRaw;
  final Map<String, dynamic> membership;
  final VoidCallback onTap;

  static Timestamp? _readTimestamp(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Groups')
          .doc(groupId)
          .snapshots(),
      builder: (context, snapshot) {
        final live = snapshot.data?.data();
        final merged = Map<String, dynamic>.from(membership);
        if (live != null) {
          merged.addAll(live);
        }

        final nameRaw = merged['chatName'] as String?;
        final rowTitle = (nameRaw != null && nameRaw.trim().isNotEmpty)
            ? nameRaw.trim()
            : title;

        var lastMsg = (merged['lastMessage'] as String?)?.trim();
        var ts = _readTimestamp(merged['lastMessageAt']);

        final panelRaw =
            (merged['lastPanel'] as String? ?? lastPanelRaw).toString();
        final panel =
            panelRaw.toLowerCase() == 'board' ? 'Board' : 'Chat';

        final displayMsg = lastMsg != null && lastMsg.isNotEmpty
            ? lastMsg
            : 'No messages yet';
        final timeStr = _formatFirestoreTime(ts);

        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _DiscussionWidget(
            chatInfo: {
              'title': rowTitle,
              'lastMessage': displayMsg,
              'category': panel,
              'time': timeStr,
              'groupId': groupId,
            },
            onTap: onTap,
          ),
        );
      },
    );
  }
}

class _DiscussionWidget extends StatelessWidget {
  final Map<String, dynamic> chatInfo;
  final VoidCallback? onTap;
  const _DiscussionWidget({required this.onTap, required this.chatInfo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 88.h),
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
          groupId: chatInfo['groupId'] as String,
        ),
      ),
    );
  }
}

class _FindSpacesWidget extends StatelessWidget {
  final TextEditingController searchController;

  const _FindSpacesWidget({required this.searchController});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: AppColors.text),
      controller: searchController,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.boardText),

          borderRadius: BorderRadius.circular(16.r),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
        filled: true,
        fillColor: AppColors.backgroundItemColor,
        hintText: 'Search spaces...',
        hintStyle: TextStyle(
          color: AppColors.upcomingMessageText,
          fontSize: 16.sp,
        ),

        prefixIcon: const Icon(Icons.search, color: AppColors.boardText),
      ),
    );
  }
}

class _AppBarWidget extends StatelessWidget {
  final Future<void> Function() onReload;
  final bool isReloading;

  const _AppBarWidget({required this.onReload, required this.isReloading});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 10.w,
      children: [
        const NameAndLogoWidget(),
        ProfileWidget(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const ProfilePage(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
