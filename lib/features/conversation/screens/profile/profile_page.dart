import 'package:collabix/core/auth/models/app_user.dart';
import 'package:collabix/core/auth/services/core_auth_service.dart';
import 'package:collabix/core/constants/app_colors.dart';
import 'package:collabix/core/firebase/firebase_service.dart';
import 'package:collabix/features/login/presentation/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  late final CoreAuthService _authService;

  User? get _firebaseUser => FirebaseAuth.instance.currentUser;

  AppUser? _appUser;
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoadingProfile = true;

  late final TextEditingController _nameController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _authService = CoreAuthServiceImpl(FirebaseServiceImpl());

    _nameController = TextEditingController();
    _descController = TextEditingController();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return;

    final appUser = await _authService.fetchUserProfile(uid);
    if (!mounted) return;

    setState(() {
      _appUser = appUser;
      _nameController.text = appUser?.name ?? _firebaseUser?.displayName ?? '';
      _descController.text = appUser?.description ?? '';
      _isLoadingProfile = false;
    });

    _animController.forward();
  }

  void _toggleEdit() {
    if (_isEditing) {
      _nameController.text = _appUser?.name ?? _firebaseUser?.displayName ?? '';
      _descController.text = _appUser?.description ?? '';
    }
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _saveProfile() async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    try {
      await _authService.updateProfile(
        uid: uid,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
      );

      await _firebaseUser?.reload();

      final updated = await _authService.fetchUserProfile(uid);

      if (!mounted) return;
      setState(() {
        _appUser = updated;
        _isEditing = false;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile updated',
            style: TextStyle(
              fontFamily: 'SpaceGrot',
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
          backgroundColor: AppColors.backgroundItemColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.w),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update profile',
            style: TextStyle(
              fontFamily: 'SpaceGrot',
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.w),
        ),
      );
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;
    await Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, __, ___, child) => child,
      ),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _HeaderSection(
                          user: _firebaseUser,
                          appUser: _appUser,
                          isEditing: _isEditing,
                          isSaving: _isSaving,
                          nameController: _nameController,
                          descController: _descController,
                          onEditTap: _toggleEdit,
                          onSaveTap: _saveProfile,
                        ),
                        SizedBox(height: 20.w),
                        _StatsRow(appUser: _appUser),
                        SizedBox(height: 24.w),
                        _BottomSection(onSignOut: _signOut),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.only(left: 16.w, top: 8.w),
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.backgroundItemColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.07),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.text,
            size: 16.sp,
          ),
        ),
      ),
      title: Text(
        'PROFILE',
        style: TextStyle(
          color: AppColors.text,
          fontSize: 14.sp,
          fontFamily: 'SpaceGrot',
          fontWeight: FontWeight.w700,
          letterSpacing: 2.5,
        ),
      ),
      centerTitle: true,
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.user,
    required this.appUser,
    required this.isEditing,
    required this.isSaving,
    required this.nameController,
    required this.descController,
    required this.onEditTap,
    required this.onSaveTap,
  });

  final User? user;
  final AppUser? appUser;
  final bool isEditing;
  final bool isSaving;
  final TextEditingController nameController;
  final TextEditingController descController;
  final VoidCallback onEditTap;
  final VoidCallback onSaveTap;

  String _handleFromEmail(String email) {
    if (email.isEmpty) return '@user';
    return '@${email.split('@').first.replaceAll('.', '_')}';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 110.w, bottom: 4.w),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.asset(
                    'assets/anim/decor/avatarCircle.json',
                    width: 150.w,
                    height: 150.w,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                  CircleAvatar(
                    radius: 66.r,
                    backgroundColor: AppColors.backgroundItemColor,
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? Icon(
                            Icons.person,
                            size: 38.sp,
                            color: AppColors.upcomingMessageText,
                          )
                        : null,
                  ),
                  if (isEditing)
                    Positioned(
                      bottom: 3.w,
                      right: 3.w,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 26.w,
                          height: 26.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.boardText,
                            border: Border.all(
                              color: AppColors.background,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 13.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  else
                    Positioned(
                      bottom: 13.w,
                      right: 23.w,
                      child: Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.boardText,
                          border: Border.all(
                            color: AppColors.background,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 14.w),

              AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState: isEditing
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: _StaticNameHandle(
                  user: user,
                  appUser: appUser,
                  handleFromEmail: _handleFromEmail,
                ),
                secondChild: _EditableNameHandle(
                  nameController: nameController,
                ),
              ),

              SizedBox(height: 10.w),

              AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState: isEditing
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 36.w),
                  child: Text(
                    appUser?.description?.isNotEmpty == true
                        ? appUser!.description!
                        : 'No bio yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.upcomingMessageText,
                      fontFamily: 'SpaceGrot',
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
                secondChild: _EditableDesc(descController: descController),
              ),

              SizedBox(height: 16.w),

              if (!isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatusPill(label: 'ONLINE', color: AppColors.boardText),
                    SizedBox(width: 8.w),
                    _StatusPill(label: 'FRIENDS', color: AppColors.chatText),
                  ],
                ),

              SizedBox(height: 20.w),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isEditing) ...[
                    _ActionButton(
                      label: 'Cancel',
                      onTap: onEditTap,
                      outlined: true,
                    ),
                    SizedBox(width: 10.w),
                    _ActionButton(
                      label: isSaving ? 'Saving…' : 'Save',
                      onTap: isSaving ? () {} : onSaveTap,
                      outlined: false,
                    ),
                  ] else
                    _ActionButton(
                      label: 'Edit Profile',
                      onTap: onEditTap,
                      outlined: true,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StaticNameHandle extends StatelessWidget {
  const _StaticNameHandle({
    required this.user,
    required this.appUser,
    required this.handleFromEmail,
  });

  final User? user;
  final AppUser? appUser;
  final String Function(String) handleFromEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appUser?.name?.isNotEmpty == true
                  ? appUser!.name
                  : (user?.displayName ?? 'User'),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
                fontFamily: 'SpaceGrot',
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              Icons.verified_rounded,
              color: AppColors.chatText,
              size: 20.sp,
            ),
          ],
        ),
        SizedBox(height: 4.w),
        Text(
          handleFromEmail(user?.email ?? ''),
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.upcomingMessageText,
            fontFamily: 'SpaceGrot',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _EditableNameHandle extends StatelessWidget {
  const _EditableNameHandle({required this.nameController});
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 48.w),
      child: TextField(
        controller: nameController,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
          fontFamily: 'SpaceGrot',
        ),
        cursorColor: AppColors.boardText,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8.w),
          hintText: 'Your name',
          hintStyle: TextStyle(
            color: AppColors.upcomingMessageText,
            fontFamily: 'SpaceGrot',
            fontSize: 22.sp,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.boardText.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.boardText, width: 2),
          ),
        ),
      ),
    );
  }
}

class _EditableDesc extends StatelessWidget {
  const _EditableDesc({required this.descController});
  final TextEditingController descController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: TextField(
        controller: descController,
        textAlign: TextAlign.center,
        maxLines: 3,
        minLines: 1,
        style: TextStyle(
          fontSize: 13.sp,
          color: AppColors.upcomingMessageText,
          fontFamily: 'SpaceGrot',
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
        cursorColor: AppColors.boardText,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8.w),
          hintText: 'Write something about you…',
          hintStyle: TextStyle(
            color: AppColors.upcomingMessageText.withValues(alpha: 0.5),
            fontFamily: 'SpaceGrot',
            fontSize: 13.sp,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.boardText.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.boardText, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.outlined,
  });

  final String label;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.w),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : AppColors.boardText,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: outlined
                ? Colors.white.withValues(alpha: 0.12)
                : AppColors.boardText,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: outlined ? AppColors.text : Colors.black,
            fontSize: 14.sp,
            fontFamily: 'SpaceGrot',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.sp,
              fontFamily: 'SpaceGrot',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.appUser});
  final AppUser? appUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          _StatCard(
            value: '${appUser?.boardsCreated ?? 0}',
            label: 'Boards',
            icon: Icons.dashboard_rounded,
          ),
          SizedBox(width: 12.w),
          _StatCard(
            value: '${appUser?.aiAssists ?? 0}',
            label: 'AI Assists',
            icon: Icons.auto_awesome_rounded,
          ),
          SizedBox(width: 12.w),
          _StatCard(
            value: '${appUser?.dayStreak ?? 0}d',
            label: 'Streak',
            icon: Icons.local_fire_department_rounded,
            accentColor: const Color(0xFFFF6B35),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    this.accentColor,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.boardText;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundItemColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.sp),
            SizedBox(height: 8.w),
            Text(
              value,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 20.sp,
                fontFamily: 'SpaceGrot',
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.w),
            Text(
              label,
              style: TextStyle(
                color: AppColors.upcomingMessageText,
                fontSize: 11.sp,
                fontFamily: 'SpaceGrot',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSection extends StatelessWidget {
  const _BottomSection({required this.onSignOut});
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Badges & Trophies',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 15.sp,
                  fontFamily: 'SpaceGrot',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '2/8 Unlocked',
                style: TextStyle(
                  color: AppColors.upcomingMessageText,
                  fontSize: 12.sp,
                  fontFamily: 'SpaceGrot',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.w),
          SizedBox(
            height: 90.w,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _BadgeCard(
                  icon: Icons.electric_bolt_rounded,
                  label: 'Idea Generator',
                  color: const Color(0xFF6C63FF),
                ),
                SizedBox(width: 12.w),
                _BadgeCard(
                  icon: Icons.group_rounded,
                  label: 'Team Player',
                  color: AppColors.chatText,
                ),
                SizedBox(width: 12.w),
                _BadgeCard(
                  icon: Icons.lock_outline_rounded,
                  label: '???',
                  color: Colors.white24,
                  locked: true,
                ),
              ],
            ),
          ),

          SizedBox(height: 20.w),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.chatText.withValues(alpha: 0.18),
                  const Color(0xFF6C63FF).withValues(alpha: 0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.chatText.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.chatText.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.chatText,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR AI STYLE',
                      style: TextStyle(
                        color: AppColors.upcomingMessageText,
                        fontSize: 10.sp,
                        fontFamily: 'SpaceGrot',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 2.w),
                    Text(
                      'Friendly Helper',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16.sp,
                        fontFamily: 'SpaceGrot',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.w,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.chatText,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.sp,
                      fontFamily: 'SpaceGrot',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.w),

          GestureDetector(
            onTap: onSignOut,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.w),
              decoration: BoxDecoration(
                color: AppColors.backgroundItemColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 20.sp,
                  ),
                  SizedBox(width: 14.w),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 15.sp,
                      fontFamily: 'SpaceGrot',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 32.w),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.icon,
    required this.label,
    required this.color,
    this.locked = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.symmetric(vertical: 12.w),
      decoration: BoxDecoration(
        color: locked
            ? AppColors.backgroundItemColor.withValues(alpha: 0.5)
            : AppColors.backgroundItemColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: locked ? Colors.white12 : color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: locked ? Colors.white24 : color, size: 24.sp),
          SizedBox(height: 6.w),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: locked ? Colors.white24 : AppColors.text,
              fontSize: 10.sp,
              fontFamily: 'SpaceGrot',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
