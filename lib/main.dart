import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:FitBro/models/blocs/cubit/workoutcubit.dart';
import 'package:FitBro/models/repos/data_repo.dart';
import 'package:FitBro/screens/Auth_Screen/Splash_Screen/Splash_Screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:FitBro/models/data/Local/SharedPerfrence.dart';
import 'package:FitBro/services/app_open_ad_service.dart';
import 'common/color_extension.dart';

// Create a global instance of AppOpenAdService
final AppOpenAdService appOpenAdService = AppOpenAdService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared preferences
  await LocalData.init();
  
  // Initialize ads
  await MobileAds.instance.initialize();
  
  // Load the first app open ad
  await appOpenAdService.loadAd();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
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
      // Show app open ad when the app is resumed
      appOpenAdService.showAdIfAvailable();
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
