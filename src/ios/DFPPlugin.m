//
//  DFPPlugin.m
//  DFPPlugin
//
//  Created by Donnie Marges on 1/29/2014.
//
//

#import "DFPPlugin.h"
#import "GADAdMobExtras.h"
#import "GADAdSize.h"
#import "GADBannerView.h"
#import "GADRequest.h"

@implementation DFPPlugin

- (CDVPlugin *)initWithWebView:(UIWebView *)theWebView {
    
    self = (DFPPlugin *)[super initWithWebView:theWebView];
    self.debugMode = YES;
    return self;
}

- (void)cordovaCreateBannerAd: (CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    NSDictionary *params = [command argumentAtIndex:0];
    NSMutableDictionary *tags = NULL;
    DFPExtras *extras = [[DFPExtras alloc] init];
    NSString *networkID = NULL;
    
    //We need to have an ad unit id to display any ads. If this argument is not passed from the JS, we are going to fire the failure callback. Same goes for ad size.
    if(![params objectForKey: @"adUnitId"]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"DFPPlugin: "
                                         @"Invalid Ad Unit ID"];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        return;
    } else if(![params objectForKey: @"adSize"]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"DFPPlugin: "
                                         @"Invalid Ad Size"];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        return;
    }
    
    NSString *adUnitId = [params objectForKey: @"adUnitId"];
    GADAdSize adSize = [self GADAdSizeFromString:[params objectForKey:@"adSize"]];
    
    if([params objectForKey: @"networkId"]) {
        networkID = [params objectForKey: @"networkId"];
        adUnitId = @"/3081/";
        adUnitId = [adUnitId stringByAppendingString: networkID];
        adUnitId = [adUnitId stringByAppendingString: @"/news/index"];
    }
    
    if([params objectForKey:@"tags"]) {
        tags = [[NSMutableDictionary alloc] initWithDictionary:[params objectForKey:@"tags"]];
        
        extras.additionalParameters = [NSDictionary dictionaryWithDictionary:tags];
        self.dfpBannerViewExtras = extras;
    }

    [self createBannerAdView:adUnitId adSize:adSize];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}


- (void)cordovaCreateInterstitialAd:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    NSDictionary *params = [command argumentAtIndex:0];
    
    //We need to have an ad unit id to display any ads. If this argument is not passed from the JS, we are going to fire the failure callback. Same goes for ad size.
    if(![params objectForKey: @"adUnitId"]) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"DFPPlugin: "
                                         @"Invalid Ad Unit ID"];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        return;
    }
    
    NSString *adUnitId = [params objectForKey: @"adUnitId"];

    [self createInterstitialAdView:adUnitId];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}


- (void)cordovaRequestAd:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    GADRequest *request = [GADRequest request];
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *callbackId = command.callbackId;
    
    if (!self.dfpBannerView && !self.dfpInterstitialView) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"DFPPlugin: "
                                         @"No ad view exists"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        return;
    }
    
    BOOL testing = [[params objectForKey:@"isTesting"] boolValue];
    
    if(testing) {
        request.testDevices = [NSArray arrayWithObjects: GAD_SIMULATOR_ID, nil];
    }
    
    // Add the ad to the main container view, and resize the webview to make space
    // for it.
    if(self.dfpBannerView) {
        if(self.dfpBannerViewExtras) {
            [request registerAdNetworkExtras:self.dfpBannerViewExtras];
        }
        
        [self.dfpBannerView loadRequest:request];
        [self.webView.superview addSubview:self.dfpBannerView];
        [self resizeViews];
    }
    
    if(self.dfpInterstitialView) {
        [self.dfpInterstitialView loadRequest:request];
    }
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)cordovaSetDebugMode:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *callbackId = command.callbackId;
    
    self.debugMode = [[params objectForKey:@"debug"] boolValue];
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (GADAdSize)GADAdSizeFromString:(NSString *)string {
    //TODO: Add support for other sizes
    if ([string isEqualToString:@"BANNER"]) {
        return kGADAdSizeBanner;
    } else if([string isEqualToString:@"BIGBOX"]) {
        return kGADAdSizeMediumRectangle;
    } else {
        return kGADAdSizeInvalid;
    }
}

- (void)createBannerAdView:(NSString *)adUnitID adSize:(GADAdSize)adSize {
    self.dfpBannerView = [[DFPBannerView alloc] initWithAdSize:adSize];
    self.dfpBannerView.adUnitID = adUnitID;
    self.dfpBannerView.delegate = self;
    self.dfpBannerView.rootViewController = self.viewController;
    [self.dfpBannerView setAppEventDelegate:self];
}

- (void)createInterstitialAdView:(NSString *)adUnitID {
    self.dfpInterstitialView = [[DFPInterstitial alloc] init];
    self.dfpInterstitialView.adUnitID = adUnitID;
    self.dfpInterstitialView.delegate = self;
    [self.dfpInterstitialView setAppEventDelegate:self];
}

- (void)resizeViews {
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    // Frame of the main Cordova webview.
    CGRect webViewFrame = self.webView.frame;
    
    // Frame of the main container view that holds the Cordova webview.
    CGRect superViewFrame = self.webView.superview.frame;
    CGRect bannerViewFrame = self.dfpBannerView.frame;
    CGRect frame = bannerViewFrame;
    
    // The updated x and y coordinates for the origin of the banner.
    CGFloat yLocation = 0.0;
    CGFloat xLocation = 0.0;
    
    webViewFrame.origin.y = 0;
    
    // Need to center the banner both horizontally and vertically.
    if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
        yLocation = superViewFrame.size.width -
        bannerViewFrame.size.height;
        xLocation = (superViewFrame.size.height -
                     bannerViewFrame.size.width) / 2.0;
    } else {
        if(self.dfpBannerView.frame.size.width == 300 && self.dfpBannerView.frame.size.height == 250) {
            yLocation = (superViewFrame.size.height - bannerViewFrame.size.height) / 2.0;
        } else {
            yLocation = superViewFrame.size.height - bannerViewFrame.size.height;
        }
        xLocation = (superViewFrame.size.width - bannerViewFrame.size.width) / 2.0;
    }
    
    frame.origin = CGPointMake(xLocation, yLocation);
    self.dfpBannerView.frame = frame;
    
    if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
    
        // The super view's frame hasn't been updated so use its width
        // as the height.
        webViewFrame.size.height = superViewFrame.size.width - bannerViewFrame.size.height;
    }
    self.webView.frame = webViewFrame;
}

- (void)cordovaRemoveAd:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    NSString *callbackId = command.callbackId;
    
    if(self.dfpBannerView) {
        
        [self.dfpBannerView setDelegate:nil];
        [self.dfpBannerView removeFromSuperview];
        [self.dfpBannerView setAppEventDelegate:nil];
        self.dfpBannerView = nil;
        
        CGRect webViewFrame = self.webView.frame;
        
        // Frame of the main container view that holds the Cordova webview.
        CGRect superViewFrame = self.webView.superview.frame;
        webViewFrame.size.height = superViewFrame.size.height;
        self.webView.frame = webViewFrame;
    }
    
    if(self.dfpInterstitialView) {
        [self.dfpInterstitialView setDelegate:nil];
        [self.dfpInterstitialView setAppEventDelegate:nil];
        self.dfpInterstitialView = nil;
    }
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}

- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    if(self.debugMode) {
        NSString *adUnitId = @"Ad Unit ID: ";
        adUnitId = [adUnitId stringByAppendingString: self.dfpBannerView.adUnitID];
        
        adUnitId = [adUnitId stringByAppendingString:@"\n"];
        
        NSString *adSize = @"Ad Size: ";
        adSize = [adSize stringByAppendingString: NSStringFromCGSize(self.dfpBannerView.adSize.size)];
        
        adUnitId = [adUnitId stringByAppendingString:adSize];
        
        NSString *tags = NULL;
        
        if(self.dfpBannerViewExtras) {
            tags = [self.dfpBannerViewExtras.additionalParameters description];
            adUnitId = [adUnitId stringByAppendingString:tags];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ad Debugging" message:adUnitId delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
        removeObserver:self
        name:UIDeviceOrientationDidChangeNotification
        object:nil];

    self.dfpBannerView.delegate = nil;
    self.dfpInterstitialView.delegate = nil;
}

- (void)interstitialDidReceiveAd:(DFPInterstitial *)interstitial {
    NSLog(@"Received Ad");
    [self.dfpInterstitialView presentFromRootViewController:self.viewController];
}

- (void)interstitial:(DFPInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to load interstitial");
}

- (void)adView:(DFPBannerView *)banner didReceiveAppEvent:(NSString *)name withInfo:(NSString *)info {
    NSLog(@"banner view event: %@", name);
}

- (void)adViewDidReceiveAd:(DFPBannerView *)bannerView {
    NSLog(@"adViewDidReceiveAd");
}

- (void)adView:(DFPBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"didFailToReceiveAdWithError: %@", error.description);
}

- (void)interstitial:(DFPInterstitial *)interstitial didReceiveAppEvent:(NSString *)name withInfo:(NSString *)info {
    NSLog(@"interstitial view event: %@", name);
}



@end
