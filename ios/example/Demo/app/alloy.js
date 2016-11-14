// The contents of this file will be executed before any of
// your view controllers are ever executed, including the index.
// You have access to all functionality on the `Alloy` namespace.
//
// This is a great place to do any initialization for your app
// or create any global variables/functions that you'd like to
// make available throughout your app. You can easily make things
// accessible globally by attaching them to the `Alloy.Globals`
// object. For example:
//
// Alloy.Globals.someGlobalFunction = function(){};

var notificare = require('ti.notificare');

Ti.API.info("module is => " + notificare);

Alloy.Globals.notificare = notificare;

var deviceToken = null;

notificare.addEventListener('ready',function(e) {
	//For iOS
	if (Ti.Platform.name == "iPhone OS") {
		
		if (parseInt(Ti.Platform.version.split(".")[0]) >= 8) {
 
		 // Wait for user settings to be registered before registering for push notifications
		    Ti.App.iOS.addEventListener('usernotificationsettings', function registerForPush() {
		 		// Remove event listener once registered for push notifications
		        Ti.App.iOS.removeEventListener('usernotificationsettings', registerForPush); 
		        Ti.Network.registerForPushNotifications({
		            success: deviceTokenSuccess,
		            error: deviceTokenError,
		            callback: receivePush
		        });
		    });
		    notificare.registerUserNotifications();		 
		} else {
			// For iOS 7 and earlier
		    Ti.Network.registerForPushNotifications({
		 		// Specifies which notifications to receive
		        types: [
		            Ti.Network.NOTIFICATION_TYPE_BADGE,
		            Ti.Network.NOTIFICATION_TYPE_ALERT,
		            Ti.Network.NOTIFICATION_TYPE_SOUND
		        ],
		        success: deviceTokenSuccess,
		        error: deviceTokenError,
		        callback: receivePush
		    });
		}
	}
	
	//notificare.logCustomEvent('someEvent', null, function(e) {
	//	if (e.success) {
	//		Ti.API.info("Message: " + e.success.message);
	//	}
	//});
	
	/*
	notificare.fetchAssets('test', function(e){
	 	if (e && e.assets && e.assets.length > 0) {
			e.assets.forEach(function(asset) {
				Ti.API.info("Asset: " + asset.title);
				Ti.API.info("Asset: " + asset.description);
				Ti.API.info("Asset: " + asset.metaData);
				Ti.API.info("Asset: " + asset.button);
				Ti.API.info("Asset: " + asset.url);
			});
		}
	 });
	 */
});



//Implement this listener to react on clicks from iOS8+ interactive notifications 
Ti.App.iOS.addEventListener('remotenotificationaction', function(e) {
	 notificare.handleAction({
	 	notification: e.data,
	 	identifier: e.identifier
	 }, function(e) {
	 	if (e.success) {
	 		Ti.API.info(e.success.message);
	 	} else {
	 		Ti.API.info(e.error.message);
	 	}
	 });
});

//Fired whenever a notification is opened, it can be used to refresh UI
notificare.addEventListener('didOpenNotification', function(e) {
	Ti.API.info("Notification: " + e.notification.id);
});

//Fired whenever an action is executed, it can be used to refresh UI
notificare.addEventListener('didExecuteAction', function(e){
	
	Ti.API.info(e);
	 
});

//Fired whenever app is in foreground and in range of any of the beacons inserted in the current region
notificare.addEventListener('didRangeBeacons', function(e) {
	//Ti.API.info("Beacon: " + e);
	if (e && e.beacons && e.beacons.length > 0) {
		e.beacons.forEach(function(beacon) {
			//Ti.API.info("Beacon: " + beacon.name + beacon.proximity);
		});
	}
});


/*
 * Functions for handling Ti.Network callbacks
 * These callbacks are fired on a separate thread, use setTimeout() to force the action to be executed on the UI thread.
 */

/**
 * Process incoming push notifications
 * @param {Event} e
 */
function receivePush(e) {
	setTimeout(function() {
		notificare.openNotification(e.data);
 	}, 0);
}

/**
 * Save the device token for subsequent API calls
 * @param {Event} e
 */
function deviceTokenSuccess(e) {
	setTimeout(function() {
		Ti.API.info(e.deviceToken);
    	notificare.registerDevice(e.deviceToken, function(e){
    		
			if (!e.error) {
    			
				notificare.startLocationUpdates(e);
    		
				notificare.fetchTags(function(e){
					Ti.API.info(e.tags);
				});
				 
				var tags = ['appcelerator'];
				notificare.addTags(tags, function(e){
				  	
				});
				 
				//notificare.clearTags(function(e){
				// 	
				//});
				
				//notificare.removeTag('appcelerator', function(e){
				// 	
				//});
				 
				//notificare.openUserPreferences(e);
				//notificare.openBeacons(e);
				 
				 /*
				  notificare.fetchPass('efbfc9bd-7249-4f46-8f4d-fb564cd679d3', function(e){
				 	if (e && e.pass) {
						Ti.API.info("Pass: " + e.pass.passbook);
						Ti.API.info("Pass: " + e.pass.serial);
						Ti.API.info("Pass: " + e.pass.data);
						Ti.API.info("Pass: " + e.pass.date);
						Ti.API.info("Pass: " + e.pass.redeem);
						Ti.API.info("Pass: " + e.pass.redeemHistory);
						Ti.API.info("Pass: " + e.pass.limit);
						Ti.API.info("Pass: " + e.pass.active);
						Ti.API.info("Pass: " + e.pass.token);
					}
				 });
				  */
    		}
    		
    	});
 	}, 0);
}

/**
 * Error obtaining device token
 * @param {Event} e
 */
function deviceTokenError(e) {
	setTimeout(function() {
		alert('Failed to register for push notifications! ' + e.error);
	}, 0);
}
