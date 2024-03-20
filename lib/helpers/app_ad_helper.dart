import 'dart:io';

import 'package:dating_app/constants/constants.dart';
import 'package:dating_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppAdHelper {
  // Local Variables
  static InterstitialAd? _interstitialAd;
  //
  static BannerAd? _bannerAd;
  final AdSize _adSize = AdSize.banner;

  String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-2870624016178065/1235687902';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-2870624016178065/1235687902';
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  // Get Interstitial Ad ID
  static String get _interstitialID {
    if (Platform.isAndroid) {
      return ANDROID_INTERSTITIAL_ID;
    } else if (Platform.isIOS) {
      return IOS_INTERSTITIAL_ID;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  // Create Interstitial Ad
  Future<void> _createInterstitialAd() async {
    await InterstitialAd.load(
        adUnitId: _interstitialID,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            debugPrint('$ad loaded');
            _interstitialAd = ad;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error.');
            _interstitialAd = null;
            _createInterstitialAd();
          },
        ));
  }

  // Show Interstitial Ads for Non VIP Users
  void showInterstitialAd() async {
    // Check "Active" VIP Status
    if (UserModel().userIsVip) {
      // Debug
      debugPrint('User is VIP Member!');
      return;
    }

    // Load Interstitial Ad
    await _createInterstitialAd();

    if (_interstitialAd == null) {
      // Debug
      debugPrint('Warning: attempt to show interstitial before loaded.');
      return;
    }
    // Run callbacks
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  // Dispose Interstitial Ad
  void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  Future<void> _createBannerAd() async {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: _adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          debugPrint('Banner ad loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
          _createBannerAd(); // Retry creating the banner ad on failure
        },
        onAdOpened: (_) {
          debugPrint('Banner ad opened.');
        },
        onAdClosed: (_) {
          debugPrint('Banner ad closed.');
        },
        onAdImpression: (_) {
          debugPrint('Banner ad impression.');
        },
        onAdClicked: (_) {
          debugPrint('Banner ad clicked.');
        },
      ),
    );

    await _bannerAd!.load();
  }

  // Show Banner Ad
  Widget showBannerAd() {
    debugPrint('Banner add showing');
    return AdWidget(ad: _bannerAd!);
  }

  // Initialize and Show Banner Ad
  void initializeAndShowBannerAd() {
    debugPrint('Banner add showinggggggg');
    _createBannerAd();
  }
}
