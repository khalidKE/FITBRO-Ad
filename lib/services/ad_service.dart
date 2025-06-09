import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/admob_config.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  final bool _isTestMode = false; // Set to false for production

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  // Interstitial Ad
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  int _interstitialAdCounter = 0;

  // Rewarded Ad
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  // Initialize ads
  Future<void> initialize() async {
    try {
      _loadBannerAd();
      _loadInterstitialAd();
      _loadRewardedAd();
    } catch (e) {
      debugPrint('AdService: Error initializing ads: $e');
    }
  }

  // Banner Ad Methods
  void _loadBannerAd() {
    try {
      final adUnitId = AdMobConfig.getAdUnitId('banner', isTest: _isTestMode);
      debugPrint('AdService: Loading banner ad with ID: $adUnitId');

      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            debugPrint('AdService: Banner ad loaded successfully');
            _isBannerAdLoaded = true;
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('AdService: Banner ad failed to load: ${error.message}');
            _isBannerAdLoaded = false;
            ad.dispose();
            // Try to reload after a delay
            Future.delayed(const Duration(minutes: 1), () {
              _loadBannerAd();
            });
          },
        ),
      );

      _bannerAd?.load();
    } catch (e) {
      debugPrint('AdService: Error loading banner ad: $e');
      _isBannerAdLoaded = false;
    }
  }

  Widget getBannerAd() {
    if (_isBannerAdLoaded && _bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }

  // Interstitial Ad Methods
  void _loadInterstitialAd() {
    try {
      final adUnitId = AdMobConfig.getAdUnitId('interstitial', isTest: _isTestMode);
      debugPrint('AdService: Loading interstitial ad with ID: $adUnitId');

      InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('AdService: Interstitial ad loaded successfully');
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;

            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('AdService: Interstitial ad dismissed');
                _isInterstitialAdLoaded = false;
                ad.dispose();
                _loadInterstitialAd(); // Load the next ad
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('AdService: Interstitial ad failed to show: ${error.message}');
                _isInterstitialAdLoaded = false;
                ad.dispose();
                _loadInterstitialAd(); // Try to load another ad
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdService: Interstitial ad failed to load: ${error.message}');
            _isInterstitialAdLoaded = false;
            // Try to reload after a delay
            Future.delayed(const Duration(minutes: 1), () {
              _loadInterstitialAd();
            });
          },
        ),
      );
    } catch (e) {
      debugPrint('AdService: Error loading interstitial ad: $e');
      _isInterstitialAdLoaded = false;
    }
  }

  void showInterstitialAd() {
    _interstitialAdCounter++;
    if (_interstitialAdCounter >= 3) {
      if (_isInterstitialAdLoaded && _interstitialAd != null) {
        debugPrint('AdService: Showing interstitial ad');
        _interstitialAd!.show();
        _interstitialAdCounter = 0;
      } else {
        debugPrint('AdService: Interstitial ad not ready to show');
      }
    }
  }

  // Rewarded Ad Methods
  void _loadRewardedAd() {
    try {
      final adUnitId = AdMobConfig.getAdUnitId('rewarded', isTest: _isTestMode);
      debugPrint('AdService: Loading rewarded ad with ID: $adUnitId');

      RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('AdService: Rewarded ad loaded successfully');
            _rewardedAd = ad;
            _isRewardedAdLoaded = true;

            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('AdService: Rewarded ad dismissed');
                _isRewardedAdLoaded = false;
                ad.dispose();
                _loadRewardedAd(); // Load the next ad
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('AdService: Rewarded ad failed to show: ${error.message}');
                _isRewardedAdLoaded = false;
                ad.dispose();
                _loadRewardedAd(); // Try to load another ad
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdService: Rewarded ad failed to load: ${error.message}');
            _isRewardedAdLoaded = false;
            // Try to reload after a delay
            Future.delayed(const Duration(minutes: 1), () {
              _loadRewardedAd();
            });
          },
        ),
      );
    } catch (e) {
      debugPrint('AdService: Error loading rewarded ad: $e');
      _isRewardedAdLoaded = false;
    }
  }

  void showRewardedAd({required Function(RewardItem) onRewarded}) {
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      debugPrint('AdService: Showing rewarded ad');
      _rewardedAd!.show(
        onUserEarnedReward: (_, reward) {
          debugPrint('AdService: User earned reward: ${reward.amount} ${reward.type}');
          onRewarded(reward);
        },
      );
    } else {
      debugPrint('AdService: Rewarded ad not ready to show');
    }
  }

  // Dispose ads
  void dispose() {
    debugPrint('AdService: Disposing ads');
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
} 