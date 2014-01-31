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
            'createBannerAd',
            [{publisherId:defaults['adUnitId'], adSize:defaults['adSize']}]
        );
    },  
};

module.exports = DFPPlugin;