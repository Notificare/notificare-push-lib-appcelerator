# Notificare Module

## Description

Titanium module for Notificare Mobile Marketing Platform. Before you start make sure you grab the notificareconfig.properties from https://github.com/Notificare/notificare-push-lib-android/blob/master/Samples/PushMe/assets/notificareconfig.properties.template and place it in your app's platform/android/bin/assets folder. This is the configuration file where you should make changes to match your app's settings.

## Accessing the Notificare Module

To access this module from JavaScript, you would do the following:

```javascript
	var Notificare = require("ti.notificare");
```

The Notificare variable is a reference to the Module object.	

Then, you need to hook up your view's lifecycle events to the module:

```javascript
	var win = Titanium.UI.createWindow({  
	    title:'Window',
	    backgroundColor:'#fff'
	});
	
	if (Ti.Platform.name == "android") {
		win.notificareProxy = notificare.createActivityWorker({lifecycleContainer: win});
	}
	win.open();
```

In Alloy, you should do this in your controller

```javascript
	(function init() {
		if (Ti.Platform.name == "android"){
			$.index.notificareProxy = Alloy.Globals.Notificare.createActivityWorker({lifecycleContainer: $.index});
		}
		$.index.open();
	})();
```

## Reference

### Notificare.addEventListener

Notificare will be initialized at launch automatically. But before you can request any of the methods you must wait for the 'ready' event to be fired. 

Events:
- ready (required) {String} Fired whenever the Notificare library is ready
- registration (required) {String} Fired in response to registerForNotifications or enableNotifications. Contains the device token, use it to register to Notificare
- registered (optional) {String} Fired when the device is registered with Notificare
- location (optional) {String} Fired when the device's location is updated
- notification (optional) {String} Fired when a notification is received
- range (optional) {String} Fired when beacons are in range. This only occurs in foreground
- errors (optional) {String} Fired whenever there's errors

Parameters:

- event (required) {String} A string representing the event to listen to
- callback {Function} A callback ({Object})

### Notificare.enableNotifications

Registers the device with GCM. In response to this method the event 'registration' will be fired.

### Notificare.enableLocationUpdates

Start location updates for this device.

### Notificare.enableBeacons

If you are using beacons please make sure you call this method after the 'ready' event is fired.

### Notificare.enableBilling

If you are going to sell in-app products in Google Play, please invoke this method after the 'ready' event is fired.

### Notificare.userID

Set this value to register the device with a userID. It should be set before calling Notificare.registerDevice().

### Notificare.userName

Set this value to register the device with a userName. To use this, userID must be also set. It should be set before calling Notificare.registerDevice().


### Notificare.registerDevice

Registers the device with Notificare. It should be invoked after the 'ready' event.

Parameters:

- token (required) {String}

### Notificare.addTags

Adds one or more tags to the device. This should only be called after the event 'registered' has been fired.

Parameters:

- tags [{String}]

### Notificare.removeTag

Removes a tag from the device.  This should only be called after the event 'registered' has been fired.

Parameters:

- tag {String}

### Notificare.buyProduct

Starts a transaction with Google Play. This should only be called after the event 'store' has been fired.

Parameters:

- identifier {String} Use the product identifier to start a transaction

## Usage

See sample app in example/app.js. For documentation please refer to: https://notificare.atlassian.net/wiki/display/notificare/Getting+started+with+Titanium


## Authors

- Joel Oliveira <joel@notifica.re>
- Joris Verbogt <joris@notifica.re>

Copyright (c) 2015 Notificare B.V.


## License

Simplified BSD