import 'package:FitBro/view/menu/menu_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:FitBro/models/data/data.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Add this import
import '../../common/color_extension.dart';

class WorkoutDetailView extends StatefulWidget {
  final Exercise exercise;
  const WorkoutDetailView({super.key, required this.exercise});

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView> {
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
    "white": Colors.white,
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
          print('Ad failed to load: ${error.message}');
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

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
            elevation: 0.1,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Image.asset(
                "assets/img/black_white.png",
                width: 25,
                height: 25,
              ),
            ),
            title: Text(
              overflow: TextOverflow.ellipsis,
              widget.exercise.name,
              style: TextStyle(
                color: TColor.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
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
                      CachedNetworkImage(
                        imageUrl: widget.exercise.image,
                        width: media.width,
                        height: media.width * 0.55,
                        fit: BoxFit.cover,
                        errorWidget:
                            (context, url, error) => Container(
                              width: media.width,
                              height: media.width * 0.55,
                              color:
                                  isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey.shade300,
                              child: Icon(
                                Icons.error,
                                color:
                                    isDarkMode
                                        ? fitColors["white"]
                                        : Colors.black,
                                size: 50,
                              ),
                            ),
                        placeholder:
                            (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: TColor.primary,
                              ),
                            ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            RatingBar.builder(
                              initialRating: 4,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 25,
                              itemPadding: const EdgeInsets.symmetric(
                                horizontal: 1.0,
                              ),
                              itemBuilder:
                                  (context, _) =>
                                      Icon(Icons.star, color: TColor.primary),
                              onRatingUpdate: (rating) {},
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                Share.share(
                                  '${widget.exercise.name}\n\nCheck this out: ${widget.exercise.image}\n\nInstructions: ${widget.exercise.instruction}',
                                  subject: 'Workout: ${widget.exercise.name}',
                                );
                              },
                              icon: Icon(
                                Icons.share,
                                color:
                                    isDarkMode
                                        ? fitColors["white"]
                                        : Colors.blueGrey,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Instructions",
                              style: TextStyle(
                                color:
                                    isDarkMode
                                        ? fitColors["white"]
                                        : TColor.secondaryText,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                widget.exercise.instruction,
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? fitColors["white"]
                                          : TColor.secondaryText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Add banner ad at the bottom
              if (_isBannerAdLoaded)
                Container(
                  alignment: Alignment.center,
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }
}
