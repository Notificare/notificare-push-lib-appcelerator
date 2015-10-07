/**
 * Notificare module for Appcelerator Titanium Mobile
 * IntentReceiver
 * @author Joel Oliveira <joel@notifica.re>
 * @copyright 2013 - 2015 Notificare B.V.
 * Please see the LICENSE included with this distribution for details.
 */
package ti.notificare;

import java.lang.reflect.Constructor;
import java.util.ArrayList;
import java.util.List;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.common.Log;
import org.json.JSONException;

import re.notifica.Notificare;
import re.notifica.NotificareCallback;
import re.notifica.NotificareError;
import re.notifica.model.NotificareAction;
import re.notifica.model.NotificareBeacon;
import re.notifica.model.NotificareNotification;
import re.notifica.model.NotificarePendingResult;
import re.notifica.push.gcm.DefaultIntentReceiver;
import re.notifica.ui.NotificationAction;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Location;
import android.net.Uri;
import android.os.Bundle;

/**
 * Intent receiver for Notificare intents
 */
public class IntentReceiver extends DefaultIntentReceiver {

	public static final String PREFS_NAME = "AppPrefsFile";
	private static final String TAG = IntentReceiver.class.getSimpleName();
	
	@Override
	public void onNotificationReceived(String alert, String notificationId, Bundle extras) {
		// Execute default behavior, i.e., put notification in drawer
		Log.d(TAG, "Notification received with extra " + extras.getString("mykey"));
		super.onNotificationReceived(alert, notificationId, extras);
	}

	@Override
	public void onNotificationOpened(String alert, final String notificationId, Bundle extras) {
		NotificareAction action = extras.getParcelable(Notificare.INTENT_EXTRA_ACTION);
		NotificareNotification notification = extras.getParcelable(Notificare.INTENT_EXTRA_NOTIFICATION);
		if (action != null && notification != null && action.getType().equals(NotificareAction.ACTION_TYPE_CALLBACK) && !action.getCamera() && !action.getKeyboard()) {
			try {
				Class<?> actionClass = Class.forName(action.getType());
				Constructor<?> ctor = actionClass.getConstructor(Activity.class, NotificareNotification.class, NotificareAction.class);
				NotificationAction actionHandler = (NotificationAction) ctor.newInstance(null, notification, action);
				actionHandler.handleAction(new NotificareCallback<NotificarePendingResult>() {
					@Override
					public void onSuccess(NotificarePendingResult result) {
						Log.i(TAG, "action handled successfully");
				        Notificare.shared().getEventLogger().logOpenNotificationInfluenced(notificationId);
				        Notificare.shared().getEventLogger().logOpenNotification(notificationId);
					}
					
					@Override
					public void onError(NotificareError error) {
						Log.e(TAG, "error handling action", error);
					}
				});
			} catch (Exception e) {
				Log.e(TAG, "error instantiating Action Handler", e);
			}
		} else {
			KrollDict event = new KrollDict();
			try {
			    event.put("notification", NotificareTitaniumAndroidModule.jsonToObject(notification.toJSONObject()));
			    event.put("alert", alert);
			    event.put("extras", notification.getExtra());
			    
			    NotificareTitaniumAndroidModule module = NotificareTitaniumAndroidModule.getModule();
				if (module != null) {
					Log.i(TAG, "Module is running, firing notification open event");
					module.fireEvent("notification", event);
				} else {
					// Start the main activity
					Log.i(TAG, "Module not running, launch app with notification open intent");
					PackageManager pm = Notificare.shared().getApplicationContext().getPackageManager();
					String packageName = Notificare.shared().getApplicationContext().getPackageName();
					Intent launchIntent = pm.getLaunchIntentForPackage(packageName);
					if (launchIntent != null) {
						launchIntent.setAction(Notificare.INTENT_ACTION_NOTIFICATION_OPENED)
						.putExtra(Notificare.INTENT_EXTRA_NOTIFICATION, notification)
						.putExtra(Notificare.INTENT_EXTRA_DISPLAY_MESSAGE, Notificare.shared().getDisplayMessage())
						.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
						Notificare.shared().getApplicationContext().startActivity(launchIntent);
					}
				}
			} catch (JSONException e) {
				Log.e(TAG, "JSON parse error");
			}
		}
		
		if (Notificare.shared().getAutoCancel()) {
			Notificare.shared().cancelNotification(notificationId);
		}
		
	}

    @Override
    public void onReady() {
    	// Notificare ready, use OnReadyListener instead
    	Log.i(TAG, "Notificare ready");
    }

    @Override
	public void onRegistrationFinished(String deviceId) {
    	NotificareTitaniumAndroidModule module = NotificareTitaniumAndroidModule.getModule();
		if (module != null) {
			KrollDict event = new KrollDict();
		    event.put("device", deviceId);
		    module.fireEvent("registration", event);
		}
	}

	@Override
	public void onActionReceived(Uri target) {
		NotificareTitaniumAndroidModule module = NotificareTitaniumAndroidModule.getModule();
		if (module != null) {
			Log.i(TAG, "Module is running, firing custom action event");
			KrollDict event = new KrollDict();
			event.put("target", target.toString());
			module.fireEvent("action", event);
		} else {
			// Start the main activity
			Log.i(TAG, "Module not running, launch app with custom action intent");
			PackageManager pm = Notificare.shared().getApplicationContext().getPackageManager();
			String packageName = Notificare.shared().getApplicationContext().getPackageName();
			Intent launchIntent = pm.getLaunchIntentForPackage(packageName);
			if (launchIntent != null) {
				launchIntent
				.setAction(Notificare.INTENT_ACTION_CUSTOM_ACTION)
				.setData(target)
				.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
				Notificare.shared().getApplicationContext().startActivity(launchIntent);
			}
//		}
	}
	
	@Override
	public void onRangingBeacons(List<NotificareBeacon> beacons) {
		NotificareTitaniumAndroidModule module = NotificareTitaniumAndroidModule.getModule();
		if (module != null) {
			List<Object> beaconsList = new ArrayList<Object>();
			for (NotificareBeacon beacon : beacons) {
				try {
	                beaconsList.add(NotificareTitaniumAndroidModule.jsonToObject(beacon.toJSONObject()));					
				} catch (JSONException e) {
					Log.e(TAG, "JSON parse error");
				}
            }
			KrollDict event = new KrollDict();
		    event.put("beacons", beaconsList.toArray(new Object[beaconsList.size()]));
		    module.fireEvent("range", event);
		}
	}
	
	@Override
	public void onLocationUpdateReceived(Location location){
		super.onLocationUpdateReceived(location);
		NotificareTitaniumAndroidModule module = NotificareTitaniumAndroidModule.getModule();
		if (module != null) {
			KrollDict event = new KrollDict();
		    event.put("latitude", location.getLatitude());
		    event.put("longitude", location.getLongitude());
		    module.fireEvent("location", event);
		}
	}
}
