/**
 * notificare-titanium-ios
 *
 * Created by Your Name
 * Copyright (c) 2015 Your Company. All rights reserved.
 */

#import "TiNotificareModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"
#import "NSData+Hex.h"

@implementation TiNotificareModule


enum {
    WDASSETURL_PENDINGREADS = 1,
    WDASSETURL_ALLFINISHED = 0
};



#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"d68e92a8-c6e7-4a31-a140-2d00ab8e0dab";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ti.notificare";
}

#pragma mark Lifecycle

-(void)startup
{
    // this method is called when the module is first loaded
    // you *must* call the superclass
    [super startup];
    
    TiThreadPerformOnMainThread(^{
        [[NotificarePushLib shared] launch];
        [[NotificarePushLib shared] setDelegate:self];
    }, NO);

    
    NSLog(@"[INFO] %@ loaded",self);
}

+(void)load
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppCreate:)
                                                 name:@"UIApplicationDidFinishLaunchingNotification" object:nil];

    
}

+(void)onAppCreate:(NSNotification *)notification
{

    ENSURE_CONSISTENCY([NSThread isMainThread]);
    
    //[[NotificarePushLib shared] handleOptions:notification.userInfo];
    
}




- (void)notificarePushLib:(NotificarePushLib *)library onReady:(NSDictionary *)info{
    
    [self fireEvent:@"ready" withObject:info];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didChangeAccountNotification:(NSDictionary *)info{

//    NSMutableDictionary * trans = [NSMutableDictionary dictionary];
//    NotificareNXOAuth2Account * account = [[NotificarePushLib shared] account];
//    NSMutableDictionary * act = [NSMutableDictionary dictionary];
//    [act setValue:[[account accessToken] tokenType] forKey:@"tokenType"];
//    [act setValue:[[account accessToken] accessToken] forKey:@"accessToken"];
//    [act setValue:[[account accessToken] refreshToken] forKey:@"refreshToken"];
//    [act setValue:[account userData] forKey:@"user"];
//    [act setValue:[NSString stringWithFormat:@"%@",[[account accessToken] expiresAt]] forKey:@"expiresAt"];
//    [trans setValue:act forKey:@"account"];
//    [self fireEvent:@"account" withObject:trans];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToRequestAccessNotification:(NSError *)error{

    NSMutableDictionary * trans = [NSMutableDictionary dictionary];
    NSMutableDictionary * err = [NSMutableDictionary dictionary];
    [err setObject:@"403" forKey:@"code"];
    [err setObject:@"Invalid resource owner credentials" forKey:@"message"];
    [trans setObject:err forKey:@"error"];
    [self fireEvent:@"account" withObject:trans];
}


- (void)notificarePushLib:(NotificarePushLib *)library didLoadStore:(NSArray *)products{
    
    NSMutableArray * prods = [NSMutableArray array];
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    NSMutableDictionary * prod = [NSMutableDictionary dictionary];
    
    for (NotificareProduct * product  in products) {
        [prod setObject:product.productName forKey:@"name"];
        [prod setObject:product.productDescription forKey:@"description"];
        [prod setObject:product.identifier forKey:@"identifier"];
        [prod setObject:product.type forKey:@"type"];
        [prod setObject:[NSNumber numberWithBool:product.purchased] forKey:@"purchased"];
        [prod setObject:product.priceLocale forKey:@"price"];
        
        NSMutableArray * downloads = [NSMutableArray array];
        NSMutableDictionary * download = [NSMutableDictionary dictionary];
        
        for (SKDownload * d in product.downloads) {
            [d setValue:d.contentIdentifier forKey:@"contentIdentifier"];
            [d setValue:[NSString stringWithFormat:@"%f",d.progress] forKey:@"progress"];
            [d setValue:[NSString stringWithFormat:@"%f",d.timeRemaining] forKey:@"timeRemaining"];
            [d setValue:[NSNumber numberWithInt:d.downloadState] forKey:@"downloadState"];
            [downloads addObject:download];
        }
        [prod setObject:downloads forKey:@"downloads"];
        [prods addObject:prod];
    }
    
    [result setValue:prods forKey:@"products"];
    [self fireEvent:@"store" withObject:result];
}


- (void)notificarePushLib:(NotificarePushLib *)library didFailProductTransaction:(SKPaymentTransaction *)transaction withError:(NSError *)error{
    
    NSMutableDictionary * err = [NSMutableDictionary dictionary];
    [err setValue:@"Transaction failed" forKey:@"message"];
    [err setValue:error.userInfo.description forKey:@"error"];
    [self fireEvent:@"errors" withObject:err];
}

- (void)notificarePushLib:(NotificarePushLib *)library didCompleteProductTransaction:(SKPaymentTransaction *)transaction{
    
    NSMutableDictionary * trans = [NSMutableDictionary dictionary];
    [trans setValue:@"Transaction completed" forKey:@"message"];
    [trans setValue:transaction.payment.productIdentifier forKey:@"transaction"];
    [self fireEvent:@"transaction" withObject:trans];
}

- (void)notificarePushLib:(NotificarePushLib *)library didRestoreProductTransaction:(SKPaymentTransaction *)transaction{
    
    NSMutableDictionary * trans = [NSMutableDictionary dictionary];
    [trans setValue:@"Transaction restored" forKey:@"message"];
    [trans setValue:transaction.payment.productIdentifier forKey:@"transaction"];
    [self fireEvent:@"transaction" withObject:trans];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didStartDownloadContent:(SKPaymentTransaction *)transaction{
    
    NSMutableDictionary * trans = [NSMutableDictionary dictionary];
    [trans setValue:@"Started download for transaction" forKey:@"message"];
    [trans setValue:transaction.payment.productIdentifier forKey:@"transaction"];
    [self fireEvent:@"transaction" withObject:trans];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFinishDownloadContent:(SKDownload *)download{
    
    NSMutableDictionary * d = [NSMutableDictionary dictionary];
    [d setValue:@"Download finished" forKey:@"message"];
    [d setValue:download.transaction.payment.productIdentifier forKey:@"download"];
    [self fireEvent:@"download" withObject:d];
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToLoadStore:(NSError *)error{
    
    NSMutableDictionary * err = [NSMutableDictionary dictionary];
    [err setValue:@"Load store failed" forKey:@"message"];
    [err setValue:error.userInfo.description forKey:@"error"];
    [self fireEvent:@"errors" withObject:err];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToStartLocationServiceWithError:(NSError *)error{
    
    NSMutableDictionary * err = [NSMutableDictionary dictionary];
    [err setValue:@"Location services failed" forKey:@"message"];
    [err setValue:error.userInfo.description forKey:@"error"];
    [self fireEvent:@"errors" withObject:err];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateLocations:(NSArray *)locations{
    CLLocation * lastLocation = (CLLocation *)[locations lastObject];
    NSMutableDictionary * location = [NSMutableDictionary dictionary];
    [location setValue:[NSNumber numberWithFloat:[lastLocation coordinate].latitude] forKey:@"latitude"];
    [location setValue:[NSNumber numberWithFloat:[lastLocation coordinate].longitude] forKey:@"longitude"];
    [self fireEvent:@"location" withObject:location];
}

- (void)notificarePushLib:(NotificarePushLib *)library didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    NSMutableDictionary * b = [NSMutableDictionary dictionary];
    NSMutableArray * bcn = [NSMutableArray array];
    for (NotificareBeacon * beacon in beacons) {
        [b setObject:beacon.name forKey:@"name"];
        [b setObject:beacon.purpose forKey:@"purpose"];
        [b setObject:beacon.notification forKey:@"notification"];
        [b setObject:beacon.region forKey:@"region"];
        [b setObject:[NSString stringWithFormat:@"%@", beacon.beacon.major] forKey:@"major"];
        [b setObject:[NSString stringWithFormat:@"%@", beacon.beacon.minor] forKey:@"minor"];
        [b setObject:[NSString stringWithFormat:@"%@", beacon.beacon.proximityUUID] forKey:@"uuid"];
        [b setObject:[NSString stringWithFormat:@"%li", (long)beacon.beacon.proximity]  forKey:@"proximity"];
        if([beacon proximityNotifications]){
            [b setObject:beacon.proximityNotifications forKey:@"notifications"];
        }
        [bcn addObject:b];
    }
    [result setValue:bcn forKey:@"beacons"];
    [self fireEvent:@"range" withObject:result];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateBadge:(int)badge{
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    [result setValue:[NSString stringWithFormat:@"%li",(long)badge] forKey:@"badge"];
    [self fireEvent:@"badge" withObject:result];
}


-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably

	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup

-(void)dealloc
{
    
    RELEASE_TO_NIL(userId);
    RELEASE_TO_NIL(username);
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
    
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
    
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs


-(id)userID
{
    return userId;
}

-(void)setUserID:(id)value
{
    // Macro from TiBase.h to type check the data
    ENSURE_STRING(value);
    // Call the retain method to keep a reference to the passed value
    userId = [value retain];
}


-(id)userName
{
    return username;
}

-(void)setUserName:(id)value
{
    // Macro from TiBase.h to type check the data
    ENSURE_STRING(value);
    // Call the retain method to keep a reference to the passed value
    username = [value retain];
}

-(void)registerDevice:(id)arg
{
    ENSURE_SINGLE_ARG(arg, NSString);
    ENSURE_UI_THREAD_1_ARG(arg);
    
    // The token received in the success callback to 'Ti.Network.registerForPushNotifications' is a hex-encode
    // string. We need to convert it back to it's byte format as an NSData object.
    
    NSMutableData *token = [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = { '\0', '\0', '\0' };
    int i;
    for (i=0; i<[arg length]/2; i++) {
        byte_chars[0] = [arg characterAtIndex:i*2];
        byte_chars[1] = [arg characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [token appendBytes:&whole_byte length:1];
    }
    

    if(userId && username){
        
        [[NotificarePushLib shared] registerDevice:token withUserID:userId withUsername:username completionHandler:^(NSDictionary *info) {
            //
            [self fireEvent:@"registered" withObject:info];
            
            [self getTags];
            
        } errorHandler:^(NSError *error) {
            //
        }];

    } else if(userId && !username){
        [[NotificarePushLib shared] registerDevice:token withUserID:userId completionHandler:^(NSDictionary *info) {
            //
            [self fireEvent:@"registered" withObject:info];
            [self getTags];
        } errorHandler:^(NSError *error) {
            //
        }];
    } else {
        [[NotificarePushLib shared] registerDevice:token completionHandler:^(NSDictionary *info) {
            //
            [self fireEvent:@"registered" withObject:info];
            [self getTags];
        } errorHandler:^(NSError *error) {
            //
        }];
    }
 
}

-(void)getTags{
    [[NotificarePushLib shared] getTags:^(NSDictionary *info) {
        NSMutableArray * t = [NSMutableArray array];
        for (NSString * tag in [info objectForKey:@"tags"]) {
            [t addObject:tag];
        }
        
        NSMutableDictionary * tags = [NSMutableDictionary dictionary];
        [tags setValue:t forKey:@"tags"];
        
        [self fireEvent:@"tags" withObject:tags];
        
    } errorHandler:^(NSError *error) {
        //
    }];
}

-(void)startLocationUpdates:(id)arg
{

    ENSURE_UI_THREAD(startLocationUpdates, arg);
    [[NotificarePushLib shared] startLocationUpdates];
    
}


-(void)openNotification:(id)arg
{
    // The only argument to this method is the userInfo dictionary received from
    // the remote notification
    
    ENSURE_UI_THREAD_1_ARG(arg);

    id userInfo = [arg objectAtIndex:0];
    ENSURE_DICT(userInfo);
    
   [[NotificarePushLib shared] openNotification:userInfo];
    
}


-(void)addTags:(id)arg
{

    ENSURE_UI_THREAD_1_ARG(arg);
    ENSURE_SINGLE_ARG(arg, NSArray);
    
    [[NotificarePushLib shared] addTags:arg completionHandler:^(NSDictionary *info) {
        //
        [self getTags];
    } errorHandler:^(NSError *error) {
        //
    }];
    
}

-(void)removeTag:(id)arg
{
    ENSURE_UI_THREAD_1_ARG(arg);
    ENSURE_SINGLE_ARG(arg, NSString);

    [[NotificarePushLib shared] removeTag:arg completionHandler:^(NSDictionary *info) {
        [self getTags];
    } errorHandler:^(NSError *error) {
        //
    }];
    
}

-(void)clearTags:(id)arg
{
    ENSURE_UI_THREAD_0_ARGS;
    
    [[NotificarePushLib shared] clearTags:^(NSDictionary *info) {
        [self getTags];
    } errorHandler:^(NSError *error) {
        //
    }];
    
}

-(void)openBeacons:(id)arg
{
    ENSURE_UI_THREAD_0_ARGS;
    
    [[NotificarePushLib shared] openBeacons];
    
}

-(void)openUserPreferences:(id)arg
{
    
    ENSURE_UI_THREAD_0_ARGS;
    
    [[NotificarePushLib shared] openUserPreferences];
    
}


-(void)openInbox:(id)arg
{
    
    ENSURE_UI_THREAD_0_ARGS;
    
    [[NotificarePushLib shared] openInbox];
    
}

-(void)buyProduct:(id)arg
{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    ENSURE_SINGLE_ARG(arg, NSString);
    
    [[NotificarePushLib shared]  fetchProduct:arg completionHandler:^(NotificareProduct *product) {
        //
        [[NotificarePushLib shared] buyProduct:product];
        
    } errorHandler:^(NSError *error) {
        //
    }];
    
}

-(void)registerUserNotifications:(id)arg{
    ENSURE_UI_THREAD(registerUserNotifications, arg);
    [[NotificarePushLib shared] registerUserNotifications];
}


-(void)handleOpenUrl:(id)arg{
    ENSURE_UI_THREAD_1_ARG(arg);
    ENSURE_SINGLE_ARG(arg, NSString);
    
    NSURL * url = [NSURL URLWithString:arg];
    
    if ([[url scheme] isEqualToString:[NSString stringWithFormat:@"nc%@",[[[NotificarePushLib shared] applicationInfo] objectForKey:@"_id"]]]) {
        
        //Check for the reset password
        if ([url path] && [[url pathComponents] count] > 1 ) {
            
            if ([[[url pathComponents] objectAtIndex:1] isEqualToString:@"resetpassword"]) {

                NSMutableDictionary * trans = [NSMutableDictionary dictionary];
                [trans setValue:[[url pathComponents] objectAtIndex:2] forKey:@"token"];
                [self fireEvent:@"resetpassword" withObject:trans];
                
                
            }
            
            if ([[[url pathComponents] objectAtIndex:1] isEqualToString:@"validate"]) {
                
                
                [[NotificarePushLib shared] validateAccount:[[url pathComponents] objectAtIndex:2] completionHandler:^(NSDictionary *info) {
                    
                    NSMutableDictionary * trans = [NSMutableDictionary dictionary];
                    [trans setValue:[[url pathComponents] objectAtIndex:2] forKey:@"success"];
                    [self fireEvent:@"validate" withObject:trans];
                    
                } errorHandler:^(NSError *error) {
                    
                    NSMutableDictionary * trans = [NSMutableDictionary dictionary];
                    [trans setValue:[error description] forKey:@"error"];
                    [self fireEvent:@"validate" withObject:trans];
                    
                }];
            }
        }
    }
    
}


-(void)resetPassword:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    
    ENSURE_ARG_AT_INDEX(_out, arg, 1, KrollCallback);
    
    NSDictionary * params = (NSDictionary*)arg[0];
    KrollCallback *callback = (KrollCallback*)arg[1];
    
    [[NotificarePushLib shared] resetPassword:[params objectForKey:@"password"] withToken:[params objectForKey:@"token"] completionHandler:^(NSDictionary *info) {
        //
        NSMutableDictionary * trans = [NSMutableDictionary dictionary];
        NSMutableDictionary * act = [NSMutableDictionary dictionary];
        [act setValue:@"Password changed successfully" forKey:@"message"];
        [trans setValue:act forKey:@"success"];
        
        [callback call:@[trans] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        
        NSMutableDictionary * er = [NSMutableDictionary dictionary];
        NSMutableDictionary * obj = [NSMutableDictionary dictionary];
        [obj setObject:[NSString stringWithFormat:@"%li",(long)[error code]] forKey:@"code"];
        [obj setObject:[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:NSLocalizedDescriptionKey]] forKey:@"message"];
        
        [er setObject:obj forKey:@"error"];
        
        [callback call:@[er] thisObject:self];
        
    }];
    
}


-(void)sendPassword:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    
    ENSURE_ARG_AT_INDEX(_out, arg, 1, KrollCallback);
    
    NSDictionary * params = (NSDictionary*)arg[0];
    KrollCallback *callback = (KrollCallback*)arg[1];
    
    [[NotificarePushLib shared] sendPassword:[params objectForKey:@"email"] completionHandler:^(NSDictionary *info) {
        //
        NSMutableDictionary * trans = [NSMutableDictionary dictionary];
        NSMutableDictionary * act = [NSMutableDictionary dictionary];
        [act setValue:@"Reset password email sent successfully" forKey:@"message"];
        [trans setValue:act forKey:@"success"];
        
        [callback call:@[trans] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        
        NSMutableDictionary * er = [NSMutableDictionary dictionary];
        NSMutableDictionary * obj = [NSMutableDictionary dictionary];
        [obj setObject:[NSString stringWithFormat:@"%li",(long)[error code]] forKey:@"code"];
        [obj setObject:[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:NSLocalizedDescriptionKey]] forKey:@"message"];
        
        [er setObject:obj forKey:@"error"];
        
        [callback call:@[er] thisObject:self];
        
    }];
    
}

-(void)createAccount:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    
    ENSURE_ARG_AT_INDEX(_out, arg, 1, KrollCallback);
    
    NSDictionary * params = (NSDictionary*)arg[0];
    KrollCallback *callback = (KrollCallback*)arg[1];
    
    [[NotificarePushLib shared] createAccount:[params objectForKey:@"email"] withName:[params objectForKey:@"name"] andPassword:[params objectForKey:@"password"] completionHandler:^(NSDictionary *info) {
        //
        NSMutableDictionary * trans = [NSMutableDictionary dictionary];
        NSMutableDictionary * act = [NSMutableDictionary dictionary];
        [act setValue:@"Account created successfully" forKey:@"message"];
        [trans setValue:act forKey:@"success"];
        
        [callback call:@[trans] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        
        NSMutableDictionary * er = [NSMutableDictionary dictionary];
        NSMutableDictionary * obj = [NSMutableDictionary dictionary];
        [obj setObject:[NSString stringWithFormat:@"%li",(long)[error code]] forKey:@"code"];
        [obj setObject:[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:NSLocalizedDescriptionKey]] forKey:@"message"];
        
        [er setObject:obj forKey:@"error"];
        
        [callback call:@[er] thisObject:self];
        
    }];
    
}

-(void)login:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    
    ENSURE_ARG_AT_INDEX(_out, arg, 1, KrollCallback);
    
    NSDictionary * params = (NSDictionary*)arg[0];
    KrollCallback *callback = (KrollCallback*)arg[1];
    
    [[NotificarePushLib shared] loginWithUsername:[params objectForKey:@"username"] andPassword:[params objectForKey:@"password"] completionHandler:^(NSDictionary *info) {
        //
        NSMutableDictionary * trans = [NSMutableDictionary dictionary];
        NotificareNXOAuth2Account * account = [[NotificarePushLib shared] account];
        NSMutableDictionary * act = [NSMutableDictionary dictionary];
        [act setValue:[[account accessToken] tokenType] forKey:@"tokenType"];
        [act setValue:[[account accessToken] accessToken] forKey:@"accessToken"];
        [act setValue:[[account accessToken] refreshToken] forKey:@"refreshToken"];
        [act setValue:[NSString stringWithFormat:@"%@",[[account accessToken] expiresAt]] forKey:@"expiresAt"];
        [trans setValue:act forKey:@"account"];
        
        [callback call:@[trans] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        
        NSMutableDictionary * er = [NSMutableDictionary dictionary];
        NSMutableDictionary * obj = [NSMutableDictionary dictionary];
        [obj setObject:[NSString stringWithFormat:@"%li",(long)[error code]] forKey:@"code"];
        [obj setObject:[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:NSLocalizedDescriptionKey]] forKey:@"message"];
        
        [er setObject:obj forKey:@"error"];
        
        [callback call:@[er] thisObject:self];
        
    }];
    
}


-(void)logout:(id)arg{
    
    ENSURE_UI_THREAD_0_ARGS;
    
    [[NotificarePushLib shared] logoutAccount];
}


-(void)fetchAccount:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    
    ENSURE_ARG_AT_INDEX(_out, arg, 0, KrollCallback);
    
    KrollCallback *callback = (KrollCallback*)arg[0];
    NSMutableArray * prefs =[NSMutableArray array];
    
    
    [[NotificarePushLib shared] fetchAccountDetails:^(NSDictionary * result) {

        NSMutableDictionary * trans = [NSMutableDictionary dictionary];
        [trans setObject:[result objectForKey:@"user"] forKey:@"user"];
        
        [callback call:@[trans] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        
        NSMutableDictionary * er = [NSMutableDictionary dictionary];
        NSMutableDictionary * obj = [NSMutableDictionary dictionary];
        [obj setObject:[NSString stringWithFormat:@"%li",(long)[error code]] forKey:@"code"];
        [obj setObject:[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:NSLocalizedDescriptionKey]] forKey:@"message"];
        
        [er setObject:obj forKey:@"error"];
        
        [callback call:@[er] thisObject:self];
        
    }];

}



-(void)fetchUserPreferences:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    
    ENSURE_ARG_AT_INDEX(_out, arg, 0, KrollCallback);

    KrollCallback *callback = (KrollCallback*)arg[0];
    NSMutableArray * prefs =[NSMutableArray array];
    
    [[NotificarePushLib shared] fetchUserPreferences:^(NSArray *result) {
        //
        NSMutableDictionary * trans = [NSMutableDictionary dictionary];

        for (NotificareUserPreference * preference in result){
            
            NSMutableDictionary * pref = [NSMutableDictionary dictionary];
            
            [pref setObject:[preference preferenceId] forKey:@"preferenceId"];
            [pref setObject:[preference preferenceLabel] forKey:@"label"];
            [pref setObject:[preference preferenceType] forKey:@"type"];
            
            NSMutableArray * segments = [NSMutableArray array];
            
            for (NotificareSegment * seg in [preference preferenceOptions]) {
                NSMutableDictionary * s = [NSMutableDictionary dictionary];
                [s setObject:[seg segmentId] forKey:@"segmentId"];
                [s setObject:[seg segmentLabel] forKey:@"label"];
                [s setObject:[NSNumber numberWithBool:[seg selected]] forKey:@"selected"];
                [segments addObject:s];
            }

            [pref setObject:segments forKey:@"segments"];
            [prefs addObject:pref];
        }
        
        [trans setObject:prefs forKey:@"userPreferences"];
        
        [callback call:@[trans] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        
        NSMutableDictionary * er = [NSMutableDictionary dictionary];
        NSMutableDictionary * obj = [NSMutableDictionary dictionary];
        [obj setObject:[NSString stringWithFormat:@"%li",(long)[error code]] forKey:@"code"];
        [obj setObject:[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:NSLocalizedDescriptionKey]] forKey:@"message"];
        
        [er setObject:obj forKey:@"error"];
        
        [callback call:@[er] thisObject:self];
        
    }];
    
}



-(void)addSegmentToPreference:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    
    ENSURE_ARG_AT_INDEX(_out, arg, 2, KrollCallback);
    
    NSDictionary * segment = (NSDictionary*)arg[0];
    NSDictionary * preference = (NSDictionary*)arg[1];
    KrollCallback *callback = (KrollCallback*)arg[2];
    NSMutableArray * prefs =[NSMutableArray array];
    
    NotificareSegment * s = [NotificareSegment new];
    [s setSegmentId:[segment objectForKey:@"segmentId"]];
    
    NotificareUserPreference * p = [NotificareUserPreference new];
    [p setPreferenceId:[preference objectForKey:@"preferenceId"]];
    
    [[NotificarePushLib shared] addSegment:s toPreference:p completionHandler:^(NSDictionary * result) {
        
        NSMutableDictionary * trans = [NSMutableDictionary dictionary];
        NSMutableDictionary * act = [NSMutableDictionary dictionary];
        [act setValue:@"Segment added to preference successfully" forKey:@"message"];
        [trans setValue:act forKey:@"success"];
        
        [callback call:@[trans] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        
        NSMutableDictionary * er = [NSMutableDictionary dictionary];
        NSMutableDictionary * obj = [NSMutableDictionary dictionary];
        [obj setObject:[NSString stringWithFormat:@"%li",(long)[error code]] forKey:@"code"];
        [obj setObject:[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:NSLocalizedDescriptionKey]] forKey:@"message"];
        
        [er setObject:obj forKey:@"error"];
        
        [callback call:@[er] thisObject:self];
        
    }];
    
}


-(void)removeSegmentFromPreference:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    
    ENSURE_ARG_AT_INDEX(_out, arg, 2, KrollCallback);
    
    NSDictionary * segment = (NSDictionary*)arg[0];
    NSDictionary * preference = (NSDictionary*)arg[1];
    KrollCallback *callback = (KrollCallback*)arg[2];
    NSMutableArray * prefs =[NSMutableArray array];
    
    NotificareSegment * s = [NotificareSegment new];
    [s setSegmentId:[segment objectForKey:@"segmentId"]];
    
    NotificareUserPreference * p = [NotificareUserPreference new];
    [p setPreferenceId:[preference objectForKey:@"preferenceId"]];
    
    [[NotificarePushLib shared] removeSegment:s fromPreference:p completionHandler:^(NSDictionary * result) {
        
        NSMutableDictionary * trans = [NSMutableDictionary dictionary];
        NSMutableDictionary * act = [NSMutableDictionary dictionary];
        [act setValue:@"Segment removed from preference successfully" forKey:@"message"];
        [trans setValue:act forKey:@"success"];
        
        [callback call:@[trans] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        
        NSMutableDictionary * er = [NSMutableDictionary dictionary];
        NSMutableDictionary * obj = [NSMutableDictionary dictionary];
        [obj setObject:[NSString stringWithFormat:@"%li",(long)[error code]] forKey:@"code"];
        [obj setObject:[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:NSLocalizedDescriptionKey]] forKey:@"message"];
        
        [er setObject:obj forKey:@"error"];
        
        [callback call:@[er] thisObject:self];
        
    }];
    
}



-(void)generateToken:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    
    ENSURE_ARG_AT_INDEX(_out, arg, 0, KrollCallback);
    
    KrollCallback *callback = (KrollCallback*)arg[0];
    
    [[NotificarePushLib shared] generateAccessToken:^(NSDictionary * result) {
        //

        NSMutableDictionary * trans = [NSMutableDictionary dictionary];
        NSMutableDictionary * act = [NSMutableDictionary dictionary];
        [act setValue:@"Password changed successfully" forKey:@"message"];
        
        if([result objectForKey:@"user"] && [[result objectForKey:@"user"] objectForKey:@"accessToken"]){
            [act setObject:[[result objectForKey:@"user"] objectForKey:@"accessToken"] forKey:@"accessToken"];
        }
        [trans setValue:act forKey:@"success"];

        [callback call:@[trans] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        
        NSMutableDictionary * er = [NSMutableDictionary dictionary];
        NSMutableDictionary * obj = [NSMutableDictionary dictionary];
        [obj setObject:[NSString stringWithFormat:@"%li",(long)[error code]] forKey:@"code"];
        [obj setObject:[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:NSLocalizedDescriptionKey]] forKey:@"message"];
        
        [er setObject:obj forKey:@"error"];
        
        [callback call:@[er] thisObject:self];
        
    }];
    
}

-(void)changePassword:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    
    ENSURE_ARG_AT_INDEX(_out, arg, 1, KrollCallback);
    
    NSDictionary *params = (NSDictionary*)arg[0];
    KrollCallback *callback = (KrollCallback*)arg[1];
    NSMutableArray * prefs =[NSMutableArray array];
    
    [[NotificarePushLib shared] changePassword:[params objectForKey:@"password"] completionHandler:^(NSDictionary * result) {
        
        NSMutableDictionary * trans = [NSMutableDictionary dictionary];
        NSMutableDictionary * act = [NSMutableDictionary dictionary];
        [act setValue:@"Password changed successfully" forKey:@"message"];
        [trans setValue:act forKey:@"success"];
        
        [callback call:@[trans] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        
        NSMutableDictionary * er = [NSMutableDictionary dictionary];
        NSMutableDictionary * obj = [NSMutableDictionary dictionary];
        [obj setObject:[NSString stringWithFormat:@"%li",(long)[error code]] forKey:@"code"];
        [obj setObject:[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:NSLocalizedDescriptionKey]] forKey:@"message"];
        
        [er setObject:obj forKey:@"error"];
        
        [callback call:@[er] thisObject:self];
        
    }];
    
}


-(void)fetchInbox:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 0, KrollCallback);
    
    KrollCallback *callback = (KrollCallback*)arg[0];
    
    NSArray * trans = [[NotificarePushLib shared] myInbox];
    
    [callback call:@[trans] thisObject:self];
    
}

-(void)saveToInbox:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    ENSURE_SINGLE_ARG(arg, NSDictionary);
    
    [[NotificarePushLib shared] saveToInbox:arg forApplication:[UIApplication sharedApplication] completionHandler:^(NSDictionary *info) {
        //
    } errorHandler:^(NSError *error) {
        //
    }];
    
}

-(void)removeFromInbox:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    ENSURE_SINGLE_ARG(arg, NSDictionary);
    
    [[NotificarePushLib shared] removeFromInbox:arg];
    
}


-(void)isLoggedIn:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 0, KrollCallback);
    
    KrollCallback *callback = (KrollCallback*)arg[0];
    

    NSMutableDictionary * obj = [NSMutableDictionary dictionary];
    if([[NotificarePushLib shared] isLoggedIn]){
        [obj setObject:@"200" forKey:@"success"];
    } else {
        [obj setObject:@"403" forKey:@"error"];
    }
    
    [callback call:@[obj] thisObject:self];
    
}

-(void)handleAction:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);

    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 1, KrollCallback);
    NSDictionary *params = (NSDictionary*)arg[0];
    KrollCallback *callback = (KrollCallback*)arg[1];
    
    [[NotificarePushLib shared] handleAction:[params objectForKey:@"identifier"] forNotification:[params objectForKey:@"notification"] withData:nil completionHandler:^(NSDictionary *info) {
        //
        NSMutableDictionary * trans = [NSMutableDictionary dictionary];
        NSMutableDictionary * act = [NSMutableDictionary dictionary];
        [act setValue:@"Action handled successfully" forKey:@"message"];
        [trans setValue:act forKey:@"success"];
        
        [callback call:@[trans] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        //
        NSMutableDictionary * er = [NSMutableDictionary dictionary];
        NSMutableDictionary * obj = [NSMutableDictionary dictionary];
        [obj setObject:[NSString stringWithFormat:@"%li",(long)[error code]] forKey:@"code"];
        [obj setObject:[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:NSLocalizedDescriptionKey]] forKey:@"message"];
        
        [er setObject:obj forKey:@"error"];
        
        [callback call:@[er] thisObject:self];

    }];
    
}

-(void)fetchNotification:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 1, KrollCallback);
    NSDictionary *params = (NSDictionary*)arg[0];
    KrollCallback *callback = (KrollCallback*)arg[1];
    
    [[NotificarePushLib shared] getNotification:[params objectForKey:@"id"] completionHandler:^(NSDictionary *info) {
        //
        NSMutableDictionary * trans = [NSMutableDictionary dictionary];
        [trans setValue:[info objectForKey:@"notification"] forKey:@"notification"];
        
        [callback call:@[trans] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        //
        NSMutableDictionary * er = [NSMutableDictionary dictionary];
        NSMutableDictionary * obj = [NSMutableDictionary dictionary];
        [obj setObject:[NSString stringWithFormat:@"%li",(long)[error code]] forKey:@"code"];
        [obj setObject:[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:NSLocalizedDescriptionKey]] forKey:@"message"];
        
        [er setObject:obj forKey:@"error"];
        
        [callback call:@[er] thisObject:self];
        
    }];
    
}

-(void)clearNotification:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    ENSURE_SINGLE_ARG(arg, NSDictionary);
    
    [[NotificarePushLib shared] clearNotification:[arg objectForKey:@"id"]];
    
}


-(void)logCustomEvent:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 2, KrollCallback);
    NSString *params = (NSString*)arg[0];
    NSDictionary *data = (NSDictionary*)arg[1];
    KrollCallback *callback = (KrollCallback*)arg[2];
    
    [[NotificarePushLib shared] logCustomEvent:params withData:data completionHandler:^(NSDictionary *info) {

        NSMutableDictionary * trans = [NSMutableDictionary dictionary];
        NSMutableDictionary * act = [NSMutableDictionary dictionary];
        [act setValue:@"Custom log registered successfully" forKey:@"message"];
        [trans setValue:act forKey:@"success"];
        
        [callback call:@[trans] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        //
        NSMutableDictionary * er = [NSMutableDictionary dictionary];
        NSMutableDictionary * obj = [NSMutableDictionary dictionary];
        [obj setObject:[NSString stringWithFormat:@"%li",(long)[error code]] forKey:@"code"];
        [obj setObject:[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:NSLocalizedDescriptionKey]] forKey:@"message"];
        
        [er setObject:obj forKey:@"error"];
        
        [callback call:@[er] thisObject:self];
        
    }];
}



-(void)notificarePushLib:(NotificarePushLib *)library shouldPerformSelector:(NSString *)selector{
   
    NSMutableDictionary * trans = [NSMutableDictionary dictionary];
    [trans setValue:selector forKey:@"target"];
    [self fireEvent:@"action" withObject:trans];
    
}


@end