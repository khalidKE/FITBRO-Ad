import 'package:FitBro/view/menu/menu_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/color_extension.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class YogaView extends StatefulWidget {
  const YogaView({super.key});

  @override
  State<YogaView> createState() => _YogaViewState();
}

class _YogaViewState extends State<YogaView> {
  // Define colors for consistency with MenuView
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

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
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
    final media = MediaQuery.of(context).size;

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor:
              isDarkMode
                  ? fitColors["darkBackground"]
                  : fitColors["background"],
          appBar: AppBar(
            backgroundColor: TColor.primary,
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
            title: Text(
              "Yoga",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    "assets/img/yyoga.png",
                    width: media.width,
                    height: media.width * 0.55,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IgnorePointer(
                      ignoring: true,
                      child: RatingBar.builder(
                        initialRating: 4,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 24,
                        itemPadding: const EdgeInsets.symmetric(
                          horizontal: 1.0,
                        ),
                        itemBuilder:
                            (context, _) =>
                                Icon(Icons.star, color: TColor.primary),
                        onRatingUpdate: (_) {},
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Tips",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : TColor.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),
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
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Yoga is more than just a physical practice—it's a journey of the mind, body, and breath. "
                    "By connecting movement with mindful breathing, yoga helps reduce stress, improve flexibility, and increase overall mental clarity.\n\n"
                    "Beginner Tips:\n"
                    "- Start with basic poses like Child's Pose, Downward Dog, and Mountain Pose.\n"
                    "- Don't worry about being perfect—listen to your body.\n"
                    "- Focus on your breathing—it's your guide.\n\n"
                    "Benefits:\n"
                    "- Enhances strength and flexibility\n"
                    "- Improves posture and balance\n"
                    "- Promotes better sleep and mental focus\n\n"
                    "Yoga isn't about touching your toes—it's about what you learn on the way down. "
                    "Take your time, stay consistent, and enjoy every moment on the mat.",
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color:
                          isDarkMode
                              ? Colors.white.withOpacity(0.9)
                              : TColor.secondaryText,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
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
