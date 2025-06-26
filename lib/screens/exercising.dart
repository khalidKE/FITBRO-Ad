import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Add this import
import 'package:FitBro/common/color_extension.dart';
import 'package:FitBro/models/blocs/cubit/StoreCubit/srore_cubit.dart';
import 'package:FitBro/models/blocs/cubit/workoutcubit.dart';
import 'package:FitBro/models/data/data.dart';
import 'package:FitBro/view/menu/menu_view.dart';

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({super.key});

  @override
  _WorkoutSessionScreenState createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  int currentExerciseIndex = 0;
  late List<WorkoutData> workoutDataList;
  late DateTime startTime;

  // Add reward ad
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;

  // Banner ad for this screen
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  // Define colors for consistency
  final Map<String, Color> fitColors = {
    "primary": const Color(0xFF1E5128),
    "secondary": const Color(0xFF4E9F3D),
    "accent": const Color(0xFF8FB339),
    "light": const Color(0xFFD8E9A8),
    "dark": const Color(0xFF191A19),
    "black": Colors.black,
    "background": const Color(0xFFF5F5F5),
    "darkBackground": const Color(0xFF2A2A2A),
  };

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    _loadRewardedAd();

    // Load banner ad
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-8639311525630636/6699798389',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            _isBannerAdLoaded = false;
          });
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    workoutDataList = context.read<ExerciseCubit>().workout;
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-8639311525630636/7745286740',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;

          // Set callback for ad closing
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _isRewardedAdLoaded = false;
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _isRewardedAdLoaded = false;
              ad.dispose();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Rewarded ad failed to load: ${error.message}');
          _isRewardedAdLoaded = false;
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (_, reward) {
          // Handle reward
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: fitColors["primary"],
              content: Text(
                'Congratulations! You earned a reward of ${reward.amount} ${reward.type}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      );
    } else {
      _done(); // Continue with completion if ad not available
    }
  }

  void _nextExercise() {
    if (currentExerciseIndex < workoutDataList.length - 1) {
      setState(() {
        currentExerciseIndex++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: fitColors["primary"],
          content: Text(
            'No more exercises!',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  void _done() async {
    final finishTime = DateTime.now();

    final workoutSession = WorkoutSession(
      startTime: startTime,
      finishTime: finishTime,
      workoutData: workoutDataList,
    );

    SaveCubit().setUserExcersiceInfo(
      endDate: workoutSession.finishTime.toString(),
      startDate: workoutSession.startTime.toString(),
      listWorkOuts: workoutSession.workoutData,
    );

    context.read<ExerciseCubit>().workout.clear();

    // Show congratulatory dialog with option to watch ad
    await showDialog(
      context: context,
      builder:
          (context) => ValueListenableBuilder<bool>(
            valueListenable: isDarkModeNotifier,
            builder: (context, isDarkMode, child) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor:
                    isDarkMode ? fitColors["darkBackground"] : Colors.white,
                title: Text(
                  "Congratulations!",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "You finished your workout.\nKeep going strong!",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isRewardedAdLoaded)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showRewardedAd();
                        },
                        icon: const Icon(Icons.card_giftcard),
                        label: const Text("Watch Ad for Reward"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: fitColors["secondary"],
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _navigateToMenu();
                    },
                    child: Text(
                      "Continue",
                      style: TextStyle(color: fitColors["primary"]),
                    ),
                  ),
                ],
              );
            },
          ),
    );

    if (!_isRewardedAdLoaded) {
      _navigateToMenu();
    }
  }

  void _navigateToMenu() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) => BlocProvider(
              create: (context) => SaveCubit(),
              child: const MenuView(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        if (workoutDataList.isEmpty) {
          return Scaffold(
            backgroundColor:
                isDarkMode
                    ? fitColors["darkBackground"]
                    : fitColors["background"],
            appBar: AppBar(
              title: Text(
                'Workout Session',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              backgroundColor: TColor.primary,
            ),
            body: Center(
              child: Text(
                'No exercises added.',
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            bottomNavigationBar: _isBannerAdLoaded && _bannerAd != null
                ? Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  )
                : null,
          );
        }

        final currentExercise = workoutDataList[currentExerciseIndex];

        return Scaffold(
          backgroundColor:
              isDarkMode
                  ? fitColors["darkBackground"]
                  : fitColors["background"],
          appBar: AppBar(
            backgroundColor: TColor.primary,
            elevation: 0,
            title: Text(
              'Workout Session',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            actions: [
              if (currentExerciseIndex < workoutDataList.length - 1)
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded),
                  onPressed: _nextExercise,
                  color: Colors.white,
                ),
              if (currentExerciseIndex == workoutDataList.length - 1)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: _done,
                  color: Colors.white,
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color:
                        isDarkMode ? fitColors["darkBackground"] : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          isDarkMode ? 0.2 : 0.12,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          currentExercise.exercise.image,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentExercise.exercise.name,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: TColor.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentExercise.exercise.instruction,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Weights:',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...currentExercise.weights.map(
                        (w) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            w,
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                if (currentExerciseIndex < workoutDataList.length - 1)
                  ElevatedButton(
                    onPressed: _nextExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Next Exercise',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (currentExerciseIndex == workoutDataList.length - 1)
                  ElevatedButton.icon(
                    onPressed: _done,
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      'Finish Workout',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: fitColors["secondary"],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: _isBannerAdLoaded && _bannerAd != null
              ? Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                )
              : null,
        );
      },
    );
  }
}
