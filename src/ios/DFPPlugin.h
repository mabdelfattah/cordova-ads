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

- (void)cordovaCreateBannerAd:(CDVInvokedUrlCommand *)command;
- (void)cordovaCreateInterstitialAd:(CDVInvokedUrlCommand *)command;
- (void)cordovaSetDebugMode:(CDVInvokedUrlCommand *)command;
- (GADAdSize)GADAdSizeFromString:(NSString *)string;
- (void)createBannerAdView:(NSString *)adUnitID adSize:(GADAdSize)adSize;
- (void)createInterstitialAdView:(NSString *)adUnitID;
- (void)resizeViews;
- (void)cordovaRemoveAd: (CDVInvokedUrlCommand *)command;
- (void)adView:(DFPBannerView *)banner didReceiveAppEvent:(NSString *)name withInfo:(NSString *)info;
- (void)interstitial:(DFPInterstitial *)interstitial didReceiveAppEvent:(NSString *)name withInfo:(NSString *)info;
- (void)interstitialDidReceiveAd:(DFPInterstitial *)interstitial;
- (void)interstitial:(DFPInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error;
- (void)adViewWillPresentScreen:(GADBannerView *)adView;
- (void)dealloc;

@end
