package ti.notificare;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.TiLifecycle.OnActivityResultEvent;
import org.appcelerator.titanium.TiLifecycle.OnInstanceStateEvent;
import org.appcelerator.titanium.TiRootActivity;
import org.json.JSONException;

import re.notifica.Notificare;
import re.notifica.NotificareError;
import re.notifica.billing.BillingManager;
import re.notifica.billing.BillingResult;
import re.notifica.billing.Purchase;
import re.notifica.model.NotificareApplicationInfo;
import re.notifica.model.NotificareNotification;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;


@Kroll.proxy(creatableInModule=NotificareTitaniumAndroidModule.class)
public class ActivityWorkerProxy extends KrollProxy implements OnActivityResultEvent, OnInstanceStateEvent, Notificare.OnServiceErrorListener, Notificare.OnNotificareReadyListener, Notificare.OnBillingReadyListener, BillingManager.OnRefreshFinishedListener, BillingManager.OnPurchaseFinishedListener
{
	private static final String TAG = "NotificareProxy";

	private NotificareTitaniumAndroidModule module;
	
	// Constructor
	public ActivityWorkerProxy()
	{
		super();
		module = NotificareTitaniumAndroidModule.getModule();
	}

	// Handle creation options
	@Override
	public void handleCreationDict(KrollDict options)
	{
		super.handleCreationDict(options);
		Log.d(TAG, "Notificare proxy created with " + options.toString());
	}
	
	@Override
	public void onCreate(Activity activity, Bundle savedInstance) {
		Log.d(TAG, "Notificare proxy onCreate with intent " + activity.getIntent().getAction());
		if (!module.isReady()) {
			Notificare.shared().addNotificareReadyListener(this);
			module.setReady();
		}
		TiRootActivity root = TiApplication.getInstance().getRootActivity();
		if (root != null) {
			NotificareNotification notification = parseNotificationIntent(root.getActivityProxy().getIntent().getIntent());
			if (notification != null) {
				Log.i(TAG, "Started with notification open intent");
				try {
					KrollDict event = new KrollDict();
					event.put("notification", NotificareTitaniumAndroidModule.jsonToObject(notification.toJSONObject()));
					event.put("alert", notification.getMessage());
				    event.put("extras", notification.getExtra());
				    module.fireEvent("notification", event);
				} catch (JSONException e) {
					Log.e(TAG, "JSON parse error");
				}
			} else {
				Uri target = parseCustomActionIntent(root.getActivityProxy().getIntent().getIntent());
				if (target != null) {
					Log.i(TAG, "Started with custom action intent");
					KrollDict event = new KrollDict();
					event.put("target", target.toString());
					module.fireEvent("action", event);
				}
			}
		}
	}

	@Override
	public void onResume(Activity activity){
		Log.d(TAG, "Notificare proxy onResume");
		Notificare.shared().setForeground(true);
		Notificare.shared().getEventLogger().logStartSession();
	}
	
	@Override
	public void onPause(Activity activity) {
		Log.d(TAG, "Notificare proxy onPause");
		Notificare.shared().setForeground(false);
		Notificare.shared().getEventLogger().logEndSession();
	}

	@Override
	public void onDestroy(Activity activity) {
		Log.d(TAG, "Notificare proxy onDestroy");
		Notificare.shared().removeNotificareReadyListener(this);

	}

	@Override
	public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent intent) {
		Log.d(TAG, "Notificare proxy onActivityResult");
		Notificare.shared().handleServiceErrorResolution(requestCode, resultCode, intent);
	}

	@Override
	public void onSaveInstanceState(Bundle outState) {
		Log.d(TAG, "Notificare proxy onSaveInstanceState");
	}

	@Override
	public void onRestoreInstanceState(Bundle inState) {
		Log.d(TAG, "Notificare proxy onSaveInstanceState");		
	}
	
	@Override
	public void onNotificareReady(NotificareApplicationInfo applicationInfo) {
		Log.d(TAG, "ready");
		module.fireEvent("ready", new KrollDict());
	}
	
	@Override
	public void onServiceError(int errorCode, int requestCode) {
		if (Notificare.isUserRecoverableError(errorCode)) {
            Notificare.getErrorDialog(errorCode, getActivity(), requestCode).show();
        }
	}
	
	@Override
	public void onPurchaseFinished(BillingResult result, Purchase purchase) {
		KrollDict event = new KrollDict();
	    event.put("transaction", purchase.getProductId());
	    module.fireEvent("transaction", event);
	}

	@Override
	public void onRefreshFailed(NotificareError error) {
		KrollDict event = new KrollDict();
	    event.put("error", error);
	    module.fireEvent("errors", event);
	}

	@Override
	public void onRefreshFinished() {
		// TODO Auto-generated method stub
		
	}
	
	@Override
	public void onBillingReady() {
		module.fireEvent("store", new KrollDict());
	}
	
	/*
	 * Intent parsing
	 */
	
	/**
	 * Parse notification from launch intent
	 * @param intent
	 * @return
	 */
	protected NotificareNotification parseNotificationIntent(Intent intent) {
		if (intent != null && intent.getAction() != null && intent.getAction().equals(Notificare.INTENT_ACTION_NOTIFICATION_OPENED) && intent.hasExtra(Notificare.INTENT_EXTRA_NOTIFICATION)) {
			return intent.getParcelableExtra(Notificare.INTENT_EXTRA_NOTIFICATION);
		} else {
			return null;
		}
	}
	
	/**
	 * Parse custom action from launch intent
	 * @param intent
	 * @return
	 */
	protected Uri parseCustomActionIntent(Intent intent) {
		if (intent != null && intent.getAction() != null && intent.getAction().equals(Notificare.INTENT_ACTION_CUSTOM_ACTION)) {
			return intent.getData();
		} else {
			return null;
		}
	}
	

}	