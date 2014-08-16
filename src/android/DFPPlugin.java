/**
 * Plugin to ser DFP Ads on mobile devices
 *
 * author: waheed ashraf
 * Created on: March 3rd, 2014
 *
 * Updated by: Mahmoud Abdel-Fattah
 * August 15th, 2014
 */

package com.postmedia.pheme;

import com.google.android.gms.ads.*;
import com.google.android.gms.ads.doubleclick.*;
import com.google.android.gms.ads.mediation.admob.AdMobExtras;
import com.google.android.gms.ads.AdListener;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.cordova.PluginResult.Status;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.Iterator;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.RelativeLayout;

/**
 * This class represents the native implementation for the DFPAds Cordova
 * plugin. This plugin can be used to request DFP ads natively via the Google
 * DFP SDK. The Google DFP SDK is a dependency for this plugin.
 */
public class DFPPlugin extends CordovaPlugin {
	private PublisherAdView adView;
	private RelativeLayout adViewLayer;
	private boolean debug;
	private AdSize adSize;
	private int backgroundColor;
	private String publisherId;
	private JSONObject extras;

	/**
	 * This is the main method for the DFPAds plugin. All API calls go through
	 * here. This method determines the action, and executes the appropriate
	 * call.
	 *
	 * @param action
	 *            The action that the plugin should execute.
	 * @param inputs
	 *            The input parameters for the action.
	 * @param callbackId
	 *            The callback ID. This is currently unused.
	 * @return A PluginResult representing the result of the provided action. A
	 *         status of INVALID_ACTION is returned if the action is not
	 *         recognized.
	 */
	@Override
	public boolean execute(String action, JSONArray inputs, CallbackContext callbackContext) throws JSONException {
		PluginResult result = null;
		if (action.equals("cordovaCreateBannerAd")) {
			result = executeCreateAdView(inputs);
		} else if (action.equals("cordovaRemoveAd")) {
			result = executeDestroyBannerView(inputs);
		} else if (action.equals("cordovaSetDebugMode")) {
			result = executeSetDebugMode(inputs);
		} else {
			Log.d("AdDFP", String.format("Invalid action passed: %s", action));
			result = new PluginResult(Status.INVALID_ACTION);
		}
		callbackContext.sendPluginResult(result);

		return true;
	}

	/**
	 * Parses the create banner view input parameters and runs the create ad
	 * view action on the UI thread. If this request is successful, the
	 * developer should make the requestAd call to request an ad for the banner.
	 *
	 * @param inputs
	 *            The JSONArray representing input parameters. This function
	 *            expects the first object in the array to be a JSONObject with
	 *            the input parameters.
	 * @return A PluginResult representing whether or not the banner was created
	 *         successfully.
	 */
	private PluginResult executeCreateAdView(JSONArray inputs) {
		String publisherId;
		String size;
		int backgroundColor = Color.TRANSPARENT;
		try {
			JSONObject options = inputs.getJSONObject(0);
			publisherId = options.getString("adUnitId");
			size = options.getString("adSize");
			extras = options.getJSONObject("tags");

			if (options.has("backgroundColor")) {
        backgroundColor = Color.parseColor(options.getString("backgroundColor"));
      } else {
        backgroundColor = backgroundColor;
      }

		} catch (JSONException exception) {
			Log.w("AdDFP", String.format("Got JSON Exception: %s", exception.getMessage()));
			return new PluginResult(Status.JSON_EXCEPTION);
		}
		return executeRunnable(new CreateAdView(publisherId, adSizeFromSize(size), backgroundColor));
	}
	private PluginResult executeDestroyBannerView(JSONArray inputs) {
		return executeRunnable(new DestroyAdView(this.adViewLayer));
	}
	private PluginResult executeRunnable(AdDfpRunnable runnable) {
		synchronized (runnable) {
			cordova.getActivity().runOnUiThread(runnable);
			try {
				if (runnable.getPluginResult() == null) {
					runnable.wait();
				}
			} catch (InterruptedException exception) {
				Log.w("AdDFP", String.format("Interrupted Exception: %s", exception.getMessage()));
				return new PluginResult(Status.ERROR, "Interruption occurred when running on UI thread");
			}
		}
		return runnable.getPluginResult();
	}
	private PluginResult executeSetDebugMode(JSONArray inputs) {
		try {
			this.debug = inputs.getJSONObject(0).getBoolean("debug");
		} catch (JSONException e) {
			return new PluginResult(Status.INVALID_ACTION);
		}
		return new PluginResult(Status.OK);
	}
	/**
	 * This class implements the DFPAds ad listener events. It forwards the
	 * events to the JavaScript layer. To listen for these events.
	 */
	private class BannerListener extends AdListener {
		@Override
		public void onAdClosed() {
			webView.loadUrl("javascript:cordova.fireDocumentEvent('onAdClosed');");
		}

		@Override
		public void onAdFailedToLoad(int errorCode) {
			webView.loadUrl(String.format("javascript:cordova.fireDocumentEvent('onAdFailedToLoad', { 'error': '%s' });", errorCode));
		}

		@Override
		public void onAdLeftApplication() {
			webView.loadUrl("javascript:cordova.fireDocumentEvent('onAdLeftApplication');");
		}

		@Override
		public void onAdLoaded() {
			webView.loadUrl("javascript:cordova.fireDocumentEvent('onAdLoaded');");
		}

		@Override
		public void onAdOpened() {
			if (debug) {
				displayDebugInfo();
			}
			webView.loadUrl("javascript:cordova.fireDocumentEvent('onAdOpened');");
		}
	}

	/**
	 * This method displays debug information in a dialog box.
	 */
	private void displayDebugInfo(){
		AlertDialog.Builder dialog = new AlertDialog.Builder(cordova.getActivity());
		dialog.setTitle("Ad Debugging");
		StringBuilder message = new StringBuilder();
		message.append(String.format("Ad Unit ID: %s\n", publisherId));
		message.append(String.format("Ad Size:  {%d, %d}\n", adSize.getWidth(), adSize.getHeight()));

		Iterator<?> keys = extras.keys();
        while( keys.hasNext() ){
            String key = (String)keys.next();
            try {
            	message.append(String.format("%s = %s\n", key, extras.getString(key)));
			} catch (JSONException e) {}
        }
		dialog.setMessage(message);
		dialog.setNegativeButton(android.R.string.ok, new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				// do nothing
			}
		});
		dialog.show();
	}

	/** Runnable for the createAdView action. */
	private class CreateAdView extends AdDfpRunnable {
		public CreateAdView(String pubId, AdSize size, int bg) {
			publisherId = pubId;
			adSize = size;
			backgroundColor = bg;
			result = new PluginResult(Status.NO_RESULT);
		}

		@Override
		public void run() {
			if (adSize == null) {
				result = new PluginResult(Status.ERROR, "AdSize is null. Did you specify AdSize?");
			} else {
				adView = new PublisherAdView(cordova.getActivity());
				adView.setAdUnitId(publisherId);
				adView.setAdSizes(adSize);

				adView.setBackgroundColor(backgroundColor);
				adView.setAdListener(new BannerListener());
				adViewLayer = new RelativeLayout(cordova.getActivity());
				RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);

				if (adSize == AdSize.BANNER) {
					adView.setPadding(0, 1, 0, 0);
					layoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
				} else {

					int topMargin = (webView.getHeight() / 2) - 400;
					if (topMargin < 200)
						topMargin = 200;
					layoutParams.topMargin = topMargin;
				}
				adViewLayer.addView(adView, layoutParams);
				ViewGroup.LayoutParams outerLayout = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
				Bundle bundle = new Bundle();

				Iterator<?> keys = extras.keys();

		        while( keys.hasNext() ){
		            String key = (String)keys.next();
		            try {
						bundle.putString(key, extras.getString(key));
					} catch (JSONException e) {

					}
		        }
				cordova.getActivity().addContentView(adViewLayer, outerLayout);
				adView.loadAd(new PublisherAdRequest.Builder().addNetworkExtras(new AdMobExtras(bundle)).build());

				result = new PluginResult(Status.OK);
			}
			synchronized (this) {
				this.notify();
			}
		}
	}
	/**
	 *
	 * Removes the ad layer from application and destroy any ad within that layerview.
	 *
	 */
	private class DestroyAdView extends AdDfpRunnable {
		private RelativeLayout layout;

		public DestroyAdView(RelativeLayout adViewLayout) {
			this.layout = adViewLayout;
			result = new PluginResult(Status.NO_RESULT);
		}

		@Override
		public void run() {
			if (adView != null) {
				if (layout != null)
					layout.removeView(adView);
			}
			// Notify the plugin.
			result = new PluginResult(Status.OK);
			synchronized (this) {
				this.notify();
			}
		}
	}
	/**
	 * Gets an AdSize object from the string size passed in from JavaScript.
	 * Returns null if an improper string is provided.
	 *
	 * @param size
	 *            The string size representing an ad format constant.
	 * @return An AdSize object used to create a banner.
	 */
	public static AdSize adSizeFromSize(String size) {
		if ("BANNER".equals(size)) {
			return AdSize.BANNER;
		} else if ("BIGBOX".equals(size)) {
			return new AdSize(300, 250);
		} else {
			return null;
		}
	}
	@Override
	public void onDestroy() {

		if (adView != null) {
			adView.destroy();
		}
		super.onDestroy();
	}
	/**
	 * Represents a runnable for the plugin that will run on the UI thread.
	 */
	private abstract class AdDfpRunnable implements Runnable {
		protected PluginResult result;

		public PluginResult getPluginResult() {
			return result;
		}
	}
}
