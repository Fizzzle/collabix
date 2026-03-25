import 'package:collabix/core/auth/services/core_auth_service.dart';
import 'package:collabix/core/constants/app_colors.dart';
import 'package:collabix/core/firebase/firebase_service.dart';
import 'package:collabix/features/forgot_password/data/send_password_reset_email_repo_impl.dart';
import 'package:collabix/features/forgot_password/domain/usecase/send_password_reser_email_use_case.dart';
import 'package:collabix/features/forgot_password/presentation/forgot_password_screen.dart';
import 'package:collabix/features/forgot_password/services/forgot_pass_service.dart';
import 'package:collabix/features/home/presentation/home_screen.dart';
import 'package:collabix/features/login/data/repositories/login_repository_impl.dart';
import 'package:collabix/features/login/data/services/login_remote_service.dart';
import 'package:collabix/features/login/domain/failures/login_failure.dart';
import 'package:collabix/features/login/domain/services/login_service.dart';
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
  late final LoginService _loginService;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _loginService = LoginService(
      LoginRepositoryImpl(
        LoginRemoteServiceImpl(
          CoreAuthServiceImpl(FirebaseServiceImpl()),
          FirebaseServiceImpl(),
        ),
      ),
    );
  }

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
            _MainContent(
              textFormFieldData: textFormFieldData,
              onLoginTap: _onLoginTap,
              isLoading: _isLoading,
              emailError: _emailError,
              passwordError: _passwordError,
              onEmailChanged: _onEmailChanged,
              onPasswordChanged: _onPasswordChanged,
              onForgotPasswordService: _onForgotPasswordService(),
            ),

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
                    onTap: () async {
                      await Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const RegisterScreen(),
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

  Future<void> _onLoginTap() async {
    if (_isLoading) {
      return;
    }
    if (!_validateFields()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _loginService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) {
        return;
      }
      await Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, __, ___, child) => child,
        ),
      );
    } on LoginFailure catch (error) {
      if (mounted) {
        _applyFailureToFields(error.message);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unexpected login error.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateFields() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    String? emailError;
    String? passwordError;

    if (email.isEmpty) {
      emailError = 'Please enter your email.';
    } else if (!email.contains('@')) {
      emailError = 'Please enter a valid email.';
    }

    if (password.isEmpty) {
      passwordError = 'Please enter your password.';
    }

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    return emailError == null && passwordError == null;
  }

  void _applyFailureToFields(String message) {
    setState(() {
      if (message == 'Invalid email or password.' ||
          message == 'Email format is invalid.') {
        _emailError = message;
        _passwordError = ' ';
      } else if (message == 'Please enter your password.') {
        _passwordError = message;
      } else {
        _emailError = message;
      }
    });
  }

  void _onEmailChanged(String _) {
    if (_emailError != null) {
      setState(() => _emailError = null);
    }
  }

  void _onPasswordChanged(String _) {
    if (_passwordError != null) {
      setState(() => _passwordError = null);
    }
  }

  ForgotPasswordService _onForgotPasswordService() {
    final authRepository = SendPasswordResetEmailRepoImpl(
      FirebaseServiceImpl(),
    );
    return ForgotPasswordService(SendPasswordResetEmailUseCase(authRepository));
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({
    required this.textFormFieldData,
    required this.onLoginTap,
    required this.isLoading,
    required this.emailError,
    required this.passwordError,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onForgotPasswordService,
  });

  final List<Map<String, dynamic>> textFormFieldData;
  final Future<void> Function() onLoginTap;
  final bool isLoading;
  final String? emailError;
  final String? passwordError;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ForgotPasswordService onForgotPasswordService;
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
                ...List.generate(textFormFieldData.length, (index) {
                  final hintText = textFormFieldData[index]['hintText'];
                  return _TextFormFieldWidget(
                    hintText: hintText,
                    prefixIcon: textFormFieldData[index]['prefixIcon'],
                    controller: textFormFieldData[index]['controller'],
                    obscureText: hintText == 'Password',
                    errorText: hintText == 'Email' ? emailError : passwordError,
                    onChanged: hintText == 'Email'
                        ? onEmailChanged
                        : onPasswordChanged,
                  );
                }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        //TODO: Implement forgot password logic
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    ForgotPasswordScreen(
                                      service: onForgotPasswordService,
                                    ),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) => child,
                          ),
                        );
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
            _BottomLoginWidget(onLoginTap: onLoginTap, isLoading: isLoading),
          ],
        ),
      ),
    );
  }
}

class _BottomLoginWidget extends StatefulWidget {
  const _BottomLoginWidget({required this.onLoginTap, required this.isLoading});

  final Future<void> Function() onLoginTap;
  final bool isLoading;

  @override
  State<_BottomLoginWidget> createState() => _BottomLoginWidgetState();
}

class _BottomLoginWidgetState extends State<_BottomLoginWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 24.h),

        /// SIGN IN BUTTON
        GestureDetector(
          onTap: () async {
            await widget.onLoginTap();
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
                  child: widget.isLoading
                      ? SizedBox(
                          width: 26.w,
                          height: 26.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.background,
                          ),
                        )
                      : Text(
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
                onTap: () async {
                  try {
                    final user = await CoreAuthServiceImpl(
                      FirebaseServiceImpl(),
                    ).registerWithGoogle();
                    if (!context.mounted) {
                      return;
                    }
                    if (user != null) {
                      await Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const HomeScreen(),
                          transitionsBuilder: (_, __, ___, child) => child,
                        ),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Google sign in was cancelled.'),
                      ),
                    );
                  } catch (error) {
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Google sign in failed: $error')),
                    );
                  }
                },
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
  final bool obscureText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  const _TextFormFieldWidget({
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
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
        errorText: errorText,
        errorStyle: TextStyle(
          fontSize: 12.sp,
          color: Colors.redAccent,
          fontWeight: FontWeight.w600,
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
