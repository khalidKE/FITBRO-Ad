import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/admob_config.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

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
    await MobileAds.instance.initialize();
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  // Banner Ad Methods
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdMobConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdLoaded = false;
          ad.dispose();
          print('Banner ad failed to load: ${error.message}');
        },
      ),
    );

    _bannerAd?.load();
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
    InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;

          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _isInterstitialAdLoaded = false;
              ad.dispose();
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _isInterstitialAdLoaded = false;
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: ${error.message}');
          _isInterstitialAdLoaded = false;
        },
      ),
    );
  }

  void showInterstitialAd() {
    _interstitialAdCounter++;
    if (_interstitialAdCounter >= 3) {
      if (_isInterstitialAdLoaded && _interstitialAd != null) {
        _interstitialAd!.show();
        _interstitialAdCounter = 0;
      }
    }
  }

  // Rewarded Ad Methods
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdMobConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;

          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _isRewardedAdLoaded = false;
              ad.dispose();
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _isRewardedAdLoaded = false;
              ad.dispose();
              _loadRewardedAd();
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

  void showRewardedAd({required Function(RewardItem) onRewarded}) {
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (_, reward) {
          onRewarded(reward);
        },
      );
    }
  }

  // Dispose ads
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
} 