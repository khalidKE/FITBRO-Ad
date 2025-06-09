import 'dart:async';
import 'package:FitBro/models/blocs/cubit/StoreCubit/srore_cubit.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:FitBro/intro.dart';
import 'package:FitBro/view/menu/menu_view.dart';
import '../../../models/data/Local/SharedKeys.dart';
import '../../../models/data/Local/SharedPerfrence.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSplashScreen(
        splash: LottieBuilder.asset('assets/Lottie/splash.json'),
        nextScreen: FutureBuilder<Widget>(
          future: _getNextScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return snapshot.data ?? const MenuView();
          },
        ),
        splashTransition: SplashTransition.sizeTransition,
        duration: 500,
      ),
    );
  }

  Future<Widget> _getNextScreen() async {
    // Check if user is logged in
    final isLoggedIn = await LocalData.getData(key: SharedKey.uid) != null;
    
    if (isLoggedIn) {
      // If logged in, go directly to menu
      return BlocProvider(
        create: (context) => SaveCubit(),
        child: const MenuView(),
      );
    } else {
      // If not logged in, show intro screen with ad
      return const IntroductionScreen();
    }
  }
}
