import 'package:collabix/core/constants/app_colors.dart';
import 'package:collabix/features/home/presentation/home_screen.dart';
import 'package:collabix/features/login/widgets/log_bottom_right_blur_widget.dart';
import 'package:collabix/features/login/widgets/log_second_bottom_right_blur_widget.dart';
import 'package:collabix/features/login/widgets/log_top_left_blur_widget.dart';
import 'package:collabix/features/register/presentation/register_screen.dart';
import 'package:collabix/widgets/social_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    /// Text form field data
    final List<Map<String, dynamic>> textFormFieldData = [
      {
        'hintText': 'Email',
        'prefixIcon': Icons.email,
        'controller': _emailController,
      },
      {
        'hintText': 'Password',
        'prefixIcon': Icons.lock,
        'controller': _passwordController,
      },
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            /// Top left blur widget
            LogTopLeftBlurWidget(),

            /// Second bottom right blur widget
            LogSecondBottomRightBlurWidget(),

            /// Bottom right blur widget
            LogBottomRightBlurWidget(),

            /// MAIN CONTENT
            _MainContent(textFormFieldData: textFormFieldData),

            Positioned(
              bottom: 24.h,
              left: 0,
              right: 0,
              child: Row(
                spacing: 5.w,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?',
                    style: TextStyle(
                      color: AppColors.upcomingMessageText,
                      fontSize: 14.sp,
                      fontFamily: 'SpaceGrot',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      //TODO: Implement sign up logic
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  RegisterScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) =>
                                  child,
                        ),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppColors.boardText,
                        fontSize: 14.sp,
                        fontFamily: 'SpaceGrot',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({required this.textFormFieldData});

  final List<Map<String, dynamic>> textFormFieldData;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(top: 70.0, left: 24.0, right: 24.0),
        child: Column(
          spacing: 40.h,
          children: [
            _TopInfoWidget(),
            Column(
              spacing: 16.h,
              children: [
                ...List.generate(
                  textFormFieldData.length,
                  (index) => _TextFormFieldWidget(
                    hintText: textFormFieldData[index]['hintText'],
                    prefixIcon: textFormFieldData[index]['prefixIcon'],
                    controller: textFormFieldData[index]['controller'],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        //TODO: Implement forgot password logic
                        debugPrint('Forgot Password? clicked');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.upcomingMessageText,
                          fontSize: 14.sp,
                          fontFamily: 'SpaceGrot',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _BottomLoginWidget(),
          ],
        ),
      ),
    );
  }
}

class _BottomLoginWidget extends StatefulWidget {
  const _BottomLoginWidget();

  @override
  State<_BottomLoginWidget> createState() => _BottomLoginWidgetState();
}

class _BottomLoginWidgetState extends State<_BottomLoginWidget> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 24.h),

        /// SIGN IN BUTTON
        GestureDetector(
          onTap: () {
            //TODO: Implement sign up logic

            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    HomeScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) => child,
              ),
            );
          },
          child: SizedBox(
            height: 70.h,
            width: double.infinity,
            child: Stack(
              children: [
                /// BACKGROUND LAYER
                Positioned(
                  left: 5,
                  top: 6.h,
                  child: Container(
                    height: 64.h,
                    width: 330,
                    decoration: BoxDecoration(
                      color: AppColors.boardText,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),

                /// MAIN BUTTON
                Container(
                  height: 64.h,
                  width: MediaQuery.of(context).size.width - 65.w,
                  decoration: BoxDecoration(
                    color: AppColors.boardText,

                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: AppColors.background,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 65.h),

        /// OR DIVIDER LINE
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                'OR',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
          ],
        ),

        SizedBox(height: 65.h),

        /// SOCIAL BUTTONS
        Row(
          children: [
            Expanded(
              child: SocialButtonWidget(
                imagePath: 'assets/images/googleic.png',
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TextFormFieldWidget extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  const _TextFormFieldWidget({
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: AppColors.upcomingMessageText,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.text,
        fontFamily: 'SpaceGrot',
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.backgroundItemColor,
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.upcomingMessageText,
        ),
        prefixIcon: Icon(prefixIcon, color: AppColors.upcomingMessageText),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(20.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.boardText),
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }
}

class _TopInfoWidget extends StatelessWidget {
  const _TopInfoWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 75.h,
          width: 70.w,
          decoration: BoxDecoration(
            color: AppColors.boardText,
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 5.w,
                child: Container(
                  height: 70.h,
                  width: 65.w,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundItemColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),

                  child: Image.asset('assets/images/img.png'),
                ),
              ),
            ],
          ),
        ),
        Text(
          'Welcome Back ✌️',
          style: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
            fontFamily: 'SpaceGrot',
          ),
        ),
        Text(
          'Sign in to sync your vibe.',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.upcomingMessageText,
            fontFamily: 'SpaceGrot',
          ),
        ),
      ],
    );
  }
}
