class AdMobConfig {
  // App ID (this is correct and should be used in AndroidManifest.xml)
  static const String appId = 'ca-app-pub-8639311525630636~2424199342';

  // Ad Unit IDs for different ad formats
  static const String bannerAdUnitId = 'ca-app-pub-8639311525630636/6699798389';  // Your existing banner ad unit
  static const String interstitialAdUnitId = 'ca-app-pub-8639311525630636/2424199342';  // Your app open ad unit
  static const String rewardedAdUnitId = 'ca-app-pub-8639311525630636/2424199342';  // Your app open ad unit
  static const String appOpenAdUnitId = 'ca-app-pub-8639311525630636/2424199342';  // Your app open ad unit

  // Test Ad Unit IDs (use these during development)
  static const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String testAppOpenAdUnitId = 'ca-app-pub-3940256099942544/3419835294';

  // Helper method to get the appropriate ad unit ID based on environment
  static String getAdUnitId(String adType, {bool isTest = false}) {
    if (isTest) {
      switch (adType) {
        case 'banner':
          return testBannerAdUnitId;
        case 'interstitial':
          return testInterstitialAdUnitId;
        case 'rewarded':
          return testRewardedAdUnitId;
        case 'appOpen':
          return testAppOpenAdUnitId;
        default:
          throw Exception('Invalid ad type: $adType');
      }
    } else {
      switch (adType) {
        case 'banner':
          return bannerAdUnitId;
        case 'interstitial':
          return interstitialAdUnitId;
        case 'rewarded':
          return rewardedAdUnitId;
        case 'appOpen':
          return appOpenAdUnitId;
        default:
          throw Exception('Invalid ad type: $adType');
      }
    }
  }
} 