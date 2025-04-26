import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:FitBro/models/blocs/cubit/workoutcubit.dart';
import 'package:FitBro/models/repos/data_repo.dart';
import 'package:FitBro/screens/Auth_Screen/Splash_Screen/Splash_Screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'common/color_extension.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/data/Local/SharedPerfrence.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  LocalData.init();
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExerciseCubit(DataRepo())..fetchdata(),
      child: MaterialApp(
        title: 'Workout Fitness',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "Quicksand",
          colorScheme: ColorScheme.fromSeed(seedColor: TColor.primary),
          useMaterial3: true,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
