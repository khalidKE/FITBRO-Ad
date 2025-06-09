import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../config/admob_config.dart';

class AppOpenAdService {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _isAdAvailable = false;
  DateTime? _lastAdLoadTime;
  static const int _adLoadTimeout = 4; // Timeout in hours
  final bool _isTestMode = false; // Set to false for production

  /// Load an app open ad.
  Future<void> loadAd() async {
    debugPrint('AppOpenAdService: Starting to load ad...');
    if (_isAdAvailable) {
      debugPrint('AppOpenAdService: Ad already available, skipping load');
      return;
    }

    try {
      final adUnitId = AdMobConfig.getAdUnitId('appOpen', isTest: _isTestMode);
      debugPrint('AppOpenAdService: Loading ad with ID: $adUnitId');
      
      await AppOpenAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('AppOpenAdService: Ad loaded successfully');
            _appOpenAd = ad;
            _isAdAvailable = true;
            _lastAdLoadTime = DateTime.now();

            _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('AppOpenAdService: Ad dismissed');
                _isShowingAd = false;
                ad.dispose();
                _appOpenAd = null;
                _isAdAvailable = false;
                loadAd(); // Load the next ad
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('AppOpenAdService: Ad failed to show: ${error.message}');
                _isShowingAd = false;
                ad.dispose();
                _appOpenAd = null;
                _isAdAvailable = false;
                loadAd(); // Try to load another ad
              },
              onAdShowedFullScreenContent: (ad) {
                debugPrint('AppOpenAdService: Ad showed successfully');
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('AppOpenAdService: Ad failed to load: ${error.message}');
            _isAdAvailable = false;
            _appOpenAd = null;
            // Try to load again after a short delay
            Future.delayed(const Duration(minutes: 1), () {
              loadAd();
            });
          },
        ),
      );
    } catch (e) {
      debugPrint('AppOpenAdService: Error loading ad: $e');
      _isAdAvailable = false;
      _appOpenAd = null;
    }
  }

  /// Show the app open ad if one is available and not already showing.
  void showAdIfAvailable() {
    debugPrint('AppOpenAdService: Attempting to show ad...');
    debugPrint('AppOpenAdService: isAdAvailable: $_isAdAvailable, isShowingAd: $_isShowingAd');
    
    if (!_isAdAvailable || _isShowingAd) {
      debugPrint('AppOpenAdService: Cannot show ad - not available or already showing');
      return;
    }

    // Check if the ad has expired
    if (_lastAdLoadTime != null) {
      final timeSinceLastLoad = DateTime.now().difference(_lastAdLoadTime!);
      debugPrint('AppOpenAdService: Time since last load: ${timeSinceLastLoad.inHours} hours');
      
      if (timeSinceLastLoad.inHours >= _adLoadTimeout) {
        debugPrint('AppOpenAdService: Ad expired, loading new one');
        _isAdAvailable = false;
        _appOpenAd?.dispose();
        _appOpenAd = null;
        loadAd();
        return;
      }
    }

    debugPrint('AppOpenAdService: Showing ad now');
    _appOpenAd?.show();
    _isShowingAd = true;
  }

  /// Dispose of the app open ad.
  void dispose() {
    debugPrint('AppOpenAdService: Disposing ad');
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isAdAvailable = false;
    _isShowingAd = false;
  }
}