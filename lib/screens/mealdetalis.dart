import 'package:FitBro/view/menu/menu_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:FitBro/common/color_extension.dart';
import 'package:FitBro/models/data/data.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MealDetailView extends StatefulWidget {
  final Meal meal;

  const MealDetailView({super.key, required this.meal});

  @override
  _MealDetailsScreenState createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailView> {
  late Meal meal;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    meal = widget.meal;
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
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor:
              isDarkMode ? fitColors["darkBackground"] : Colors.white,
          appBar: AppBar(
            title: Text(
              meal.name,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: TColor.primary,
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Animation for Image
                Hero(
                  tag: meal.image_url,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                    child: Image.network(
                      meal.image_url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 280,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              TColor.primary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color:
                              isDarkMode ? Colors.grey[800] : Colors.grey[200],
                          height: 280,
                          width: double.infinity,
                          child: Icon(
                            Icons.error,
                            color: isDarkMode ? Colors.white70 : Colors.black,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Text(
                    meal.name,
                    style: GoogleFonts.quicksand(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                // Calories Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Calories: ${meal.calories}',
                    style: GoogleFonts.quicksand(
                      fontSize: 20,
                      color: isDarkMode ? Colors.white70 : TColor.secondaryText,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // Ingredients List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Ingredients:',
                    style: GoogleFonts.quicksand(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: TColor.primary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    meal.ingredients.join(', '),
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // Instructions Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Instructions:',
                    style: GoogleFonts.quicksand(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: TColor.primary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    meal.instructions,
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // A simple divider for style
                Divider(
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.2)
                          : TColor.primary.withOpacity(0.2),
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          bottomNavigationBar: _isBannerAdLoaded && _bannerAd != null
              ? Container(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  alignment: Alignment.center,
                  child: AdWidget(ad: _bannerAd!),
                )
              : null,
        );
      },
    );
  }
}
