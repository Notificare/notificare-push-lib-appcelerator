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

notificare.addEventListener('ready',function(e) {
	Ti.API.info("Notificare ready");
	notificare.enableNotifications();
});

/**
 * Successful registration to APNS or GCM, let's register the device on Notificare API
 */
Ti.API.info("add listener for registration events");
notificare.addEventListener('registration', function(e) {
	Ti.API.info("device registered to push");
	notificare.userID = "TestAlloyUser";
	notificare.registerDevice(e.device);
	Ti.API.info(notificare.userID);
});

//Listen for the device registered event
//Only after this event occurs it is safe to call any other method
notificare.addEventListener('registered', function(e) {
	Ti.API.info("device registered to Notificare");
	notificare.enableLocationUpdates(function(e) {
		if (e.success) {
			notificare.enableLocationUpdates();		
		}
	});
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

/**
 * Successful registration to APNS or GCM, let's register the device on Notificare API
 */
Ti.API.info("add listener for notification events");
notificare.addEventListener('notification', function(e) {
	Ti.API.info("notification opened: " + e.alert);
	notificare.openNotification(e.notification);
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


//Fired whenever app is in foreground and in range of any of the beacons inserted in the current region
notificare.addEventListener('range', function(e) {
	//Ti.API.info("Beacon: " + e);
	if (e && e.beacons && e.beacons.length > 0) {
		e.beacons.forEach(function(beacon) {
			//Ti.API.info("Beacon: " + beacon.name + beacon.proximity);
		});
	}
});
