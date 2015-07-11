/**
 * Sample code for Notificare Titanium module
 * 
 * @author Joel Oliveira <joel@notifica.re>
 * @author Joris Verbogt <joris@notifica.re>
 * @license MIT
 */

var notificare = require('ti.notificare');


var win = Titanium.UI.createWindow({  
    title:'Window',
    backgroundColor:'#fff'
});

var label = Titanium.UI.createLabel({
	color: '#999',
	text: 'Hello, World',
	font: {
		fontSize:20,
		fontFamily:'Helvetica Neue'
	},
	textAlign: 'center',
	width: 'auto'
});
win.add(label);

/*
 * In Classic apps, hook up the lifecycle events for Android to the module
 */
if (Ti.Platform.name == "android") {
	win.notificareProxy = notificare.createActivityWorker({lifecycleContainer: win});
}
win.open();

/*
 * In Alloy apps, add a global reference for use in controllers
 * 
 * 		Alloy.Globals.Notificare = notificare;
 * 
 * Then, in your controllers, hook up the lifecycle events to the module like so
 * 
 * 		(function init() {
 * 			if (Ti.Platform.name == "android"){
 *				$.index.notificareProxy = Alloy.Globals.Notificare.createActivityWorker({lifecycleContainer: $.index});
 *			}
 * 			$.index.open();
 * 		})();
 * 
 */


var deviceToken = null;

/**
 * Process incoming push notifications from iOS
 */
function receivePush(e) {
	//notificare.saveToInbox(e.data);
    notificare.openNotification(e.data);
}

/**
 * Save the device token for subsequent API calls (iOS)
 */
function deviceTokenSuccess(e) {
    notificare.registerDevice(e.deviceToken);
}

/**
 * Handle device token error (iOS)
 */
function deviceTokenError(e) {
    alert('Failed to register for push notifications! ' + e.error);
}

/*
 * Implement this listener to react on clicks from iOS8+ interactive notifications
 */ 
if (Ti.Platform.name == "iPhone OS"){
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
}

notificare.addEventListener('ready', function(e) {
	
	// For iOS
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
		        
		        notificare.registerUserNotifications();
		    });
		 
			 // Register notification types to use
		    Ti.App.iOS.registerUserNotificationSettings({
			    types: [
		            Ti.App.iOS.USER_NOTIFICATION_TYPE_ALERT,
		            Ti.App.iOS.USER_NOTIFICATION_TYPE_SOUND,
		            Ti.App.iOS.USER_NOTIFICATION_TYPE_BADGE
		        ]
		    });
		} else {
			// For iOS 7 and earlier, specifies which notifications to receive
		    Ti.Network.registerForPushNotifications({
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

	// For Android
	if (Ti.Platform.name == "android") {
		notificare.enableNotifications();
	}
});

/**
 * Successful registration to APNS or GCM, let's register the device on Notificare API
 */
notificare.addEventListener('registration', function(e) {
	
	//notificare.userID = 'testing123';
    //notificare.userName = 'Name here';
	notificare.registerDevice(e.device);

});

/**
 * Listen for the device registered event
 * Only after this event occurs it is safe to call any other method
 */

notificare.addEventListener('registered', function(e) {
	if (Ti.Platform.name == "iPhone OS") {
		notificare.startLocationUpdates(e);
	}

	if (Ti.Platform.name == "android") {
		notificare.enableLocationUpdates();
		notificare.enableBeacons();
	}
	
	notificare.addTags(['one', 'two']);
	notificare.logCustomEvent('titanium', {test: true});
	
});

/**
 * Listen to notification event
 */
notificare.addEventListener('notification', function(e) {
	if (e && e.notification) {
		Ti.API.info(e.notification.message);
		notificare.openNotification(e.notification);
	}
});

/**
 * Listen to tags event
 */
notificare.addEventListener('action', function(e){
	if (e && e.target) {
 		Ti.API.info(e.target);
 	}
});

/**
 * Listen to tags event
 */
notificare.addEventListener('tags', function(e) {
	if (e && e.tags && e.tags.length > 0) {
		e.tags.forEach(function(tag) {
			Ti.API.info("Device Tag: " + tag);
		});
	}
});

/**
 * Fired when a location changes
 */
notificare.addEventListener('location', function(e) {
	 Ti.API.info("User location changed " + e.latitude + e.longitude);
});

/**
 * Fired whenever app is in foreground and in range of any of the beacons inserted in the current region
 */
notificare.addEventListener('range', function(e) {
	if (e && e.beacons && e.beacons.length > 0) {
		e.beacons.forEach(function(beacon) {
			Ti.API.info("Beacon: " + beacon.name  + " " + beacon.proximity);
		});
	}
});
