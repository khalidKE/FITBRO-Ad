import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:FitBro/intro.dart';
import 'package:FitBro/models/blocs/cubit/AuthCubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../models/data/Local/SharedKeys.dart';
import '../../../models/data/Local/SharedPerfrence.dart';
import '../../../view/menu/menu_view.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSplashScreen(
        splash: LottieBuilder.asset('assets/Lottie/splash.json'),
        // using LocalData to check if user is logged in or not
        nextScreen:
            LocalData.getData(key: SharedKey.uid) == null
                ? const IntroductionScreen()
                : BlocProvider(
                  create: (context) => AuthCubit()..getUserInfoFire(),
                  child: const MenuView(),
                ),
        splashTransition: SplashTransition.sizeTransition,
        duration: 500,
      ),
    );
  }
}
