import 'package:collabix/core/constants/app_colors.dart';
import 'package:collabix/features/forgot_password/domain/entity/forgot_pass_request.dart';
import 'package:collabix/features/forgot_password/services/forgot_pass_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../login/widgets/log_bottom_right_blur_widget.dart';
import '../../login/widgets/log_second_bottom_right_blur_widget.dart';
import '../../login/widgets/log_top_left_blur_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, required this.service});

  final ForgotPasswordService service;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;
  String? _codeError;

  late final ForgotPasswordService _forgotPasswordService;

  @override
  void initState() {
    super.initState();
    _forgotPasswordService = widget.service;
  }

  Future<void> _onSubmit() async {
    setState(() {
      _isLoading = true;
      _emailError = null;
      _codeError = null;
    });

    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = "Email cannot be empty";
        _isLoading = false;
      });
      return;
    }

    if (_codeController.text.isEmpty) {
      setState(() {
        _codeError = "Code cannot be empty";
        _isLoading = false;
      });
      return;
    }

    try {
      await _forgotPasswordService.resetPassword(
        ForgotPasswordRequest(email: _emailController.text),
        // code: _codeController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check your email for reset instructions.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> textFormFieldData = [
      {
        'hintText': 'Email',
        'prefixIcon': Icons.email,
        'controller': _emailController,
        'errorText': _emailError,
      },
      {
        'hintText': 'Secret Code',
        'prefixIcon': Icons.lock,
        'controller': _codeController,
        'errorText': _codeError,
      },
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // blur виджеты
            LogTopLeftBlurWidget(),
            LogSecondBottomRightBlurWidget(),
            LogBottomRightBlurWidget(),

            // основной контент
            _MainContent(
              textFormFieldData: textFormFieldData,
              isLoading: _isLoading,
              onSubmit: _onSubmit,
            ),
            Positioned(
              top: 10.h,
              left: 10.w,
              child: Container(
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainContent extends StatelessWidget {
  const _MainContent({
    required this.textFormFieldData,
    required this.isLoading,
    required this.onSubmit,
  });

  final List<Map<String, dynamic>> textFormFieldData;
  final bool isLoading;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.only(top: 140.h, left: 24.w, right: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // кастомный квадратик сверху
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

            SizedBox(height: 30.h),

            // Заголовок
            Text(
              'Reset Password 🔐',
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
                fontFamily: 'SpaceGrot',
              ),
            ),
            SizedBox(height: 16.h),

            // Подзаголовок
            Text(
              "Fill in the fields. If successful, we'll send you an email with instructions to reset your password.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.upcomingMessageText,
                fontFamily: 'SpaceGrot',
              ),
            ),

            SizedBox(height: 40.h),

            // Поля
            Column(
              children: textFormFieldData.map((field) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _TextFormFieldWidget(
                    hintText: field['hintText'],
                    prefixIcon: field['prefixIcon'],
                    controller: field['controller'],
                    errorText: field['errorText'],
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 40.h),

            // Submit кнопка
            GestureDetector(
              onTap: isLoading ? null : onSubmit,
              child: Container(
                height: 64.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.boardText,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                alignment: Alignment.center,
                child: isLoading
                    ? SizedBox(
                        width: 26.w,
                        height: 26.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                    : Text(
                        'Submit',
                        style: TextStyle(
                          color: AppColors.background,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextFormFieldWidget extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final String? errorText;

  const _TextFormFieldWidget({
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.errorText,
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
