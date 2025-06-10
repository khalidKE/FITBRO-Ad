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

  // Add method to check if any ad is currently showing
  bool _isShowingAd = false;

  // Add status tracking
  void _logAdStatus() {
    debugPrint('''
AdService Status:
----------------
Banner Ad: ${_isBannerAdLoaded ? 'Loaded' : 'Not Loaded'} (${_bannerAd != null ? 'Instance exists' : 'No instance'})
Interstitial Ad: ${_isInterstitialAdLoaded ? 'Loaded' : 'Not Loaded'} (${_interstitialAd != null ? 'Instance exists' : 'No instance'})
Rewarded Ad: ${_isRewardedAdLoaded ? 'Loaded' : 'Not Loaded'} (${_rewardedAd != null ? 'Instance exists' : 'No instance'})
Counter: $_interstitialAdCounter
----------------
''');
  }

  // Banner Ad Methods
  Future<void> _loadBannerAd() async {
    try {
      final adUnitId = AdMobConfig.getAdUnitId('banner', isTest: _isTestMode);
      debugPrint('AdService: Starting banner ad load with ID: $adUnitId');

      // Dispose old ad if exists
      if (_bannerAd != null) {
        debugPrint('AdService: Disposing old banner ad');
        _isBannerAdLoaded = false;
        await _bannerAd!.dispose();
        _bannerAd = null;
      }

      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            debugPrint('AdService: Banner ad loaded successfully');
            _isBannerAdLoaded = true;
            _logAdStatus();
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('AdService: Banner ad failed to load: ${error.message}');
            debugPrint('AdService: Banner ad error code: ${error.code}');
            _isBannerAdLoaded = false;
            ad.dispose();
            _bannerAd = null;
            _logAdStatus();
            // Try to reload after a delay
            Future.delayed(const Duration(minutes: 1), () {
              if (!_isBannerAdLoaded) {
                debugPrint('AdService: Attempting to reload banner ad');
                _loadBannerAd();
              }
            });
          },
        ),
      );

      debugPrint('AdService: Initiating banner ad load');
      await _bannerAd?.load();
    } catch (e, stackTrace) {
      debugPrint('AdService: Error loading banner ad: $e');
      debugPrint('AdService: Stack trace: $stackTrace');
      _isBannerAdLoaded = false;
      _bannerAd = null;
      _logAdStatus();
    }
  }

  Widget getBannerAd() {
    if (!_isBannerAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    try {
      return Container(
        width: double.infinity,
        height: _bannerAd!.size.height.toDouble(),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.grey.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              Text(
                "Advertisement",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint('AdService: Error displaying banner ad: $e');
      _isBannerAdLoaded = false;
      _bannerAd = null;
      return const SizedBox.shrink();
    }
  }

  // Interstitial Ad Methods
  Future<void> _loadInterstitialAd() async {
    try {
      final adUnitId = AdMobConfig.getAdUnitId('interstitial', isTest: _isTestMode);
      debugPrint('AdService: Starting interstitial ad load with ID: $adUnitId');

      // Dispose old ad if exists
      if (_interstitialAd != null) {
        debugPrint('AdService: Disposing old interstitial ad');
        _isInterstitialAdLoaded = false;
        await _interstitialAd!.dispose();
        _interstitialAd = null;
      }

      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('AdService: Interstitial ad loaded successfully');
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
            _logAdStatus();

            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('AdService: Interstitial ad dismissed');
                _isInterstitialAdLoaded = false;
                ad.dispose();
                _interstitialAd = null;
                _logAdStatus();
                _loadInterstitialAd(); // Load the next ad
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('AdService: Interstitial ad failed to show: ${error.message}');
                debugPrint('AdService: Interstitial ad error code: ${error.code}');
                _isInterstitialAdLoaded = false;
                ad.dispose();
                _interstitialAd = null;
                _logAdStatus();
                _loadInterstitialAd(); // Try to load another ad
              },
              onAdShowedFullScreenContent: (ad) {
                debugPrint('AdService: Interstitial ad showed successfully');
                _logAdStatus();
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdService: Interstitial ad failed to load: ${error.message}');
            debugPrint('AdService: Interstitial ad error code: ${error.code}');
            _isInterstitialAdLoaded = false;
            _interstitialAd = null;
            _logAdStatus();
            // Try to reload after a delay
            Future.delayed(const Duration(minutes: 1), () {
              if (!_isInterstitialAdLoaded) {
                debugPrint('AdService: Attempting to reload interstitial ad');
                _loadInterstitialAd();
              }
            });
          },
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('AdService: Error loading interstitial ad: $e');
      debugPrint('AdService: Stack trace: $stackTrace');
      _isInterstitialAdLoaded = false;
      _interstitialAd = null;
      _logAdStatus();
    }
  }

  void showInterstitialAd() {
    if (!_isInterstitialAdLoaded || _interstitialAd == null) {
      debugPrint('AdService: Interstitial ad not ready to show');
      return;
    }

    try {
      _interstitialAdCounter++;
      if (_interstitialAdCounter >= 3) {
        debugPrint('AdService: Showing interstitial ad');
        _interstitialAd!.show();
        _interstitialAdCounter = 0;
      }
    } catch (e) {
      debugPrint('AdService: Error showing interstitial ad: $e');
      _isInterstitialAdLoaded = false;
      _interstitialAd = null;
    }
  }

  // Rewarded Ad Methods
  Future<void> _loadRewardedAd() async {
    try {
      final adUnitId = AdMobConfig.getAdUnitId('rewarded', isTest: _isTestMode);
      debugPrint('AdService: Starting rewarded ad load with ID: $adUnitId');

      // Dispose old ad if exists
      if (_rewardedAd != null) {
        debugPrint('AdService: Disposing old rewarded ad');
        _isRewardedAdLoaded = false;
        await _rewardedAd!.dispose();
        _rewardedAd = null;
      }

      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('AdService: Rewarded ad loaded successfully');
            _rewardedAd = ad;
            _isRewardedAdLoaded = true;
            _logAdStatus();

            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('AdService: Rewarded ad dismissed');
                _isRewardedAdLoaded = false;
                ad.dispose();
                _rewardedAd = null;
                _logAdStatus();
                _loadRewardedAd(); // Load the next ad
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('AdService: Rewarded ad failed to show: ${error.message}');
                debugPrint('AdService: Rewarded ad error code: ${error.code}');
                _isRewardedAdLoaded = false;
                ad.dispose();
                _rewardedAd = null;
                _logAdStatus();
                _loadRewardedAd(); // Try to load another ad
              },
              onAdShowedFullScreenContent: (ad) {
                debugPrint('AdService: Rewarded ad showed successfully');
                _logAdStatus();
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdService: Rewarded ad failed to load: ${error.message}');
            debugPrint('AdService: Rewarded ad error code: ${error.code}');
            _isRewardedAdLoaded = false;
            _rewardedAd = null;
            _logAdStatus();
            // Try to reload after a delay
            Future.delayed(const Duration(minutes: 1), () {
              if (!_isRewardedAdLoaded) {
                debugPrint('AdService: Attempting to reload rewarded ad');
                _loadRewardedAd();
              }
            });
          },
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('AdService: Error loading rewarded ad: $e');
      debugPrint('AdService: Stack trace: $stackTrace');
      _isRewardedAdLoaded = false;
      _rewardedAd = null;
      _logAdStatus();
    }
  }

  void showRewardedAd({required Function(RewardItem) onRewarded}) {
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      debugPrint('AdService: Rewarded ad not ready to show');
      return;
    }

    try {
      debugPrint('AdService: Showing rewarded ad');
      _rewardedAd!.show(
        onUserEarnedReward: (_, reward) {
          debugPrint('AdService: User earned reward: ${reward.amount} ${reward.type}');
          onRewarded(reward);
        },
      );
    } catch (e) {
      debugPrint('AdService: Error showing rewarded ad: $e');
      _isRewardedAdLoaded = false;
      _rewardedAd = null;
    }
  }

  // Dispose ads
  Future<void> dispose() async {
    debugPrint('AdService: Disposing ads');
    try {
      if (_bannerAd != null) {
        await _bannerAd!.dispose();
        _bannerAd = null;
      }
      if (_interstitialAd != null) {
        await _interstitialAd!.dispose();
        _interstitialAd = null;
      }
      if (_rewardedAd != null) {
        await _rewardedAd!.dispose();
        _rewardedAd = null;
      }
      _isBannerAdLoaded = false;
      _isInterstitialAdLoaded = false;
      _isRewardedAdLoaded = false;
    } catch (e) {
      debugPrint('AdService: Error disposing ads: $e');
    }
  }

  // Initialize ads
  Future<void> initialize() async {
    try {
      debugPrint('AdService: Starting ad initialization');
      // Reset all states
      await dispose();
      
      // Load banner ad first since it's most important
      debugPrint('AdService: Loading banner ad');
      await _loadBannerAd();
      
      // Then load other ads with a delay to prevent startup lag
      debugPrint('AdService: Scheduling other ads to load');
      Future.delayed(const Duration(seconds: 2), () {
        debugPrint('AdService: Loading interstitial and rewarded ads');
        _loadInterstitialAd();
        _loadRewardedAd();
      });
      
      _logAdStatus();
    } catch (e, stackTrace) {
      debugPrint('AdService: Error initializing ads: $e');
      debugPrint('AdService: Stack trace: $stackTrace');
    }
  }

  // Add method to check if any ad is currently showing
  bool get isAnyAdShowing => _isShowingAd;
} 