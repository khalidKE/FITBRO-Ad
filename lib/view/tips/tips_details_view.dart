import "package:FitBro/view/menu/menu_view.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:google_mobile_ads/google_mobile_ads.dart"; // Add this import
import "../../common/color_extension.dart";

class TipsDetailView extends StatefulWidget {
  final Map<String, dynamic> tObj;
  const TipsDetailView({super.key, required this.tObj});

  @override
  State<TipsDetailView> createState() => _TipsDetailViewState();
}

class _TipsDetailViewState extends State<TipsDetailView> {
  // Define colors for consistency
  final Map<String, Color> fitColors = {
    "primary": const Color(0xFF1E5128),
    "secondary": const Color(0xFF4E9F3D),
    "accent": const Color(0xFF8FB339),
    "light": const Color(0xFFD8E9A8),
    "dark": const Color(0xFF191A19),
    "black": Colors.black,
    "background": const Color(0xFFF9F9F9),
    "darkBackground": const Color(0xFF2A2A2A),
  };

  // Add banner ad
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    const adUnitId = "ca-app-pub-8639311525630636/6699798389";
    const size = AdSize.banner;
    const request = AdRequest();
    final listener = BannerAdListener(
      onAdLoaded: (_) {
        setState(() {
          _isBannerAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        print('Ad failed to load: ${error.message}');
      },
    );

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: request,
      listener: listener,
    );

    _bannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor:
              isDarkMode
                  ? fitColors["darkBackground"]
                  : const Color(0xFFF9F9F9),
          appBar: AppBar(
            backgroundColor: TColor.primary,
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
            title: Text(
              "Fitness Tips",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/img/5.png",
                        width: media.width,
                        height: media.width * 0.55,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            widget.tObj["name"],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : TColor.secondaryText,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Customized content based on the title of the tip
                      _buildSection(
                        title: widget.tObj["name"],
                        content: _getCustomContent(widget.tObj["name"]),
                        isDarkMode: isDarkMode, // Pass isDarkMode
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Add banner ad at the bottom - using the same system as WorkoutDetailView
              if (_isBannerAdLoaded)
                Container(
                  alignment: Alignment.center,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              const SizedBox(
                height: 60,
              ), // Add space below the ad to avoid navigation buttons
            ],
          ),
        );
      },
    );
  }

  String _getCustomContent(String title) {
    switch (title) {
      case "About Training":
        return "Effective training goes beyond the physical effort. It's about consistency, proper techniques, and balance between strength and flexibility. Focus on creating a routine that includes rest and active recovery days to avoid burnout. Build intensity gradually, and always listen to your body to avoid injury.";

      case "How to Weight Loss?":
        return """Achieving sustainable weight loss requires a comprehensive approach:

1. Caloric Deficit: Create a moderate caloric deficit of 500-700 calories per day for healthy weight loss of 0.5-1kg per week.

2. Exercise Strategy:
   • Combine cardio (30-45 minutes, 4-5 times/week) with strength training (3-4 times/week)
   • High-Intensity Interval Training (HIIT) for efficient fat burning
   • Focus on compound exercises like squats, deadlifts, and push-ups

3. Nutrition Guidelines:
   • Prioritize protein (1.6-2.2g per kg of body weight)
   • Include complex carbohydrates for energy
   • Healthy fats for hormone production
   • Stay hydrated (2-3 liters of water daily)

4. Lifestyle Factors:
   • Get 7-9 hours of quality sleep
   • Manage stress through meditation or yoga
   • Track progress with measurements and photos
   • Stay consistent and patient with the process""";

      case "Introducing Meal Plan":
        return """A well-structured meal plan is essential for fitness success. Here's a comprehensive guide:

1. Daily Meal Structure:
   • Breakfast: Complex carbs + protein (e.g., oatmeal with protein)
   • Mid-morning: Protein-rich snack (e.g., Greek yogurt)
   • Lunch: Balanced meal with protein, carbs, and vegetables
   • Pre-workout: Light carb + protein (e.g., banana with nuts)
   • Post-workout: Protein + fast carbs (e.g., protein shake with fruit)
   • Dinner: Protein + vegetables + healthy fats

2. Macronutrient Distribution:
   • Protein: 30-40% of daily calories
   • Carbohydrates: 40-50% of daily calories
   • Fats: 20-30% of daily calories

3. Meal Timing:
   • Eat every 3-4 hours
   • Pre-workout meal 1-2 hours before training
   • Post-workout meal within 30 minutes
   • Last meal 2-3 hours before sleep

4. Food Choices:
   • Lean proteins: chicken, fish, tofu, legumes
   • Complex carbs: brown rice, quinoa, sweet potatoes
   • Healthy fats: avocado, nuts, olive oil
   • Vegetables: colorful variety for micronutrients""";

      case "Water and Food":
        return "Proper hydration and a healthy diet are the pillars of good health. Drink water regularly to maintain hydration, especially during workouts. Pair your meals with hydration-rich foods like fruits and vegetables, which contribute to both hydration and nutrition. Stay mindful of your food choices, as they directly impact your energy and recovery after workouts.";

      case "Drink Water":
        return """Proper hydration is crucial for optimal performance and health. Here's a comprehensive guide:

1. Daily Water Intake:
   • Base requirement: 30-35ml per kg of body weight
   • Add 500ml for every hour of exercise
   • Increase intake in hot weather or high altitude

2. Hydration Timing:
   • Morning: 500ml upon waking
   • Pre-workout: 250-500ml 2-3 hours before
   • During workout: 200-300ml every 15-20 minutes
   • Post-workout: 500ml within 30 minutes
   • Before meals: 250ml 30 minutes before
   • Before bed: 250ml 1 hour before

3. Signs of Dehydration:
   • Dark yellow urine
   • Dry mouth and lips
   • Headaches
   • Fatigue
   • Dizziness
   • Muscle cramps

4. Hydration Tips:
   • Carry a water bottle
   • Set hourly reminders
   • Add lemon or mint for flavor
   • Monitor urine color
   • Include water-rich foods (cucumber, watermelon)""";

      case "How Many Times a Day to Eat":
        return """Optimal meal frequency depends on your goals and lifestyle. Here's a detailed breakdown:

1. For Weight Loss:
   • 3 main meals + 2 snacks
   • 4-5 hours between meals
   • 2-3 hours between snacks
   • Total daily meals: 5-6
   • Portion control is crucial

2. For Muscle Gain:
   • 3 main meals + 3 snacks
   • 3-4 hours between meals
   • 2-2.5 hours between snacks
   • Total daily meals: 6-7
   • Focus on protein distribution

3. For Maintenance:
   • 3 main meals + 1-2 snacks
   • 4-5 hours between meals
   • Total daily meals: 4-5
   • Balanced macronutrients

4. Meal Timing Guidelines:
   • Breakfast: Within 1 hour of waking
   • Pre-workout: 1-2 hours before
   • Post-workout: Within 30 minutes
   • Last meal: 2-3 hours before sleep
   • Snacks: Between main meals

5. Important Considerations:
   • Listen to your hunger cues
   • Maintain consistent meal times
   • Adjust based on activity level
   • Consider your schedule
   • Quality over quantity""";

      case "Become Stronger":
        return """Building strength requires a systematic approach. Here's a comprehensive guide:

1. Training Principles:
   • Progressive overload
   • Compound exercises
   • Proper form and technique
   • Adequate rest between sets
   • Consistent training schedule

2. Essential Exercises:
   • Lower Body:
     - Squats (back, front, goblet)
     - Deadlifts (conventional, Romanian)
     - Lunges (walking, reverse, lateral)
     - Calf raises
   
   • Upper Body:
     - Bench press
     - Overhead press
     - Pull-ups/Chin-ups
     - Rows (barbell, dumbbell)
     - Push-ups variations

3. Training Frequency:
   • Beginners: 3-4 times per week
   • Intermediate: 4-5 times per week
   • Advanced: 5-6 times per week
   • Rest days: 1-2 days per week

4. Set and Rep Schemes:
   • Strength: 3-5 sets, 3-5 reps
   • Hypertrophy: 3-4 sets, 8-12 reps
   • Endurance: 2-3 sets, 15-20 reps
   • Rest: 2-5 minutes between sets

5. Recovery and Nutrition:
   • Protein: 1.6-2.2g per kg body weight
   • Sleep: 7-9 hours per night
   • Hydration: 3-4 liters daily
   • Rest days: Active recovery
   • Proper warm-up and cool-down""";

      case "Shoes for Training":
        return "Choosing the right shoes is essential to prevent injury and optimize performance. For yoga, lightweight, flexible shoes or even going barefoot is ideal for proper balance. For other workouts, such as running or weightlifting, look for shoes that offer support, cushioning, and stability to match the type of activity you're engaging in.";

      case "Appeal Tips":
        return "In fitness, confidence is key. Wear comfortable, moisture-wicking clothing that allows you to move freely and comfortably. Choose breathable fabrics to keep you cool during intense workouts, and invest in proper gear like a good sports bra or supportive leggings for added comfort. When you feel good in your workout gear, you'll be more motivated to push yourself further.";

      default:
        return "Fitness tips are designed to help you reach your personal health goals. Stay consistent, focus on balance, and ensure your body gets the nutrition, hydration, and rest it needs for optimal performance.";
    }
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TColor.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: isDarkMode ? Colors.white70 : TColor.secondaryText,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
