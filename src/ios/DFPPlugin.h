//
//  DFPPlugin.h
//  DFPPlugin
//
//  Created by Donnie Marges on 1/29/2014.
//
//

#import <Cordova/CDV.h>
#import "DFPBannerView.h"
#import "GADAdSizeDelegate.h"
#import "GADAppEventDelegate.h"
#import "GADBannerViewDelegate.h"

@interface DFPPlugin : CDVPlugin <GADBannerViewDelegate, GADAppEventDelegate>
@property (strong, nonatomic)DFPBannerView *dfpBannerView;
@property (strong, nonatomic)DFPBannerView *dfpInterstitialView;


- (void)cordovaCreateBannerAd:(CDVInvokedUrlCommand *)command;
- (void)cordovaCreateInterstitialAd:(CDVInvokedUrlCommand *)command;
- (GADAdSize)GADAdSizeFromString:(NSString *)string;
- (void)createBannerAdView:(NSString *)adUnitID adSize:(GADAdSize)adSize;
- (void)createInterstitialAdView:(NSString *)adUnitID adSize:(GADAdSize)adSize;
- (void)resizeViews;
- (void)cordovaRemoveAd: (CDVInvokedUrlCommand *)command;
- (void)dealloc;

@end
