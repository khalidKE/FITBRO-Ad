import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobConfig {
  // App ID (this is correct and should be used in AndroidManifest.xml)
  static const String appId = 'ca-app-pub-8639311525630636~2424199342';

  // Production Ad Unit IDs
  static const String bannerAdUnitId = 'ca-app-pub-8639311525630636/6699798389';
  static const String interstitialAdUnitId = 'ca-app-pub-8639311525630636/7745286740';  // Replace with your actual interstitial ad unit
  static const String rewardedAdUnitId = 'ca-app-pub-8639311525630636/7745286740';  // Replace with your actual rewarded ad unit
  static const String appOpenAdUnitId = 'ca-app-pub-8639311525630636/2424199342';

  // Test Ad Unit IDs
  static const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String testAppOpenAdUnitId = 'ca-app-pub-3940256099942544/3419835294';

  // Test Device ID
  static const String testDeviceId = 'FB9983AB0AB05F95C7C9CE00870F97D8';

  // Initialize Mobile Ads SDK with test device configuration
  static Future<void> initialize({bool isTest = false}) async {
    await MobileAds.instance.initialize();
    
    if (isTest) {
      // Set test device
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: [testDeviceId],
        ),
      );
    }
  }

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