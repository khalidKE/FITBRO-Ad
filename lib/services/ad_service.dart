import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/admob_config.dart';

class AdService extends ChangeNotifier {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Change to true temporarily to test ads
  final bool _isTestMode = false; // Set to true for testing

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool get isBannerAdLoaded => _isBannerAdLoaded;
  
  // Add getters for banner dimensions
  double get bannerWidth => _bannerAd?.size.width.toDouble() ?? 320;
  double get bannerHeight => _bannerAd?.size.height.toDouble() ?? 50;

  // Interstitial Ad
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  int _interstitialAdCounter = 0;

  // Rewarded Ad
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;

  // Rewarded Interstitial Ad
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _isRewardedInterstitialAdLoaded = false;
  bool get isRewardedInterstitialAdLoaded => _isRewardedInterstitialAdLoaded;

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
Rewarded Interstitial Ad: ${_isRewardedInterstitialAdLoaded ? 'Loaded' : 'Not Loaded'} (${_rewardedInterstitialAd != null ? 'Instance exists' : 'No instance'})
Counter: $_interstitialAdCounter
----------------
''');
  }

  // Banner Ad Methods
  Future<void> _loadBannerAd() async {
    try {
      debugPrint('AdService: Starting banner ad load');
      
      // Dispose old ad if exists
      if (_bannerAd != null) {
        await _bannerAd!.dispose();
        _bannerAd = null;
        _isBannerAdLoaded = false;
        notifyListeners();
      }

      // Get test ad unit ID
      final adUnitId = _isTestMode 
          ? 'ca-app-pub-3940256099942544/6300978111'  // Test banner ad unit ID
          : AdMobConfig.getAdUnitId('banner', isTest: false);

      debugPrint('AdService: Loading banner ad with ID: $adUnitId');

      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('AdService: Banner ad loaded successfully');
            _isBannerAdLoaded = true;
            notifyListeners();
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('AdService: Banner ad failed to load: ${error.message}');
            _isBannerAdLoaded = false;
            ad.dispose();
            _bannerAd = null;
            notifyListeners();
            
            // Retry after 5 seconds
            Future.delayed(const Duration(seconds: 5), () {
              if (!_isBannerAdLoaded) {
                _loadBannerAd();
              }
            });
          },
        ),
      );

      await _bannerAd?.load();
    } catch (e) {
      debugPrint('AdService: Error loading banner ad: $e');
      _isBannerAdLoaded = false;
      _bannerAd = null;
      notifyListeners();
    }
  }

  Widget getBannerAd() {
    if (!_isBannerAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }

  // Dispose only the banner ad
  Future<void> disposeBannerAd() async {
    if (_bannerAd != null) {
      await _bannerAd!.dispose();
      _bannerAd = null;
      _isBannerAdLoaded = false;
      notifyListeners();
    }
  }

  // Public method to initialize (load) the banner ad
  Future<void> initializeBannerAd() async {
    await _loadBannerAd();
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
        notifyListeners();
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
            notifyListeners();

            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('AdService: Interstitial ad dismissed');
                _isInterstitialAdLoaded = false;
                ad.dispose();
                _interstitialAd = null;
                _logAdStatus();
                notifyListeners();
                _loadInterstitialAd(); // Load the next ad
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('AdService: Interstitial ad failed to show: ${error.message}');
                debugPrint('AdService: Interstitial ad error code: ${error.code}');
                _isInterstitialAdLoaded = false;
                ad.dispose();
                _interstitialAd = null;
                _logAdStatus();
                notifyListeners();
                _loadInterstitialAd(); // Try to load another ad
              },
              onAdShowedFullScreenContent: (ad) {
                debugPrint('AdService: Interstitial ad showed successfully');
                _logAdStatus();
                notifyListeners();
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdService: Interstitial ad failed to load: ${error.message}');
            debugPrint('AdService: Interstitial ad error code: ${error.code}');
            _isInterstitialAdLoaded = false;
            _interstitialAd = null;
            _logAdStatus();
            notifyListeners();
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
      notifyListeners();
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
        notifyListeners();
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
            notifyListeners();

            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('AdService: Rewarded ad dismissed');
                _isRewardedAdLoaded = false;
                ad.dispose();
                _rewardedAd = null;
                _logAdStatus();
                notifyListeners();
                _loadRewardedAd(); // Load the next ad
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('AdService: Rewarded ad failed to show: ${error.message}');
                debugPrint('AdService: Rewarded ad error code: ${error.code}');
                _isRewardedAdLoaded = false;
                ad.dispose();
                _rewardedAd = null;
                _logAdStatus();
                notifyListeners();
                _loadRewardedAd(); // Try to load another ad
              },
              onAdShowedFullScreenContent: (ad) {
                debugPrint('AdService: Rewarded ad showed successfully');
                _logAdStatus();
                notifyListeners();
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdService: Rewarded ad failed to load: ${error.message}');
            debugPrint('AdService: Rewarded ad error code: ${error.code}');
            _isRewardedAdLoaded = false;
            _rewardedAd = null;
            _logAdStatus();
            notifyListeners();
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
      notifyListeners();
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

  // Rewarded Interstitial Ad Methods
  Future<void> loadRewardedInterstitialAd() async {
    try {
      final adUnitId = 'ca-app-pub-8639311525630636/4073408071';
      debugPrint('AdService: Loading RewardedInterstitialAd with ID: $adUnitId');
      if (_rewardedInterstitialAd != null) {
        await _rewardedInterstitialAd!.dispose();
        _rewardedInterstitialAd = null;
        _isRewardedInterstitialAdLoaded = false;
      }
      await RewardedInterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('AdService: RewardedInterstitialAd loaded');
            _rewardedInterstitialAd = ad;
            _isRewardedInterstitialAdLoaded = true;
            notifyListeners();
            _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('AdService: RewardedInterstitialAd dismissed');
                _isRewardedInterstitialAdLoaded = false;
                ad.dispose();
                _rewardedInterstitialAd = null;
                notifyListeners();
                loadRewardedInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('AdService: RewardedInterstitialAd failed to show: ${error.message}');
                _isRewardedInterstitialAdLoaded = false;
                ad.dispose();
                _rewardedInterstitialAd = null;
                notifyListeners();
                loadRewardedInterstitialAd();
              },
              onAdShowedFullScreenContent: (ad) {
                debugPrint('AdService: RewardedInterstitialAd showed');
                notifyListeners();
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdService: RewardedInterstitialAd failed to load: ${error.message}');
            _isRewardedInterstitialAdLoaded = false;
            _rewardedInterstitialAd = null;
            notifyListeners();
            // Retry after 30 seconds
            Future.delayed(const Duration(seconds: 30), () {
              if (!_isRewardedInterstitialAdLoaded) {
                loadRewardedInterstitialAd();
              }
            });
          },
        ),
      );
    } catch (e) {
      debugPrint('AdService: Error loading RewardedInterstitialAd: $e');
      _isRewardedInterstitialAdLoaded = false;
      _rewardedInterstitialAd = null;
      notifyListeners();
    }
  }

  void showRewardedInterstitialAd({required Function(RewardItem) onRewarded}) {
    if (!_isRewardedInterstitialAdLoaded || _rewardedInterstitialAd == null) {
      debugPrint('AdService: RewardedInterstitialAd not ready to show');
      return;
    }
    try {
      debugPrint('AdService: Showing RewardedInterstitialAd');
      _rewardedInterstitialAd!.show(
        onUserEarnedReward: (_, reward) {
          debugPrint('AdService: User earned reward from RewardedInterstitialAd: ${reward.amount} ${reward.type}');
          onRewarded(reward);
        },
      );
    } catch (e) {
      debugPrint('AdService: Error showing RewardedInterstitialAd: $e');
      _isRewardedInterstitialAdLoaded = false;
      _rewardedInterstitialAd = null;
      notifyListeners();
    }
  }

  Future<void> disposeRewardedInterstitialAd() async {
    if (_rewardedInterstitialAd != null) {
      await _rewardedInterstitialAd!.dispose();
      _rewardedInterstitialAd = null;
      _isRewardedInterstitialAdLoaded = false;
      notifyListeners();
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
      if (_rewardedInterstitialAd != null) {
        await _rewardedInterstitialAd!.dispose();
        _rewardedInterstitialAd = null;
      }
      _isBannerAdLoaded = false;
      _isInterstitialAdLoaded = false;
      _isRewardedAdLoaded = false;
      _isRewardedInterstitialAdLoaded = false;
    } catch (e) {
      debugPrint('AdService: Error disposing ads: $e');
    }
  }

  // Initialize ads
  Future<void> initialize() async {
    try {
      debugPrint('AdService: ===== Starting Ad Initialization =====');
      debugPrint('AdService: Current banner ad status - Loaded: $_isBannerAdLoaded, Instance: ${_bannerAd != null}');
      debugPrint('AdService: Using test mode: $_isTestMode');
      
      // Initialize Mobile Ads SDK with test configuration
      debugPrint('AdService: Initializing Mobile Ads SDK...');
      await AdMobConfig.initialize(isTest: _isTestMode);
      debugPrint('AdService: Mobile Ads SDK initialized successfully');
      
      // Reset all states
      debugPrint('AdService: Disposing existing ads...');
      await dispose();
      debugPrint('AdService: Existing ads disposed');
      
      // Load banner ad first since it's most important
      debugPrint('AdService: Starting banner ad load process...');
      await _loadBannerAd();
      debugPrint('AdService: Banner ad load process completed');
      
      // Then load other ads with a delay to prevent startup lag
      debugPrint('AdService: Scheduling other ads to load in 2 seconds...');
      Future.delayed(const Duration(seconds: 2), () {
        debugPrint('AdService: Loading interstitial and rewarded ads...');
        _loadInterstitialAd();
        _loadRewardedAd();
        loadRewardedInterstitialAd();
      });
      
      _logAdStatus();
      debugPrint('AdService: ===== Ad Initialization Completed =====');
    } catch (e, stackTrace) {
      debugPrint('AdService: ===== Error in Ad Initialization =====');
      debugPrint('AdService: Error message: $e');
      debugPrint('AdService: Stack trace: $stackTrace');
      debugPrint('AdService: ===== End of Error Report =====');
    }
  }

  // Add method to check if any ad is currently showing
  bool get isAnyAdShowing => _isShowingAd;
} 