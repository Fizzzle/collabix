import 'package:collabix/core/auth/services/core_auth_service.dart';
import 'package:collabix/core/constants/app_colors.dart';
import 'package:collabix/core/firebase/firebase_service.dart';
import 'package:collabix/features/login/presentation/login_screen.dart';
import 'package:collabix/features/register/data/repositories/register_repository_impl.dart';
import 'package:collabix/features/register/data/services/register_remote_service.dart';
import 'package:collabix/features/register/domain/failures/register_failure.dart';
import 'package:collabix/features/register/domain/services/register_service.dart';
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
  late final RegisterService _registerService;
  bool _isLoading = false;
  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _registerService = RegisterService(
      RegisterRepositoryImpl(
        RegisterRemoteServiceImpl(CoreAuthServiceImpl(FirebaseServiceImpl())),
      ),
    );
  }

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
        'obscureText': true,
      },
      {
        'hintText': 'Confirm Password',
        'prefixIcon': Icons.lock,
        'controller': _confirmPasswordController,
        'obscureText': true,
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

              _MainContent(
                textFormFieldData: textFormFieldData,
                isLoading: _isLoading,
                onRegisterTap: _onRegisterTap,
                fullNameError: _fullNameError,
                emailError: _emailError,
                passwordError: _passwordError,
                confirmPasswordError: _confirmPasswordError,
                onFullNameChanged: _onFullNameChanged,
                onEmailChanged: _onEmailChanged,
                onPasswordChanged: _onPasswordChanged,
                onConfirmPasswordChanged: _onConfirmPasswordChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRegisterTap(bool acceptedTerms) async {
    if (_isLoading) {
      return;
    }
    if (!_validateFields()) {
      return;
    }
    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accept terms to continue.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _registerService.register(
        name: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        acceptedTerms: acceptedTerms,
      );

      if (!mounted) {
        return;
      }

      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              child,
        ),
      );
    } on RegisterFailure catch (error) {
      if (mounted) {
        _applyFailureToFields(error.message);
      }
    } catch (_) {
      debugPrint('Unexpected register error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    String? fullNameError;
    String? emailError;
    String? passwordError;
    String? confirmPasswordError;

    if (fullName.isEmpty) {
      fullNameError = 'Please enter your full name.';
    }

    if (email.isEmpty) {
      emailError = 'Please enter your email.';
    } else if (!email.contains('@')) {
      emailError = 'Please enter a valid email.';
    }

    if (password.length < 6) {
      passwordError = 'Password must be at least 6 characters.';
    }

    if (confirmPassword != password) {
      confirmPasswordError = 'Passwords do not match.';
    }

    setState(() {
      _fullNameError = fullNameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });

    return fullNameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  void _applyFailureToFields(String message) {
    setState(() {
      if (message == 'This email is already in use.') {
        _emailError = message;
      } else if (message == 'Password is too weak.') {
        _passwordError = message;
      } else if (message == 'Email format is invalid.') {
        _emailError = message;
      }
    });
  }

  void _onFullNameChanged(String _) {
    if (_fullNameError != null) {
      setState(() => _fullNameError = null);
    }
  }

  void _onEmailChanged(String _) {
    if (_emailError != null) {
      setState(() => _emailError = null);
    }
  }

  void _onPasswordChanged(String _) {
    if (_passwordError != null || _confirmPasswordError != null) {
      setState(() {
        _passwordError = null;
        _confirmPasswordError = null;
      });
    }
  }

  void _onConfirmPasswordChanged(String _) {
    if (_confirmPasswordError != null) {
      setState(() => _confirmPasswordError = null);
    }
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({
    required this.textFormFieldData,
    required this.onRegisterTap,
    required this.isLoading,
    required this.fullNameError,
    required this.emailError,
    required this.passwordError,
    required this.confirmPasswordError,
    required this.onFullNameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmPasswordChanged,
  });

  final List<Map<String, dynamic>> textFormFieldData;
  final Future<void> Function(bool acceptedTerms) onRegisterTap;
  final bool isLoading;
  final String? fullNameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final ValueChanged<String> onFullNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmPasswordChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(top: 70.0.h, left: 24.0.w, right: 24.0.w),
        child: Column(
          spacing: 40.h,
          children: [
            _TopInfoWidget(),
            Column(
              spacing: 16.h,
              children: [
                ...List.generate(
                  textFormFieldData.length,
                  (index) {
                    final hintText = textFormFieldData[index]['hintText'] as String;
                    String? errorText;
                    ValueChanged<String>? onChanged;
                    if (hintText == 'Full Name') {
                      errorText = fullNameError;
                      onChanged = onFullNameChanged;
                    } else if (hintText == 'Email') {
                      errorText = emailError;
                      onChanged = onEmailChanged;
                    } else if (hintText == 'Password') {
                      errorText = passwordError;
                      onChanged = onPasswordChanged;
                    } else if (hintText == 'Confirm Password') {
                      errorText = confirmPasswordError;
                      onChanged = onConfirmPasswordChanged;
                    }

                    return _TextFormFieldWidget(
                      hintText: hintText,
                      prefixIcon: textFormFieldData[index]['prefixIcon'],
                      controller: textFormFieldData[index]['controller'],
                      obscureText:
                          textFormFieldData[index]['obscureText'] as bool? ??
                          false,
                      errorText: errorText,
                      onChanged: onChanged,
                    );
                  },
                ),
              ],
            ),
            _BottomRegisterWidget(
              onRegisterTap: onRegisterTap,
              isLoading: isLoading,
            ),
            const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }
}

class _BottomRegisterWidget extends StatefulWidget {
  const _BottomRegisterWidget({
    required this.onRegisterTap,
    required this.isLoading,
  });

  final Future<void> Function(bool acceptedTerms) onRegisterTap;
  final bool isLoading;

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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                width: 25.w,
                height: 25.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.9),
                    width: 1.8,
                  ),
                  color: isChecked ? AppColors.chatText : Colors.transparent,
                ),
                alignment: Alignment.center,
                child: isChecked
                    ? Icon(Icons.check, size: 18.sp, color: Colors.white)
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
          onTap: () async {
            await widget.onRegisterTap(isChecked);
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
                  child: widget.isLoading
                      ? SizedBox(
                          width: 26.w,
                          height: 26.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.text,
                          ),
                        )
                      : Text(
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
          borderSide: BorderSide(color: AppColors.chatText),
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
