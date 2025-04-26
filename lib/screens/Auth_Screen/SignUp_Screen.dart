import 'package:FitBro/models/blocs/cubit/AuthCubit/auth_cubit.dart';
import 'package:FitBro/screens/Auth_Screen/Login_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../view/menu/menu_view.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  bool _acceptTerms = false;
  late AnimationController _backgroundAnimationController;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _hasNavigated = false; // Flag to prevent multiple navigations
  bool _isTermsHovered = false; // Track hover state for Terms and Conditions

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _navigateToMenuView() {
    if (_hasNavigated || !mounted) {
      debugPrint(
        "⚡ SignUpScreen: Navigation already performed or widget not mounted",
      );
      return;
    }

    debugPrint("⚡ SignUpScreen: Navigating to MenuView");
    _hasNavigated = true;

    // Use pushAndRemoveUntil to clear the navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) {
          debugPrint("⚡ SignUpScreen: Building MenuView");
          return BlocProvider(
            create: (context) => AuthCubit()..getUserInfoFire(),
            child: const MenuView(),
          );
        },
      ),
      (Route<dynamic> route) => false, // Remove all previous routes
    );

    debugPrint("⚡ SignUpScreen: Navigation completed successfully");
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Terms and Conditions",
            style: TextStyle(fontSize: 18.sp),
          ),
          content: SingleChildScrollView(
            child: Text(
              "By using FitBro, you agree to our Terms and Conditions. "
              "These terms outline your rights and responsibilities when using our app. "
              "By continuing to use FitBro after changes are made, you accept the revised terms.",
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil here
    ScreenUtil.init(context, designSize: const Size(375, 812));

    // Define our fitness-themed colors
    final Color primaryColor = const Color(0xFF00C853); // Vibrant green
    final Color secondaryColor = const Color(0xFF212121); // Dark gray
    final Color accentColor = const Color(0xFFFFD600); // Energetic yellow
    final Color lightColor = const Color(0xFFF5F5F5); // Light background

    return Scaffold(
      body: BlocProvider(
        create: (context) => AuthCubit(),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            debugPrint(
              "⚡ SignUpScreen: State changed to: ${state.runtimeType}",
            );

            if (state is AuthSuccess) {
              debugPrint("⚡ SignUpScreen: AuthSuccess state received");
              _navigateToMenuView();

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account created successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is AuthError) {
              debugPrint(
                "⚡ SignUpScreen: AuthError state received: ${state.error}",
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is AuthLoading) {
              debugPrint("⚡ SignUpScreen: AuthLoading state received");
            }
          },
          builder: (context, state) {
            final authCubit = AuthCubit.get(context);
            debugPrint(
              "⚡ SignUpScreen: Building UI with state: ${state.runtimeType}",
            );

            return AnimatedBuilder(
              animation: _backgroundAnimationController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        secondaryColor,
                        Color.lerp(
                              secondaryColor,
                              primaryColor.withOpacity(0.7),
                              _backgroundAnimationController.value,
                            ) ??
                            secondaryColor,
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: SafeArea(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Animated background elements
                        Positioned(
                          top: -50.h,
                          right: -50.w,
                          child: Container(
                                width: 200.w,
                                height: 200.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryColor.withOpacity(0.15),
                                ),
                              )
                              .animate(
                                onPlay:
                                    (controller) =>
                                        controller.repeat(reverse: true),
                              )
                              .scale(
                                duration: 1200.ms,
                                curve: Curves.easeOutQuint,
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1.0, 1.0),
                              ),
                        ),

                        Positioned(
                          bottom: -80.h,
                          left: -80.w,
                          child: Container(
                                width: 250.w,
                                height: 250.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accentColor.withOpacity(0.08),
                                ),
                              )
                              .animate(
                                onPlay:
                                    (controller) =>
                                        controller.repeat(reverse: true),
                              )
                              .scale(
                                duration: 1500.ms,
                                curve: Curves.easeOutQuint,
                                begin: const Offset(0.9, 0.9),
                                end: const Offset(1.1, 1.1),
                              ),
                        ),

                        // Main content
                        SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Form(
                            key: authCubit.signUpFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 16.h),

                                // Back button
                                Align(
                                      alignment: Alignment.centerLeft,
                                      child: IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: Icon(
                                          Icons.arrow_back_ios_new,
                                          color: lightColor,
                                          size: 20.sp,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: lightColor
                                              .withOpacity(0.1),
                                          padding: EdgeInsets.all(8.r),
                                        ),
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(duration: 600.ms)
                                    .slideX(
                                      begin: -0.2,
                                      end: 0,
                                      duration: 600.ms,
                                      curve: Curves.easeOutQuint,
                                    ),

                                SizedBox(height: 12.h),

                                // App logo
                                Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "FIT",
                                          style: TextStyle(
                                            fontSize: 28.sp,
                                            fontWeight: FontWeight.w900,
                                            color: lightColor,
                                            letterSpacing: 1.2,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                        Text(
                                          "BRO",
                                          style: TextStyle(
                                            fontSize: 28.sp,
                                            fontWeight: FontWeight.w900,
                                            color: primaryColor,
                                            letterSpacing: 1.2,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ],
                                    )
                                    .animate()
                                    .fadeIn(duration: 800.ms)
                                    .slideY(
                                      begin: -0.2,
                                      end: 0,
                                      duration: 800.ms,
                                      curve: Curves.easeOutQuint,
                                    ),

                                SizedBox(height: 24.h),

                                // Title and subtitle
                                Text(
                                  "Create Your Account",
                                  style: TextStyle(
                                    color: lightColor,
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                  ),
                                  textAlign: TextAlign.center,
                                ).animate().fadeIn(
                                  duration: 800.ms,
                                  delay: 300.ms,
                                ),

                                SizedBox(height: 8.h),

                                Text(
                                  "Join the fitness revolution today",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: lightColor.withOpacity(0.8),
                                    fontSize: 14.sp,
                                    fontFamily: 'Montserrat',
                                  ),
                                ).animate().fadeIn(
                                  duration: 800.ms,
                                  delay: 400.ms,
                                ),

                                SizedBox(height: 24.h),

                                // Email field - Connected to AuthCubit
                                _buildTextField(
                                  controller: authCubit.signUpEmailController,
                                  hintText: "Email",
                                  prefixIcon: Icons.email_outlined,
                                  primaryColor: primaryColor,
                                  lightColor: lightColor,
                                  delay: 500.ms,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: 12.h),

                                // Password field - Connected to AuthCubit
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    return _buildTextField(
                                      controller:
                                          authCubit.signUpPasswordController,
                                      hintText: "Password",
                                      prefixIcon: Icons.lock_outline,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: primaryColor,
                                          size: 20.sp,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                      isPassword: true,
                                      obscureText: !_isPasswordVisible,
                                      primaryColor: primaryColor,
                                      lightColor: lightColor,
                                      delay: 600.ms,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    );
                                  },
                                ),

                                SizedBox(height: 12.h),

                                // Confirm Password field - Connected to AuthCubit
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    return _buildTextField(
                                      controller:
                                          authCubit
                                              .signUpConfirmPasswordController,
                                      hintText: "Confirm Password",
                                      prefixIcon: Icons.lock_outline,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _isConfirmPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: primaryColor,
                                          size: 20.sp,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isConfirmPasswordVisible =
                                                !_isConfirmPasswordVisible;
                                          });
                                        },
                                      ),
                                      isPassword: true,
                                      obscureText: !_isConfirmPasswordVisible,
                                      primaryColor: primaryColor,
                                      lightColor: lightColor,
                                      delay: 700.ms,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please confirm your password';
                                        }
                                        if (value !=
                                            authCubit
                                                .signUpPasswordController
                                                .text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    );
                                  },
                                ),

                                SizedBox(height: 20.h),

                                // Sign up button - Connected to AuthCubit
                                ElevatedButton(
                                      onPressed:
                                          state is AuthLoading
                                              ? null
                                              : (_acceptTerms
                                                  ? () {
                                                    debugPrint(
                                                      "⚡ SignUpScreen: Sign up button pressed",
                                                    );
                                                    if (authCubit
                                                        .signUpFormKey
                                                        .currentState!
                                                        .validate()) {
                                                      debugPrint(
                                                        "⚡ SignUpScreen: Form validated, calling signUpWithFire",
                                                      );
                                                      authCubit
                                                          .signUpWithFire();
                                                    }
                                                  }
                                                  : null),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 4,
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: lightColor,
                                        minimumSize: Size(
                                          double.infinity,
                                          50.h,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            25.r,
                                          ),
                                        ),
                                        padding: EdgeInsets.zero,
                                        disabledForegroundColor: lightColor
                                            .withOpacity(0.5),
                                        disabledBackgroundColor:
                                            Colors.transparent,
                                      ),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          gradient:
                                              _acceptTerms &&
                                                      state is! AuthLoading
                                                  ? LinearGradient(
                                                    colors: [
                                                      primaryColor,
                                                      Color.lerp(
                                                            primaryColor,
                                                            accentColor,
                                                            0.6,
                                                          ) ??
                                                          primaryColor,
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )
                                                  : LinearGradient(
                                                    colors: [
                                                      primaryColor.withOpacity(
                                                        0.3,
                                                      ),
                                                      Color.lerp(
                                                            primaryColor,
                                                            accentColor,
                                                            0.6,
                                                          )?.withOpacity(0.3) ??
                                                          primaryColor
                                                              .withOpacity(0.3),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                          borderRadius: BorderRadius.circular(
                                            25.r,
                                          ),
                                          boxShadow:
                                              _acceptTerms &&
                                                      state is! AuthLoading
                                                  ? [
                                                    BoxShadow(
                                                      color: primaryColor
                                                          .withOpacity(0.4),
                                                      blurRadius: 8,
                                                      offset: const Offset(
                                                        0,
                                                        4,
                                                      ),
                                                    ),
                                                  ]
                                                  : [],
                                        ),
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: 50.h,
                                          child:
                                              state is AuthLoading
                                                  ? CircularProgressIndicator(
                                                    color: lightColor,
                                                    strokeWidth: 3,
                                                  )
                                                  : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'SIGN UP',
                                                        style: TextStyle(
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontFamily:
                                                              'Montserrat',
                                                          letterSpacing: 1.2,
                                                          color:
                                                              _acceptTerms
                                                                  ? lightColor
                                                                  : lightColor
                                                                      .withOpacity(
                                                                        0.5,
                                                                      ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 8.w),
                                                      Icon(
                                                        Icons.arrow_forward,
                                                        size: 18.sp,
                                                        color:
                                                            _acceptTerms
                                                                ? lightColor
                                                                : lightColor
                                                                    .withOpacity(
                                                                      0.5,
                                                                    ),
                                                      ),
                                                    ],
                                                  ),
                                        ),
                                      ),
                                    )
                                    .animate()
                                    .scale(
                                      duration: 800.ms,
                                      delay: 800.ms,
                                      curve: Curves.easeOutBack,
                                    )
                                    .animate(
                                      onPlay:
                                          (controller) =>
                                              _acceptTerms &&
                                                      state is! AuthLoading
                                                  ? controller.repeat(
                                                    reverse: true,
                                                  )
                                                  : controller.stop(),
                                    )
                                    .shimmer(
                                      duration: 1800.ms,
                                      color: lightColor.withOpacity(0.1),
                                      delay: 1800.ms,
                                    ),

                                SizedBox(height: 16.h),

                                // Terms checkbox
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 20.w,
                                        height: 20.h,
                                        child: Checkbox(
                                          value: _acceptTerms,
                                          onChanged: (value) {
                                            setState(() {
                                              _acceptTerms = value ?? false;
                                            });
                                          },
                                          activeColor: primaryColor,
                                          checkColor: secondaryColor,
                                          side: BorderSide(
                                            color: lightColor.withOpacity(0.6),
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4.r,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          'I agree to the Terms and Conditions',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: lightColor,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(
                                  duration: 800.ms,
                                  delay: 900.ms,
                                ),

                                SizedBox(height: 12.h),

                                // Terms text with hover effect
                                StatefulBuilder(
                                  builder: (context, setInnerState) {
                                    return GestureDetector(
                                      onTap: _showTermsAndConditions,
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        onEnter:
                                            (_) => setInnerState(() {
                                              _isTermsHovered = true;
                                            }),
                                        onExit:
                                            (_) => setInnerState(() {
                                              _isTermsHovered = false;
                                            }),
                                        child: RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            text:
                                                "By continuing, you confirm that you agree with our ",
                                            style: TextStyle(
                                              color: lightColor.withOpacity(
                                                0.7,
                                              ),
                                              fontSize: 12.sp,
                                              fontFamily: 'Montserrat',
                                            ),
                                            children: [
                                              TextSpan(
                                                text: "Terms and Conditions",
                                                style: TextStyle(
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                  decoration:
                                                      _isTermsHovered
                                                          ? TextDecoration
                                                              .underline
                                                          : TextDecoration.none,
                                                  decorationThickness: 2,
                                                  shadows:
                                                      _isTermsHovered
                                                          ? [
                                                            Shadow(
                                                              color: primaryColor
                                                                  .withOpacity(
                                                                    0.5,
                                                                  ),
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    1,
                                                                  ),
                                                              blurRadius: 2,
                                                            ),
                                                          ]
                                                          : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ).animate().fadeIn(
                                  duration: 800.ms,
                                  delay: 1000.ms,
                                ),

                                SizedBox(height: 20.h),

                                // Sign in link
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                            ) => const LoginScreen(),
                                        transitionsBuilder: (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(
                                      0.05,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Already have an account? ",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: lightColor.withOpacity(0.8),
                                        fontFamily: 'Montserrat',
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "SIGN IN",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: primaryColor,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ).animate().fadeIn(
                                  duration: 800.ms,
                                  delay: 1100.ms,
                                ),

                                SizedBox(height: 16.h),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool isPassword = false,
    bool obscureText = false,
    required Color primaryColor,
    required Color lightColor,
    required Duration delay,
    String? Function(String?)? validator,
  }) {
    return Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword && !obscureText ? true : false,
            style: TextStyle(
              color: lightColor,
              fontSize: 14.sp,
              fontFamily: 'Montserrat',
            ),
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: lightColor.withOpacity(0.5),
                fontSize: 14.sp,
                fontFamily: 'Montserrat',
              ),
              prefixIcon: Icon(prefixIcon, color: primaryColor, size: 20.sp),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
            cursorColor: primaryColor,
          ),
        )
        .animate()
        .slideX(
          duration: 800.ms,
          begin: -0.2,
          end: 0,
          delay: delay,
          curve: Curves.easeOutQuint,
        )
        .fadeIn(duration: 800.ms, delay: delay);
  }
}
