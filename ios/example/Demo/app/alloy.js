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
});


//Listen for the device registered event
//Only after this event occurs it is safe to call any other method
notificare.addEventListener('registered', function(e) {
	notificare.startLocationUpdates(e);
	 //var tags = ['one','two'];
	 //notificare.addTags(tags);
	 //notificare.clearTags();
	 //notificare.openUserPreferences(e);
	 //notificare.openBeacons(e);
	 //notificare.removeTag('one');
	 
	 /*
		notificare.fetchInbox(function(e){
			Ti.API.info(e.inbox);
			
			e.inbox.forEach(function(item){
				//Open inbox item
				notificare.openInboxItem(item);
				
				//Mark as read
				notificare.markAsRead(item, function(response){
					
				});
				
				//Remove item
				notificare.removeFromInbox(item, function(response){
					
				});
				
				//Remove all items
				notificare.clearInbox(function(response){
					
				});
			});
		});
	  */
});

notificare.addEventListener('action', function(e){
	
	if (e.target) {
 		Ti.API.info(e.target);
 	}
	 
});

// Triggered every time device tags change
notificare.addEventListener('tags', function(e) {
	if (e && e.tags && e.tags.length > 0) {
		e.tags.forEach(function(tag) {
			Ti.API.info("Device Tag: " + tag);
		});
	}
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


//Fired whenever app is in foreground and in range of any of the beacons inserted in the current region
notificare.addEventListener('range', function(e) {
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
    	notificare.registerDevice(e.deviceToken);
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
