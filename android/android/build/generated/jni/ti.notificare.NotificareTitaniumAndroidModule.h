/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2011-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

/** This is generated, do not edit by hand. **/

#include <jni.h>

#include "Proxy.h"

		namespace ti {
		namespace notificare {


class NotificareTitaniumAndroidModule : public titanium::Proxy
{
public:
	explicit NotificareTitaniumAndroidModule(jobject javaObject);

	static void bindProxy(v8::Handle<v8::Object> exports);
	static v8::Handle<v8::FunctionTemplate> getProxyTemplate();
	static void dispose();

	static v8::Persistent<v8::FunctionTemplate> proxyTemplate;
	static jclass javaClass;

private:
	// Methods -----------------------------------------------------------
	static v8::Handle<v8::Value> getUserID(const v8::Arguments&);
	static v8::Handle<v8::Value> logCustomEvent(const v8::Arguments&);
	static v8::Handle<v8::Value> getInboxItems(const v8::Arguments&);
	static v8::Handle<v8::Value> removeTag(const v8::Arguments&);
	static v8::Handle<v8::Value> clearTags(const v8::Arguments&);
	static v8::Handle<v8::Value> markInboxItem(const v8::Arguments&);
	static v8::Handle<v8::Value> registerDevice(const v8::Arguments&);
	static v8::Handle<v8::Value> getTags(const v8::Arguments&);
	static v8::Handle<v8::Value> enableBeacons(const v8::Arguments&);
	static v8::Handle<v8::Value> openNotification(const v8::Arguments&);
	static v8::Handle<v8::Value> getDeviceID(const v8::Arguments&);
	static v8::Handle<v8::Value> setUserID(const v8::Arguments&);
	static v8::Handle<v8::Value> enableBilling(const v8::Arguments&);
	static v8::Handle<v8::Value> removeInboxItem(const v8::Arguments&);
	static v8::Handle<v8::Value> enableLocationUpdates(const v8::Arguments&);
	static v8::Handle<v8::Value> setUserName(const v8::Arguments&);
	static v8::Handle<v8::Value> enableNotifications(const v8::Arguments&);
	static v8::Handle<v8::Value> addTags(const v8::Arguments&);
	static v8::Handle<v8::Value> getUserName(const v8::Arguments&);

	// Dynamic property accessors ----------------------------------------
	static v8::Handle<v8::Value> getter_userName(v8::Local<v8::String> property, const v8::AccessorInfo& info);
	static void setter_userName(v8::Local<v8::String> property, v8::Local<v8::Value> value, const v8::AccessorInfo& info);
	static v8::Handle<v8::Value> getter_userID(v8::Local<v8::String> property, const v8::AccessorInfo& info);
	static void setter_userID(v8::Local<v8::String> property, v8::Local<v8::Value> value, const v8::AccessorInfo& info);
	static v8::Handle<v8::Value> getter_deviceID(v8::Local<v8::String> property, const v8::AccessorInfo& info);

};

		} // notificare
		} // ti
