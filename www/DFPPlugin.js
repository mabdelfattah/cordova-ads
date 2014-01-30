var DFPPlugin =  {
    createBannerAd : function (options, successCallback, failureCallback) {
        var defaults = {
            'adUnitId': undefined,
            'adSize': undefined
        };
        var requiredOptions = ['adUnitId', 'adSize'];
        
        // Merge optional settings into defaults.
        for (var key in defaults) {
            if (typeof options[key] !== 'undefined') {
                defaults[key] = options[key];
            }
        }
        
        // Check for and merge required settings into defaults.
        requiredOptions.forEach(function(key) {
            if (typeof options[key] === 'undefined') {
                failureCallback('Failed to specify key: ' + key + '.');
                return;
            }
            defaults[key] = options[key];
        });
        
        cordova.exec(
            successCallback,
            failureCallback,
            'DFPPlugin',
            'cordovaCreateBannerAd',
            [{adUnitId:defaults['adUnitId'], adSize:defaults['adSize']}]
        );
    },
    createInterstitialAd : function (options, successCallback, failureCallback) {
        var defaults = {
            'adUnitId': undefined
        };
        var requiredOptions = ['adUnitId'];
        
        // Merge optional settings into defaults.
        for (var key in defaults) {
            if (typeof options[key] !== 'undefined') {
                defaults[key] = options[key];
            }
        }
        
        // Check for and merge required settings into defaults.
        requiredOptions.forEach(function(key) {
                                if (typeof options[key] === 'undefined') {
                                failureCallback('Failed to specify key: ' + key + '.');
                                return;
                                }
                                defaults[key] = options[key];
                                });
        
        cordova.exec(
            successCallback,
            failureCallback,
            'DFPPlugin',
            'cordovaCreateInterstitialAd',
            [{adUnitId:defaults['adUnitId']}]
        );
    },
    
    requestAd : function(options, successCallback, failureCallback) {
        var defaults = {
            'isTesting': false,
            'extras': {}
        };
        
        for (var key in defaults) {
            if (typeof options[key] !== 'undefined') {
                defaults[key] = options[key];
            }
        }
        
        cordova.exec(
            successCallback,
            failureCallback,
            'DFPPlugin',
            'cordovaRequestAd',
            [{isTesting:defaults['isTesting'], extras:defaults['extras']}]
        );
    },
    
    removeAd: function(options, successCallback, failureCallback) {
        //In case we need options for removing an ad
        var defaults = {};
        
        for (var key in defaults) {
            if (typeof options[key] !== 'undefined') {
                defaults[key] = options[key];
            }
        }

        cordova.exec(
            successCallback,
            failureCallback,
            'DFPPlugin',
            'cordovaRemoveAd',
            []
        );

    }
};

module.exports = DFPPlugin;