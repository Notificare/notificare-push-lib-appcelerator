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

var deviceToken = null;

notificare.addEventListener('ready',function(e){
	
	//For iOS
	if (Ti.Platform.name == "iPhone OS"){
		
		//notificare.registerForNotifications(e);
		
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
		}
		 
		// For iOS 7 and earlier
		else {
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
	

	//If using saveToInbox() on receivePush() with background remote notifications
	//you can then access the Inbox 
	notificare.fetchInbox(function(e){

		if(e && e.length > 0){
			
			//If you want to use the default inbox
			//notificare.openInbox();
			
			//If you want to build with your own UI
			//You can loop over the items
			e.forEach(function(msg){
				Ti.API.info("Message: " + msg.aps.alert);
				//You can also remove messages from the inobox
				//notificare.removeFromInbox(msg);
			});
		
		} else {
			Ti.API.info("Empty Inbox");
		}

	});
	
	notificare.logCustomEvent('someEvent', null, function(e){
		
		if(e.success){
			Ti.API.info("Message: " + e.success.message);
		}
	});
	
});


//Listen for the device registered event
//Only after this event occurs it is safe to call any other method
notificare.addEventListener('registered', function(e){
	notificare.startLocationUpdates(e);
	 //var tags = ['one','two'];
	 //notificare.addTags(tags);
	 //notificare.clearTags();
	 //notificare.openUserPreferences(e);
	 //notificare.openInbox(e);
	 //notificare.openBeacons(e);
	 //notificare.removeTag('one');

});

notificare.addEventListener('action', function(e){
	
	if(e.target){
 		Ti.API.info(e.target);
 	}
	 
});

// Triggered every time device tags change
notificare.addEventListener('tags', function(e){
	
	if(e && e.tags && e.tags.length > 0){
		e.tags.forEach(function(tag){
			Ti.API.info("Device Tag: " + tag);
		});
	}
	
	 
});

//Implement this listener to react on clicks from iOS8+ interactive notifications 
Ti.App.iOS.addEventListener('remotenotificationaction', function(e) {
	 notificare.handleAction({
	 	notification: e.data,
	 	identifier: e.identifier
	 }, function(e){
	 	if(e.success){
	 		Ti.API.info(e.success.message);
	 	} else {
	 		Ti.API.info(e.error.message);
	 	}
	 });
});


// 
// //Fired when a transaction changes state
// notificare.addEventListener('location', function(e){
	 // Ti.API.info("User location changed " + e.latitude + e.longitude);
// });
// 
// //Fired when a transaction changes state
// notificare.addEventListener('transaction', function(e){
	 // Ti.API.info(e.message + e.transaction);
// });
// 
// //Only available for iOS. This is fired whenever a product's downloadable content is finished.
// notificare.addEventListener('download', function(e){
	 // Ti.API.info(e.message + e.download);
// });
// 
// //Fired when the store is ready
// notificare.addEventListener('store', function(e){
	// if(e && e.products && e.products.length > 0){
		 // e.products.forEach(function(product){
			// Ti.API.info("Product: " + product.identifer + product.name);
		// });
	// }
	 // //After this trigger is it safe to buy products
	 // // use Notificare.buyProduct(product.identifier);
	 // // To buy products
// 	 
// });
// 
// //Fired whenever there's errors
// notificare.addEventListener('errors', function(e){
	 // Ti.API.info("There was an error " + e.error);
	 // Ti.API.info("with message " + e.message);
// });
// 
//Fired whenever app is in foreground and in range of any of the beacons inserted in the current region
notificare.addEventListener('range', function(e){
	//Ti.API.info("Beacon: " + e);
	if(e && e.beacons && e.beacons.length > 0){
		e.beacons.forEach(function(beacon){
			//Ti.API.info("Beacon: " + beacon.name + beacon.proximity);
		});
	}
});


// Process incoming push notifications
function receivePush(e) {
	//notificare.saveToInbox(e.data);
    notificare.openNotification(e.data);
}
// Save the device token for subsequent API calls
function deviceTokenSuccess(e) {
    notificare.registerDevice(e.deviceToken);
}
function deviceTokenError(e) {
    alert('Failed to register for push notifications! ' + e.error);
}
