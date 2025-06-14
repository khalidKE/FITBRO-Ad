import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:FitBro/models/blocs/cubit/workoutcubit.dart';
import 'package:FitBro/models/repos/data_repo.dart';
import 'package:FitBro/screens/Auth_Screen/Splash_Screen/Splash_Screen.dart';
import 'package:FitBro/models/data/Local/SharedPerfrence.dart';
import 'package:FitBro/services/app_open_ad_service.dart';
import 'package:FitBro/config/admob_config.dart';
import 'common/color_extension.dart';

// Create a global instance of AppOpenAdService
final AppOpenAdService appOpenAdService = AppOpenAdService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared preferences
  await LocalData.init();
  
  // Initialize ads with test mode disabled for production
  await AdMobConfig.initialize(isTest: false);
  
  // Load app open ad in the background to prevent startup delay
  Future.microtask(() => appOpenAdService.loadAd());
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appOpenAdService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Only show app open ad if it's not the first launch
      if (!_isFirstLaunch) {
        appOpenAdService.showAdIfAvailable();
      }
      _isFirstLaunch = false;
    }
  }

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
        home: const SplashScreen(),
      ),
    );
  }
}
