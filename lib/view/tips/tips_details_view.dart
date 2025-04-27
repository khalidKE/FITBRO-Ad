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
        return "Weight loss is a combination of reducing caloric intake and increasing physical activity. A balanced approach that includes regular workouts such as yoga, cardio, and strength training, along with a healthy diet, can effectively help you lose weight. Focus on whole foods, stay hydrated, and ensure you get enough sleep to support your weight loss goals.";

      case "Introducing Meal Plan":
        return "A well-structured meal plan is crucial for achieving fitness goals. Include a balance of macronutrients—proteins, carbohydrates, and healthy fats. Opt for lean proteins like chicken, tofu, or legumes, complex carbs like brown rice, and healthy fats from avocado or nuts. Plan meals ahead to avoid unhealthy food choices and maintain energy levels throughout the day.";

      case "Water and Food":
        return "Proper hydration and a healthy diet are the pillars of good health. Drink water regularly to maintain hydration, especially during workouts. Pair your meals with hydration-rich foods like fruits and vegetables, which contribute to both hydration and nutrition. Stay mindful of your food choices, as they directly impact your energy and recovery after workouts.";

      case "Drink Water":
        return "Water is essential for regulating body temperature, aiding digestion, and supporting overall performance. Make sure to drink at least 2 liters of water daily, and more if you're active. Keep a water bottle with you during your yoga or workout sessions to sip throughout. Drinking before meals helps curb hunger and improve digestion.";

      case "How Many Times a Day to Eat":
        return "Eating frequency can vary based on personal preference, but generally, eating 3 balanced meals with 2 snacks throughout the day can help maintain energy and support muscle recovery. Focus on nutrient-dense foods and avoid long gaps between meals to ensure your body has the fuel it needs for performance and recovery.";

      case "Become Stronger":
        return "To build strength, consistency is key. Include strength training exercises like squats, push-ups, and yoga poses such as plank and Warrior poses. It's important to progressively increase intensity while allowing your muscles time to recover. Pair your workouts with adequate protein intake for muscle repair and growth.";

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
