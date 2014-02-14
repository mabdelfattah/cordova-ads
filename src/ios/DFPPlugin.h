//
//  DFPPlugin.h
//  DFPPlugin
//
//  Created by Donnie Marges on 1/29/2014.
//
//

#import <Cordova/CDV.h>
#import "DFPBannerView.h"
#import "DFPInterstitial.h"
#import "GADInterstitialDelegate.h"
#import "GADAdSizeDelegate.h"
#import "GADAppEventDelegate.h"
#import "GADBannerViewDelegate.h"
#import "DFPExtras.h"

@interface DFPPlugin : CDVPlugin <GADBannerViewDelegate, GADAppEventDelegate, GADInterstitialDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic)DFPBannerView *dfpBannerView;
@property (strong, nonatomic)DFPExtras *dfpBannerViewExtras;
@property (strong, nonatomic)DFPInterstitial *dfpInterstitialView;
@property BOOL debugMode;

//These methods are what can be called from the JavaScript plugin.
- (void)cordovaCreateBannerAd:(CDVInvokedUrlCommand *)command;
- (void)cordovaCreateInterstitialAd:(CDVInvokedUrlCommand *)command;
- (void)cordovaSetDebugMode:(CDVInvokedUrlCommand *)command;
- (void)cordovaRemoveAd: (CDVInvokedUrlCommand *)command;

//DFP Ad Rendering Methods
- (void)createBannerAdView:(NSString *)adUnitID adSize:(GADAdSize)adSize backgroundColor:(NSString *)backgroundColor;
- (void)createInterstitialAdView:(NSString *)adUnitID;
- (void)resizeViews;
- (void)removeAds;

//DFP Ad Events
- (void)adView:(DFPBannerView *)banner didReceiveAppEvent:(NSString *)name withInfo:(NSString *)info;
- (void)interstitial:(DFPInterstitial *)interstitial didReceiveAppEvent:(NSString *)name withInfo:(NSString *)info;
- (void)interstitialDidReceiveAd:(DFPInterstitial *)interstitial;
- (void)interstitial:(DFPInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error;
- (void)adViewWillPresentScreen:(GADBannerView *)adView;

- (void)dealloc;

//Helper methods
- (GADAdSize)GADAdSizeFromString:(NSString *)string;
- (unsigned int)intFromHexString:(NSString *)hexStr;
- (UIColor *)getUIColorObjectFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha;

@end
