import 'package:collabix/core/constants/app_colors.dart';
import 'package:collabix/features/login/presentation/login_screen.dart';
import 'package:collabix/features/register/widgets/reg_bottom_right_blur_widget.dart';
import 'package:collabix/features/register/widgets/reg_second_bottom_right_blur_widget.dart';
import 'package:collabix/features/register/widgets/reg_top_left_blur_widget.dart';
import 'package:collabix/widgets/social_button_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    /// Text form field data
    final List<Map<String, dynamic>> textFormFieldData = [
      {
        'hintText': 'Full Name',
        'prefixIcon': Icons.person,
        'controller': _fullNameController,
      },
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
      {
        'hintText': 'Confirm Password',
        'prefixIcon': Icons.lock,
        'controller': _confirmPasswordController,
      },
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Stack(
            children: [
              /// Top left blur widget
              RegTopLeftBlurWidget(),

              /// Second bottom right blur widget
              RegSecondBottomRightBlurWidget(),

              /// Bottom right blur widget
              RegBottomRightBlurWidget(),

              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 70.0.h,
                    left: 24.0.w,
                    right: 24.0.w,
                  ),
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
                              prefixIcon:
                                  textFormFieldData[index]['prefixIcon'],
                              controller:
                                  textFormFieldData[index]['controller'],
                            ),
                          ),
                        ],
                      ),
                      _BottomRegisterWidget(),
                      const SizedBox(height: 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

class _BottomRegisterWidget extends StatefulWidget {
  const _BottomRegisterWidget();

  @override
  State<_BottomRegisterWidget> createState() => _BottomRegisterWidgetState();
}

class _BottomRegisterWidgetState extends State<_BottomRegisterWidget> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20.h),

        /// CHECKBOX + TEXT
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => isChecked = !isChecked),
              child: Container(
                width: 25.w,
                height: 27.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: Colors.grey),
                  color: isChecked ? AppColors.chatText : Colors.transparent,
                ),
                child: isChecked
                    ? Icon(Icons.check, size: 16.sp, color: Colors.white)
                    : null,
              ),
            ),

            SizedBox(width: 10.w),

            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                    fontFamily: 'SpaceGrot',
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppColors.chatText,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          debugPrint('Terms of Service clicked');
                        },
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.chatText,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          debugPrint('Privacy Policy clicked');
                        },
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 24.h),

        /// SIGN UP BUTTON
        GestureDetector(
          onTap: () {
            //TODO: Implement sign up logic
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    LoginScreen(),
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
                      color: AppColors.chatText,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),

                /// MAIN BUTTON
                Container(
                  height: 64.h,
                  width: MediaQuery.of(context).size.width - 65.w,
                  decoration: BoxDecoration(
                    color: AppColors.chatText,

                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 24.h),

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

        SizedBox(height: 24.h),

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
          borderSide: BorderSide(color: AppColors.chatText),
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
            color: AppColors.chatText,
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

                  child: Image.asset('assets/images/iimg.png'),
                ),
              ),
            ],
          ),
        ),
        Text(
          'Join CollaBix ✨',
          style: TextStyle(
            fontSize: 36.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
            fontFamily: 'SpaceGrot',
          ),
        ),
        Text(
          'Create and account to get started',
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
