import 'package:FitBro/screens/Auth_Screen/SignUp_Screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/blocs/cubit/AuthCubit/auth_cubit.dart';
import '../../view/menu/menu_view.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  bool _isPasswordVisible = false;

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            var authCubit = AuthCubit.get(context);
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: constraints.maxHeight * 0.08),

                              // App logo
                              Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "FIT",
                                        style: TextStyle(
                                          fontSize: 32.sp,
                                          fontWeight: FontWeight.w900,
                                          color: lightColor,
                                          letterSpacing: 1.2,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                      Text(
                                        "BRO",
                                        style: TextStyle(
                                          fontSize: 32.sp,
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

                              SizedBox(height: 16.h),

                              // Fitness icon with circular background
                              Container(
                                    width: 80.w,
                                    height: 80.h,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.fitness_center,
                                      size: 40.sp,
                                      color: primaryColor,
                                    ),
                                  )
                                  .animate()
                                  .scale(
                                    duration: 800.ms,
                                    curve: Curves.easeOutBack,
                                    delay: 200.ms,
                                  )
                                  .animate(
                                    onPlay:
                                        (controller) =>
                                            controller.repeat(reverse: true),
                                  )
                                  .moveY(
                                    begin: 0,
                                    end: -10,
                                    duration: 1500.ms,
                                    curve: Curves.easeInOut,
                                  ),

                              SizedBox(height: 24.h),

                              // Welcome text
                              Text(
                                'Welcome Back!',
                                style: TextStyle(
                                  color: lightColor,
                                  fontSize: 28.sp,
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
                                'Sign in to continue your fitness journey',
                                style: TextStyle(
                                  color: lightColor.withOpacity(0.8),
                                  fontSize: 16.sp,
                                  fontFamily: 'Montserrat',
                                ),
                                textAlign: TextAlign.center,
                              ).animate().fadeIn(
                                duration: 800.ms,
                                delay: 400.ms,
                              ),

                              SizedBox(height: 40.h),

                              // Login form
                              Form(
                                key: authCubit.signInFormKey,
                                child: Column(
                                  children: [
                                    // Email field
                                    _buildTextField(
                                      controller:
                                          authCubit.signInEmailController,
                                      hintText: 'Email',
                                      labelText: 'Email',
                                      prefixIcon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
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
                                      onChanged: (value) {
                                        authCubit.signInEmailController.text =
                                            value;
                                      },
                                      obscureText: false,
                                      primaryColor: primaryColor,
                                      lightColor: lightColor,
                                      delay: 500.ms,
                                    ),

                                    SizedBox(height: 16.h),

                                    // Password field
                                    StatefulBuilder(
                                      builder: (context, setState) {
                                        return _buildTextField(
                                          controller:
                                              authCubit
                                                  .signInPasswordController,
                                          hintText: 'Password',
                                          labelText: 'Password',
                                          prefixIcon: Icons.lock_outline,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isPasswordVisible
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: primaryColor,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isPasswordVisible =
                                                    !_isPasswordVisible;
                                              });
                                            },
                                          ),
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          textInputAction: TextInputAction.done,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter your password';
                                            }
                                            if (value.length < 6) {
                                              return 'Password must be at least 6 characters';
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            authCubit
                                                .signInPasswordController
                                                .text = value;
                                          },
                                          obscureText: !_isPasswordVisible,
                                          primaryColor: primaryColor,
                                          lightColor: lightColor,
                                          delay: 700.ms,
                                        );
                                      },
                                    ),

                                    SizedBox(height: 16.h),

                                    // Forgot password
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () async {
                                          final email =
                                              authCubit
                                                  .signInEmailController
                                                  .text
                                                  .trim();
                                          if (email.isEmpty) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Please enter your email',
                                                  style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                  ),
                                                ),
                                                backgroundColor: secondaryColor,
                                              ),
                                            );
                                            return;
                                          }
                                          try {
                                            await FirebaseAuth.instance
                                                .sendPasswordResetEmail(
                                                  email: email,
                                                );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Password reset email sent',
                                                  style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                  ),
                                                ),
                                                backgroundColor: primaryColor,
                                              ),
                                            );
                                          } catch (e) {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    title: Text(
                                                      'Error',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    content: Text(
                                                      'Failed to send reset email. Please check your email and try again.',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.pop(
                                                              context,
                                                            ),
                                                        child: Text(
                                                          'OK',
                                                          style: TextStyle(
                                                            color: primaryColor,
                                                            fontFamily:
                                                                'Montserrat',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 4.h,
                                          ),
                                        ),
                                        child: Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: primaryColor,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ).animate().fadeIn(
                                      duration: 800.ms,
                                      delay: 900.ms,
                                    ),

                                    SizedBox(height: 32.h),

                                    // Sign in button
                                    BlocConsumer<AuthCubit, AuthState>(
                                      listener: (context, state) {
                                        if (state is AuthSuccess) {
                                          Navigator.pushReplacement(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder:
                                                  (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                  ) => BlocProvider(
                                                    create:
                                                        (context) =>
                                                            AuthCubit()
                                                              ..getUserInfoFire(),
                                                    child: const MenuView(),
                                                  ),
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
                                        } else if (state is AuthError) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "🚫 Login Failed Incorrect email or password. Please check your credentials and try again.",
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                ),
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                      builder: (context, state) {
                                        return ElevatedButton(
                                              onPressed:
                                                  state is AuthLoading
                                                      ? null
                                                      : () {
                                                        if (authCubit
                                                            .signInFormKey
                                                            .currentState!
                                                            .validate()) {
                                                          authCubit
                                                              .signInWithFire();
                                                        }
                                                      },
                                              style: ElevatedButton.styleFrom(
                                                elevation: 4,
                                                backgroundColor:
                                                    Colors.transparent,
                                                foregroundColor: lightColor,
                                                minimumSize: Size(
                                                  double.infinity,
                                                  56.h,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        28.r,
                                                      ),
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Ink(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
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
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        28.r,
                                                      ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: primaryColor
                                                          .withOpacity(0.4),
                                                      blurRadius: 12,
                                                      offset: const Offset(
                                                        0,
                                                        6,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: 56.h,
                                                  child:
                                                      state is AuthLoading
                                                          ? SizedBox(
                                                            width: 24.w,
                                                            height: 24.h,
                                                            child: const CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                    Color
                                                                  >(
                                                                    Colors
                                                                        .white,
                                                                  ),
                                                            ),
                                                          )
                                                          : Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                'SIGN IN',
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      18.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontFamily:
                                                                      'Montserrat',
                                                                  letterSpacing:
                                                                      1.2,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 8.w,
                                                              ),
                                                              Icon(
                                                                Icons
                                                                    .arrow_forward,
                                                                size: 20.sp,
                                                              ),
                                                            ],
                                                          ),
                                                ),
                                              ),
                                            )
                                            .animate()
                                            .scale(
                                              duration: 800.ms,
                                              delay: 1100.ms,
                                              curve: Curves.easeOutBack,
                                            )
                                            .animate(
                                              onPlay:
                                                  (controller) => controller
                                                      .repeat(reverse: true),
                                            )
                                            .shimmer(
                                              duration: 1800.ms,
                                              color: lightColor.withOpacity(
                                                0.1,
                                              ),
                                              delay: 1800.ms,
                                            );
                                      },
                                    ),

                                    SizedBox(height: 32.h),

                                    // Sign up link
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
                                                ) => const SignUpScreen(),
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
                                      child: Text.rich(
                                        TextSpan(
                                          text: "Don't have an account? ",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: lightColor.withOpacity(0.8),
                                            fontFamily: 'Montserrat',
                                          ),
                                          children: [
                                            TextSpan(
                                              text: "SIGN UP",
                                              style: TextStyle(
                                                fontSize: 16.sp,
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
                                      delay: 1300.ms,
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 24.h),
                            ],
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
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    required TextInputType keyboardType,
    required TextInputAction textInputAction,
    required String? Function(String?) validator,
    required void Function(String) onChanged,
    required bool obscureText,
    required Color primaryColor,
    required Color lightColor,
    required Duration delay,
  }) {
    return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            labelStyle: TextStyle(
              color: lightColor.withOpacity(0.7),
              fontSize: 16.sp,
              fontFamily: 'Montserrat',
            ),
            hintStyle: TextStyle(
              color: lightColor.withOpacity(0.5),
              fontSize: 16.sp,
              fontFamily: 'Montserrat',
            ),
            prefixIcon: Icon(prefixIcon, color: primaryColor, size: 22.sp),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
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
              borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            errorStyle: TextStyle(
              color: Colors.red.shade300,
              fontFamily: 'Montserrat',
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
          style: TextStyle(
            color: lightColor,
            fontSize: 16.sp,
            fontFamily: 'Montserrat',
          ),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          obscureText: obscureText,
          cursorColor: primaryColor,
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
