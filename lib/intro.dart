import 'dart:async';
import 'package:FitBro/view/menu/menu_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MenuView()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF22C55E),
                  Color(0xFF16A34A),
                ], // Use FitBro's primary gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image(
                    image: const AssetImage("assets/img/3.png"),
                    fit: BoxFit.cover,
                    color: Colors.white.withOpacity(
                      0.2,
                    ), // Subtle overlay effect
                    colorBlendMode: BlendMode.overlay,
                  ).animate().fadeIn(duration: 1000.ms),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome to FitBro 💪",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Quicksand',
                          ),
                        ).animate().slideX(
                          duration: 800.ms,
                          begin: -0.5,
                          end: 0,
                          curve: Curves.easeOut,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "Your Fitness Journey Starts Here",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Quicksand',
                          ),
                        ).animate().slideX(
                          duration: 800.ms,
                          delay: 200.ms,
                          begin: -0.5,
                          end: 0,
                          curve: Curves.easeOut,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "Transform your body with expert workouts and personalized plans!",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Quicksand',
                          ),
                        ).animate().fadeIn(duration: 800.ms, delay: 400.ms),
                        SizedBox(height: 80.h),
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
  }
}
