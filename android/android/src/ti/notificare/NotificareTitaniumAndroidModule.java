/**
 * Notificare module for Appcelerator Titanium Mobile
 * @author Joel Oliveira <joel@notifica.re>
 * @copyright 2013 - 2015 Notificare B.V.
 * Please see the LICENSE included with this distribution for details.
 */
package ti.notificare;

import java.lang.reflect.Method;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.TiBaseActivity;
import org.appcelerator.titanium.TiC;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import re.notifica.Notificare;
import re.notifica.NotificareCallback;
import re.notifica.NotificareError;
import re.notifica.model.NotificareInboxItem;
import re.notifica.model.NotificareNotification;
import re.notifica.ui.NotificationActivity;
import android.app.Activity;
import android.content.Intent;

@Kroll.module(name="NotificareTitaniumAndroid", id="ti.notificare")
public class NotificareTitaniumAndroidModule extends KrollModule {
	private static final String TAG = "NotificareTitanium";
	
	private static NotificareTitaniumAndroidModule module;
	
	private static SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US);

	private Boolean ready = false;
	
	private String userID;
	private String userName;
	private String deviceID;
	
	/**
	 * Constructor
	 */
	public NotificareTitaniumAndroidModule() {
		super();
		Log.d(TAG, "constructor");
		module = this;
	}
	
	/*
	 * Helper methods
	 */

	/**
	 * Try and fetch the loaded module form the current running context
	 * @return
	 */
	public static NotificareTitaniumAndroidModule getModule() {
		return module;
	}
	
	/**
	 * Fetches tags and fires an event when done
	 */
	private void fetchTags() {
		Notificare.shared().fetchDeviceTags(new NotificareCallback<List<String>>() {

			@Override
			public void onError(NotificareError error) {
				Log.e(TAG, "Error fetching tags", error);
			}

			@Override
			public void onSuccess(List<String> tags) {
				KrollDict event = new KrollDict();
			    event.put("tags", tags.toArray(new Object[tags.size()]));
			    fireEvent("tags", event);
			}

		});
	}
	
	/*
	 *  Properties
	 */
	
	@Kroll.getProperty @Kroll.method
	public String getUserID() {
		return this.userID;
	}

	@Kroll.setProperty @Kroll.method
	public void setUserID(String userID) {
		this.userID = userID;
	}

	@Kroll.getProperty @Kroll.method
	public String getUserName() {
		return this.userName;
	}

	@Kroll.setProperty @Kroll.method
	public void setUserName(String userName) {
		this.userName = userName;
		Notificare.shared().setUserName(userName);
	}

	@Kroll.getProperty @Kroll.method
	public String getDeviceID() {
		return this.deviceID;
	}
	
	private void setDeviceID(String deviceID) {
		this.deviceID = deviceID;
	}
	
	public Boolean isReady() {
		return ready;
	}
	
	public void setReady() {
		ready = true;
	}

	/*
	 * Overrides
	 */
	
	@Kroll.onAppCreate
	public static void onAppCreate(TiApplication app) {
		Log.d(TAG, "Notificare module app create");
		Notificare.shared().launch(app);
		Notificare.shared().setDebugLogging(true);
		Notificare.shared().setIntentReceiver(IntentReceiver.class);
	}
	
	/*
	 * Module Methods
	 */
		
	/**
	 * Enable notifications
	 */
	@Kroll.method
	public void enableNotifications() {
		Notificare.shared().enableNotifications();
	}

	/**
	 * Enable location updates
	 */
	@Kroll.method
	public void enableLocationUpdates(@Kroll.argument(optional=true)KrollFunction permissionCallback) {
    	if (Notificare.shared().hasLocationPermissionGranted()) {
    		Notificare.shared().enableLocationUpdates();
		} else {
    		Log.i(TAG, "location permission not granted");
			if (TiBaseActivity.locationCallbackContext == null) {
				TiBaseActivity.locationCallbackContext = getKrollObject();
			}
			TiBaseActivity.locationPermissionCallback = permissionCallback;
			String[] permissions = new String[] {android.Manifest.permission.ACCESS_FINE_LOCATION};
			Activity currentActivity = TiApplication.getInstance().getCurrentActivity();
			currentActivity.requestPermissions(permissions, TiC.PERMISSION_CODE_LOCATION);
    	}
	}
	
	/** 
	 * Enable beacons
	 */
	@Kroll.method
	public void enableBeacons() {
		Notificare.shared().enableBeacons();
	}
	
	/**
	 * Enable billing
	 */
	@Kroll.method
	public void enableBilling() {
		Notificare.shared().enableBilling();
	}
	
	/**
	 * Register device, userID and userName should be set before if needed
	 * Fires the 'registered' event
	 * @param deviceId
	 */
	@Kroll.method
	public void registerDevice(@Kroll.argument(optional=false, name="deviceId" ) String deviceId) {
		
		Notificare.shared().registerDevice(deviceId, getUserID(), getUserName(), new NotificareCallback<String>() {

			@Override
			public void onSuccess(String result) {
				
				setDeviceID(Notificare.shared().getDeviceId());
				setUserID(Notificare.shared().getUserId());
				setUserName(Notificare.shared().getUserName());
				HashMap<String, Object> event = new HashMap<String, Object>();
			    event.put("device", result);
			    fireEvent("registered", event);
		    	fetchTags();
			}

			@Override
			public void onError(NotificareError error) {
				Log.e(TAG, "Error registering device", error);
			}
        	
        });
		
	}
	
	/**
	 * Open a notification in a NotificationActivity
	 * @param notificationObject
	 */
	@Kroll.method
	public void openNotification(@Kroll.argument(optional=false, name="notification") KrollDict notificationObject) {
		try {
			JSONObject json = mapToJson(notificationObject);
			NotificareNotification notification = new NotificareNotification(json);
			openNotificationActivity(notification);
		} catch (JSONException e) {
			Log.e(TAG, "Error opening notification: " + e.getMessage());
		}
	}
	
	/**
	 * Add tags to this device
	 * Fires the 'tags' event
	 * @param tags
	 */
	@Kroll.method
	public void addTags(@Kroll.argument(optional=false, name="tags") String[] tags)
	{
		ArrayList<String> tagsList = new ArrayList<String>(tags.length);
		for (String tag: tags) {
			tagsList.add(tag);
		}
		Notificare.shared().addDeviceTags(tagsList, new NotificareCallback<Boolean>(){

			@Override
			public void onError(NotificareError error) {
				Log.e(TAG, "Error adding tags", error);
			}

			@Override
			public void onSuccess(Boolean success) {
				fetchTags();
			}

		});
	}
	
	/**
	 * Remove tag from this device
	 * Fires the 'tags' event
	 * @param tag
	 */
	@Kroll.method
	public void removeTag(@Kroll.argument(optional=false, name="tag") String tag)
	{
		Notificare.shared().removeDeviceTag(tag, new NotificareCallback<Boolean>(){

			@Override
			public void onError(NotificareError error) {
				Log.e(TAG, "Error removing tag", error);
			}

			@Override
			public void onSuccess(Boolean success) {
				fetchTags();
			}
			
		});
	}
	
	/**
	 * Clears all tags from this device
	 * Fires the 'tags' event
	 * @param tag
	 */
	@Kroll.method
	public void clearTags()
	{
		Notificare.shared().clearDeviceTags(new NotificareCallback<Boolean>(){

			@Override
			public void onError(NotificareError error) {
				Log.e(TAG, "Error clearing tags", error);
			}

			@Override
			public void onSuccess(Boolean success) {
				fetchTags();
			}
			
		});
	}
	
	/**
	 * Gets tags set to this device
	 * Fires the 'tags' event
	 */
	@Kroll.method
	public void getTags() {
		fetchTags();
	}
	
	/**
	 * Log a custom event
	 * @param name
	 * @param data
	 */
	@Kroll.method
	public void logCustomEvent(@Kroll.argument(optional=false, name="name") String name, @Kroll.argument(optional=true, name="data") KrollDict data) {
		Notificare.shared().getEventLogger().logCustomEvent(name, data);
	}
	
	/**
	 * Get a sorted list of inbox items
	 * @return
	 * @deprecated use {{@link #fetchInbox(int, int, KrollFunction)} instead
	 */
	@Kroll.method
	public Object[] getInboxItems() {
		Set<NotificareInboxItem> items = Notificare.shared().getInboxManager().getItems();
		List<KrollDict> itemList = new ArrayList<KrollDict>(items.size());
		for (NotificareInboxItem notificareInboxItem : items) {
			KrollDict item = new KrollDict();
			item.put("itemId", notificareInboxItem.getItemId());
			item.put("status", notificareInboxItem.getStatus());
			item.put("message", notificareInboxItem.getNotification().getMessage());
			item.put("timestamp", dateFormatter.format(notificareInboxItem.getTimestamp()));
			item.put("notification", notificareInboxItem.getNotification().getNotificationId());
			itemList.add(item);
		}		
		return itemList.toArray(new Object[itemList.size()]);
	}
	
    /**
     * Fetch inbox items
     * @param args
     * @param callbackContext
     */
	@Kroll.method
	protected void fetchInbox(@Kroll.argument(optional=false, name="success") KrollFunction success) {
		List<KrollDict> inbox = new ArrayList<KrollDict>();
		for (NotificareInboxItem item : Notificare.shared().getInboxManager().getItems()) {
			KrollDict result = new KrollDict();
            result.put("id", item.getItemId());
            result.put("notification", item.getNotification().getNotificationId());
            result.put("message", item.getNotification().getMessage());
            result.put("opened", item.getStatus());
            result.put("time", dateFormatter.format(item.getTimestamp()));
            inbox.add(result);
		}
		KrollDict results = new KrollDict();
		results.put("inbox", inbox.toArray(new Object[inbox.size()]));
		results.put("total", Notificare.shared().getInboxManager().getItems().size());
		results.put("unread", Notificare.shared().getInboxManager().getUnreadCount());
		if (success != null) {
			success.callAsync(getKrollObject(), results);
		}
	}

	
	/**
	 * Mark an item in the inbox as read
	 * @param item
	 */
	@Kroll.method
	public void markAsRead(@Kroll.argument(optional=false, name="item") KrollDict item, @Kroll.argument(optional=true, name="success")KrollFunction success, @Kroll.argument(optional=true, name="error")KrollFunction error) {
		final NotificareInboxItem inboxItem = Notificare.shared().getInboxManager().getItem(item.getString("id"));
		if (inboxItem != null) {
			Notificare.shared().getEventLogger().logOpenNotification(inboxItem.getNotification().getNotificationId());
			Notificare.shared().getInboxManager().markItem(inboxItem);
			if (success != null) {
				success.callAsync(getKrollObject(), new KrollDict());
			}				
		} else {
			if (error != null) {
				KrollDict errorMessage = new KrollDict();
				errorMessage.put("error", "unknown inboxitem");
				error.callAsync(getKrollObject(), errorMessage);				
			}				
		}
	}

	/**
	 * Remove an item from the inbox
	 * @param item
	 */
	@Kroll.method
	public void removeFromInbox(@Kroll.argument(optional=false, name="item") KrollDict item, @Kroll.argument(optional=true, name="success") final KrollFunction success, @Kroll.argument(optional=true, name="error") final KrollFunction error) {
		final NotificareInboxItem inboxItem = Notificare.shared().getInboxManager().getItem(item.getString("id"));
		if (inboxItem != null) {
			Notificare.shared().deleteInboxItem(inboxItem.getItemId(), new NotificareCallback<Boolean>() {
				@Override
				public void onSuccess(Boolean result) {
					Notificare.shared().getInboxManager().removeItem(inboxItem);
					if (success == null) {
						return;
					}
					success.callAsync(getKrollObject(), new KrollDict());
				}

				@Override
				public void onError(NotificareError notificareError) {
					if (error == null) {
						return;
					}
					if (error != null) {
						KrollDict errorMessage = new KrollDict();
						errorMessage.put("error", "Could not delete inbox item");
						error.callAsync(getKrollObject(), errorMessage);				
					}
				}
			});				
		} else {
			if (error != null) {
				KrollDict errorMessage = new KrollDict();
				errorMessage.put("error", "unknown inboxitem");
				error.callAsync(getKrollObject(), errorMessage);				
			}				
		}

	}
	
	@Kroll.method
	public void clearInbox(@Kroll.argument(optional=true, name="success") final KrollFunction success, @Kroll.argument(optional=true, name="error") final KrollFunction error) {
		Notificare.shared().clearInbox(new NotificareCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean result) {
                Notificare.shared().getInboxManager().clearInbox();
				if (success == null) {
					return;
				}
                success.callAsync(getKrollObject(), new KrollDict());
            }

            @Override
            public void onError(NotificareError notificareError) {
				if (error == null) {
					return;
				}
				if (error != null) {
					KrollDict errorMessage = new KrollDict();
					errorMessage.put("error", "Failed to clear inbox");
					error.callAsync(getKrollObject(), errorMessage);				
				}
            }
        });
	}
		
	/**
	 * Open a notification in a NotificationActivity
	 * @param notificationObject
	 */
	@Kroll.method
	public void openInboxItem(@Kroll.argument(optional=false, name="notification") KrollDict item) {
		NotificareInboxItem inboxItem = Notificare.shared().getInboxManager().getItem(item.getString("id"));
		if (inboxItem != null) {
			openNotificationActivity(inboxItem.getNotification());				
		}
	}

	/**
	 * Open notification activity
	 * @param notification
	 */
	public void openNotificationActivity(NotificareNotification notification) {
			Intent notificationIntent = new Intent()
			.setClass(Notificare.shared().getApplicationContext(), NotificationActivity.class)
			.setAction(Notificare.INTENT_ACTION_NOTIFICATION_OPENED)
			.putExtra(Notificare.INTENT_EXTRA_NOTIFICATION, notification)
			.putExtra(Notificare.INTENT_EXTRA_DISPLAY_MESSAGE, Notificare.shared().getDisplayMessage())
			.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);

			TiApplication.getAppCurrentActivity().startActivity(notificationIntent);
	}
	
	/*
	 * Utility methods for converting JSON objects
	 */
	
	/**
	 * Transform a JSONObject into a Map
	 * @see NotificareTitaniumAndroidModule#jsonToObject(Object) for mapping details
	 * @param json
	 * @return
	 */
	private static KrollDict jsonToMap(JSONObject json) {
		KrollDict map = new KrollDict(json.length());
		for (Iterator<String> iter = json.keys(); iter.hasNext();) {
			String key = iter.next();
			try {
				Object value = json.get(key);
				map.put(key, jsonToObject(value));
			} catch (JSONException e) {
				Log.e(TAG, "JSON error: " + e.getMessage());
			}
		}
		return map;
	}
	
	/**
	 * Transform a JSONArray into an Object[]
	 * @see NotificareTitaniumAndroidModule#jsonToObject(Object) for mapping details
	 * @param json
	 * @return
	 */
	private static Object[] jsonToArray(JSONArray json) {
		List<Object> elements = new ArrayList<Object>(json.length());
		for (int i = 0; i < json.length(); i++) {
			try {
				Object value = json.get(i);
				elements.add(jsonToObject(value));
			} catch (JSONException e) {
				Log.e(TAG, "JSON error: " + e.getMessage());
			}
		}
		return elements.toArray(new Object[json.length()]);
	}
	
	/**
	 * Try to convert a JSON value to a Java value, Object[] or Map<String,Object>
	 * If a value has a toJSONObject method, call that one 
	 * @param json
	 * @return
	 */
	public static Object jsonToObject(Object json) {
		if (json instanceof JSONObject) {
			return jsonToMap((JSONObject)json);
		} else if (json instanceof JSONArray) {
			return jsonToArray((JSONArray)json);
		} else {
			try {
				Method method = json.getClass().getMethod("toJSONObject");
				JSONObject object = (JSONObject) method.invoke(json);
				return jsonToMap(object);
			} catch (Exception e) {
				return json;
			}
		}
	}
	
	/**
	 * Transforms an Object[] into JSONArray
	 * @see NotificareTitaniumAndroidModule#objectToJson(Object) for mapping results
	 * @param list
	 * @return
	 */
	private static JSONArray arrayToJson(Object[] list) {
		JSONArray json = new JSONArray();
		for (int i = 0; i < list.length; i++) {
			json.put(objectToJson(list[i]));
		}
		return json;
	}

	/**
	 * Tries to transform a Map into a JSONObject
	 * Non-String keys or non-mappable values are left out
	 * @param map
	 * @return
	 */
	private static JSONObject mapToJson(Map<?,?> map) {
		JSONObject json = new JSONObject();
		for (Object key : map.keySet()) {
			if (key instanceof String) {
				try {
					json.put((String) key, objectToJson(map.get(key)));
				} catch (JSONException e) {
					Log.e(TAG, "JSON error: " + e.getMessage());
				}
			}
		}
		return json;
	}
	
	/**
	 * Try to turn a Map or Object[] into JSONObject or JSONArray
	 * Returns the original Object if not Map or Object[]
	 * @param object
	 * @return
	 */
	public static Object objectToJson(Object object) {
		if (object instanceof Map) {
			return mapToJson((Map<?,?>)object);
		} else if (object instanceof Object[]) {
			return arrayToJson((Object[])object);
		} else {
			return object;
		}
	}
	
}
