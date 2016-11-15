/**
 * notificare-titanium-ios
 *
 * Created by Joel Oliveira
 * Copyright (c) 2015 Notificare. All rights reserved.
 */

#import "TiNotificareModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"
#import "NSData+Hex.h"
#import "NotificareAsset.h"
#import "NotificarePass.h"

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


#pragma mark Mandatory Delegate
- (void)notificarePushLib:(NotificarePushLib *)library onReady:(NSDictionary *)info{
    
    [self fireEvent:@"ready" withObject:info];
    
}

#pragma mark Inbox Delegates
- (void)notificarePushLib:(NotificarePushLib *)library didUpdateBadge:(int)badge{
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    [result setValue:[NSString stringWithFormat:@"%li",(long)badge] forKey:@"badge"];
    [self fireEvent:@"badge" withObject:result];
}


#pragma mark Notification Delegates
-(void)notificarePushLib:(NotificarePushLib *)library willOpenNotification:(nonnull NotificareNotification *)notification{
    
    NSMutableDictionary * message = [NSMutableDictionary dictionary];
    [message setObject:[self dictionaryFromNotification:notification] forKey:@"notification"];
    
    [self fireEvent:@"willOpenNotification" withObject:message];
    
}

-(void)notificarePushLib:(NotificarePushLib *)library didOpenNotification:(nonnull NotificareNotification *)notification{
    
    NSMutableDictionary * message = [NSMutableDictionary dictionary];
    [message setObject:[self dictionaryFromNotification:notification] forKey:@"notification"];
    
    [self fireEvent:@"didOpenNotification" withObject:message];
    
}

-(void)notificarePushLib:(NotificarePushLib *)library didFailToOpenNotification:(nonnull NotificareNotification *)notification{

    NSMutableDictionary * message = [NSMutableDictionary dictionary];
    [message setObject:[self dictionaryFromNotification:notification] forKey:@"notification"];
    
    [self fireEvent:@"didFailToOpenNotification" withObject:message];
    
}

-(void)notificarePushLib:(NotificarePushLib *)library didCloseNotification:(nonnull NotificareNotification *)notification {
    
    NSMutableDictionary * message = [NSMutableDictionary dictionary];
    [message setObject:[self dictionaryFromNotification:notification] forKey:@"notification"];
    
    [self fireEvent:@"didCloseNotification" withObject:message];
}

#pragma mark Action Delegates
-(void)notificarePushLib:(NotificarePushLib *)library willExecuteAction:(nonnull NotificareNotification *)notification{

    NSMutableDictionary * message = [NSMutableDictionary dictionary];
    [message setObject:[self dictionaryFromNotification:notification] forKey:@"notification"];
    
    [self fireEvent:@"willExecuteAction" withObject:message];
    
}

-(void)notificarePushLib:(NotificarePushLib *)library didExecuteAction:(nonnull NSDictionary *)info{

    [self fireEvent:@"didExecuteAction" withObject:info];
    
}


-(void)notificarePushLib:(NotificarePushLib *)library didNotExecuteAction:(nonnull NSDictionary *)info{
 
    [self fireEvent:@"didNotExecuteAction" withObject:info];
}


-(void)notificarePushLib:(NotificarePushLib *)library didFailToExecuteAction:(nonnull NSError *)error{

    NSMutableDictionary * er = [NSMutableDictionary dictionary];
    NSMutableDictionary * obj = [NSMutableDictionary dictionary];
    [obj setObject:[NSString stringWithFormat:@"%li",(long)[error code]] forKey:@"code"];
    [obj setObject:[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:NSLocalizedDescriptionKey]] forKey:@"message"];
    
    [er setObject:obj forKey:@"error"];
    
    [self fireEvent:@"didFailToExecuteAction" withObject:er];
}

-(void)notificarePushLib:(NotificarePushLib *)library shouldPerformSelectorWithURL:(NSURL *)url{
    
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[url absoluteString] forKey:@"url"];
    [self fireEvent:@"shouldPerformSelectorWithURL" withObject:payload];
    
}

-(void)notificarePushLib:(NotificarePushLib *)library didClickURL:(nonnull NSURL *)url inNotification:(nonnull NotificareNotification *)notification{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryFromNotification:notification]];
    [payload setObject:[url absoluteString] forKey:@"url"];
    
    [self fireEvent:@"didClickURL" withObject:payload];
    
}

#pragma mark Users & Auth Delegates

- (void)notificarePushLib:(NotificarePushLib *)library didChangeAccountNotification:(NSDictionary *)info{

    NSMutableDictionary * trans = [NSMutableDictionary dictionary];
    NotificareNXOAuth2Account * account = [[NotificarePushLib shared] account];
    NSMutableDictionary * act = [NSMutableDictionary dictionary];
    [act setValue:[[account accessToken] tokenType] forKey:@"tokenType"];
    [act setValue:[[account accessToken] accessToken] forKey:@"accessToken"];
    [act setValue:[[account accessToken] refreshToken] forKey:@"refreshToken"];
    [act setValue:[account userData] forKey:@"user"];
    [act setValue:[NSString stringWithFormat:@"%@",[[account accessToken] expiresAt]] forKey:@"expiresAt"];
    [trans setValue:act forKey:@"account"];
    [self fireEvent:@"didChangeAccountNotification" withObject:trans];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToRequestAccessNotification:(NSError *)error{

    [self fireEvent:@"didFailToRequestAccessNotification" withObject:[self dictionaryFromError:error]];
}


- (void)notificarePushLib:(NotificarePushLib *)library didReceiveActivationToken:(NSString *)token{
    
    [[NotificarePushLib shared] validateAccount:token completionHandler:^(NSDictionary *info) {
        
         [self fireEvent:@"didValidateAccount" withObject:info];
        
    } errorHandler:^(NSError *error) {
        
        [self fireEvent:@"didFailToValidateAccount" withObject:[self dictionaryFromError:error]];
        
    }];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didReceiveResetPasswordToken:(NSString *)token{
    
    [self fireEvent:@"didReceiveResetPasswordToken" withObject:@{@"token": token}];
}


#pragma Notificare Location delegates
- (void)notificarePushLib:(NotificarePushLib *)library didReceiveLocationServiceAuthorizationStatus:(NSDictionary *)status{
    
    [self fireEvent:@"didReceiveLocationServiceAuthorizationStatus" withObject:status];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailToStartLocationServiceWithError:(NSError *)error{
    
    [self fireEvent:@"didFailToStartLocationServiceWithError" withObject:@{@"error" : [error localizedDescription]}];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didUpdateLocations:(NSArray *)locations{
    
    CLLocation * lastLocation = (CLLocation *)[locations lastObject];
    NSMutableDictionary * location = [NSMutableDictionary dictionary];
    [location setValue:[NSNumber numberWithFloat:[lastLocation coordinate].latitude] forKey:@"latitude"];
    [location setValue:[NSNumber numberWithFloat:[lastLocation coordinate].longitude] forKey:@"longitude"];
    [self fireEvent:@"didUpdateLocations" withObject:location];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[region identifier] forKey:@"region"];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    
    [self fireEvent:@"monitoringDidFailForRegion" withObject:payload];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[region identifier] forKey:@"region"];
    [payload setObject:[NSNumber numberWithInt:state] forKey:@"state"];
    
    [self fireEvent:@"didDetermineState" withObject:payload];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didEnterRegion:(CLRegion *)region{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[region identifier] forKey:@"region"];;
    
    [self fireEvent:@"didEnterRegion" withObject:payload];
    
}



- (void)notificarePushLib:(NotificarePushLib *)library didExitRegion:(CLRegion *)region{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[region identifier] forKey:@"region"];;
    
    [self fireEvent:@"didExitRegion" withObject:payload];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didStartMonitoringForRegion:(CLRegion *)region{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[region identifier] forKey:@"region"];;
    
    [self fireEvent:@"didStartMonitoringForRegion" withObject:payload];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[region identifier] forKey:@"region"];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    
    [self fireEvent:@"rangingBeaconsDidFailForRegion" withObject:payload];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    NSMutableArray * theBeacons = [NSMutableArray array];
    
    [payload setObject:[region identifier] forKey:@"region"];
    
    for (NotificareBeacon * beacon in beacons) {
        NSMutableDictionary * b = [NSMutableDictionary dictionary];
        [b setObject:[[beacon beaconUUID] UUIDString] forKey:@"uuid"];
        [b setObject:[beacon major] forKey:@"major"];
        [b setObject:[beacon minor] forKey:@"minor"];
        [b setObject:[beacon notification] forKey:@"notification"];
        [b setObject:[NSNumber numberWithInt:[[beacon beacon] proximity]] forKey:@"proximity"];
        [theBeacons addObject:b];
    }
    
    [payload setObject:theBeacons forKey:@"beacons"];
    
    [self fireEvent:@"didRangeBeacons" withObject:payload];
    
}


#pragma Notificare In-App Purchases

- (void)notificarePushLib:(NotificarePushLib *)library didLoadStore:(NSArray *)products{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    NSMutableArray * prods = [NSMutableArray new];
    
    for (NotificareProduct * product in products) {
        [prods addObject:[self dictionaryFromProduct:product]];
    }
    
    [payload setObject:prods forKey:@"products"];
    
    [self fireEvent:@"didLoadStore" withObject:payload];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didFailToLoadStore:(NSError *)error{
    
    [self fireEvent:@"didFailToLoadStore" withObject:@{@"products": @[]}];
    
}

- (void)notificarePushLib:(NotificarePushLib *)library didFailProductTransaction:(SKPaymentTransaction *)transaction withError:(NSError *)error{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[transaction transactionIdentifier] forKey:@"transaction"];
    [payload setObject:[error localizedDescription] forKey:@"error"];
    
    [self fireEvent:@"didFailProductTransaction" withObject:payload];
}


- (void)notificarePushLib:(NotificarePushLib *)library didCompleteProductTransaction:(SKPaymentTransaction *)transaction{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[transaction transactionIdentifier] forKey:@"transaction"];
    
    [self fireEvent:@"didCompleteProductTransaction" withObject:payload];
}


- (void)notificarePushLib:(NotificarePushLib *)library didRestoreProductTransaction:(SKPaymentTransaction *)transaction{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[transaction transactionIdentifier] forKey:@"transaction"];
    
    [self fireEvent:@"didRestoreProductTransaction" withObject:payload];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didStartDownloadContent:(SKPaymentTransaction *)transaction{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    [payload setObject:[transaction transactionIdentifier] forKey:@"transaction"];
    
    [self fireEvent:@"didStartDownloadContent" withObject:payload];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didPauseDownloadContent:(SKDownload *)download{
    
    [self fireEvent:@"didPauseDownloadContent" withObject:[self dictionaryFromSKDownload:download]];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didCancelDownloadContent:(SKDownload *)download{
    
    [self fireEvent:@"didCancelDownloadContent" withObject:[self dictionaryFromSKDownload:download]];
    
}


- (void)notificarePushLib:(NotificarePushLib *)library didReceiveProgressDownloadContent:(SKDownload *)download{
    
    [self fireEvent:@"didReceiveProgressDownloadContent" withObject:[self dictionaryFromSKDownload:download]];
}


- (void)notificarePushLib:(NotificarePushLib *)library didFailDownloadContent:(SKDownload *)download{
    
    [self fireEvent:@"didFailDownloadContent" withObject:[self dictionaryFromSKDownload:download]];
}


- (void)notificarePushLib:(NotificarePushLib *)library didFinishDownloadContent:(SKDownload *)download{
    
    [self fireEvent:@"didFinishDownloadContent" withObject:[self dictionaryFromSKDownload:download]];
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
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    
    ENSURE_ARG_AT_INDEX(_out, arg, 1, KrollCallback);
    
    NSString * device = (NSString*)arg[0];
    KrollCallback *callback = (KrollCallback*)arg[1];
    
    // The token received in the success callback to 'Ti.Network.registerForPushNotifications' is a hex-encode
    // string. We need to convert it back to it's byte format as an NSData object.
    
    NSMutableData *token = [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = { '\0', '\0', '\0' };
    int i;
    for (i=0; i<[device length]/2; i++) {
        byte_chars[0] = [device characterAtIndex:i*2];
        byte_chars[1] = [device characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [token appendBytes:&whole_byte length:1];
    }
    

    if(userId && username){
        
        [[NotificarePushLib shared] registerDevice:token withUserID:userId withUsername:username completionHandler:^(NSDictionary *info) {
            //
            [callback call:@[info] thisObject:self];

            
        } errorHandler:^(NSError *error) {
            
            [callback call:@[[self dictionaryFromError:error]] thisObject:self];
            
        }];

    } else if(userId && !username){
        [[NotificarePushLib shared] registerDevice:token withUserID:userId completionHandler:^(NSDictionary *info) {
            //
            [callback call:@[info] thisObject:self];

        } errorHandler:^(NSError *error) {
            
            [callback call:@[[self dictionaryFromError:error]] thisObject:self];
            
        }];
    } else {
        [[NotificarePushLib shared] registerDevice:token completionHandler:^(NSDictionary *info) {
            //
            [callback call:@[info] thisObject:self];

        } errorHandler:^(NSError *error) {
            
            [callback call:@[[self dictionaryFromError:error]] thisObject:self];
            
        }];
    }
 
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



-(void)fetchTags:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 0, KrollCallback);
    KrollCallback *callback = (KrollCallback*)arg[0];
    
    [[NotificarePushLib shared] getTags:^(NSDictionary *info) {
        NSMutableArray * t = [NSMutableArray array];
        for (NSString * tag in [info objectForKey:@"tags"]) {
            [t addObject:tag];
        }
        
        NSMutableDictionary * tags = [NSMutableDictionary dictionary];
        [tags setValue:t forKey:@"tags"];
        
        [callback call:@[tags] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
    }];
}


-(void)addTags:(id)arg
{

    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 1, KrollCallback);
    NSArray * tags = (NSArray*)arg[0];
    KrollCallback *callback = (KrollCallback*)arg[1];
    
    ENSURE_UI_THREAD_1_ARG(arg);
    ENSURE_SINGLE_ARG(arg, NSArray);
    
    [[NotificarePushLib shared] addTags:tags completionHandler:^(NSDictionary *info) {
        //
        [callback call:@[info] thisObject:self];
    } errorHandler:^(NSError *error) {
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
    }];
    
}

-(void)removeTag:(id)arg
{
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 1, KrollCallback);
    NSString * tag = (NSString*)arg[0];
    KrollCallback *callback = (KrollCallback*)arg[1];

    [[NotificarePushLib shared] removeTag:tag completionHandler:^(NSDictionary *info) {
        [callback call:@[info] thisObject:self];
    } errorHandler:^(NSError *error) {
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
    }];
    
}

-(void)clearTags:(id)arg
{
    ENSURE_UI_THREAD_1_ARG(arg);
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 0, KrollCallback);
    KrollCallback *callback = (KrollCallback*)arg[0];
    
    [[NotificarePushLib shared] clearTags:^(NSDictionary *info) {
        [callback call:@[info] thisObject:self];
    } errorHandler:^(NSError *error) {
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
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
    
    [[NotificarePushLib shared] handleOpenURL:url];
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
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
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
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
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
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
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
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
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
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
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
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
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
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
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
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
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
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
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
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
    }];
    
}


-(void)fetchInbox:(id)arg{
    
    ENSURE_UI_THREAD(fetchInbox, arg);
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 3, KrollCallback);
    NSString * dateString = (NSString*)arg[0];
    NSNumber * skip = (NSNumber*)arg[1];
    NSNumber * limit = (NSNumber*)arg[2];
    KrollCallback *callback = (KrollCallback*)arg[3];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss Z"];
    NSDate *sinceDate = [dateFormatter dateFromString:dateString];

    
    NSMutableDictionary * trans = [NSMutableDictionary dictionary];
    
    [[NotificarePushLib shared] fetchInbox:sinceDate skip:skip limit:limit completionHandler:^(NSDictionary *info) {
        
        NSMutableArray * inbox = [NSMutableArray array];
        
        for (NotificareDeviceInbox * inb in [info objectForKey:@"inbox"]) {
            NSMutableDictionary * i = [NSMutableDictionary dictionary];
            
            [i setObject:[inb inboxId] forKey:@"id"];
            [i setObject:[inb applicationId] forKey:@"application"];
            [i setObject:[inb deviceID] forKey:@"deviceID"];
            [i setObject:[inb notification] forKey:@"notification"];
            [i setObject:[inb time] forKey:@"time"];
            [i setObject:[inb message] forKey:@"message"];
            [i setObject:[NSNumber numberWithBool:[inb opened]] forKey:@"opened"];
            
            if([inb userID]){
                [i setObject:[inb userID] forKey:@"userID"];
            }
            
            if([inb data]){
                [i setObject:[inb data] forKey:@"data"];
            }
            
            [inbox addObject:i];
        }
     
        [trans setObject:inbox forKey:@"inbox"];
        
        [callback call:@[trans] thisObject:self];
     
    } errorHandler:^(NSError *error) {
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
    }];
    
    
}

-(void)markAsRead:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 1, KrollCallback);
    NSDictionary * inbox = (NSDictionary*)arg[0];
    KrollCallback *callback = (KrollCallback*)arg[1];
    
    NotificareDeviceInbox * item = [NotificareDeviceInbox new];
    [item setInboxId:[inbox objectForKey:@"id"]];
    [item setNotification:[inbox objectForKey:@"notification"]];
    
    [[NotificarePushLib shared] markAsRead:item completionHandler:^(NSDictionary *info) {
        
        [callback call:@[info] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
    }];
    
}

-(void)removeFromInbox:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 1, KrollCallback);
    NSDictionary * inbox = (NSDictionary*)arg[0];
    KrollCallback *callback = (KrollCallback*)arg[1];
    
    NotificareDeviceInbox * item = [NotificareDeviceInbox new];
    [item setInboxId:[inbox objectForKey:@"id"]];
    
    [[NotificarePushLib shared] removeFromInbox:item completionHandler:^(NSDictionary *info) {
        
        [callback call:@[info] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
    }];
    
}

-(void)clearInbox:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 0, KrollCallback);
    KrollCallback *callback = (KrollCallback*)arg[0];

    [[NotificarePushLib shared] clearInbox:^(NSDictionary *info) {
        [callback call:@[info] thisObject:self];
    } errorHandler:^(NSError *error) {
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
    }];
    
}

-(void)openInboxItem:(id)arg{
    
    ENSURE_UI_THREAD_1_ARG(arg);
    ENSURE_SINGLE_ARG(arg, NSDictionary);
    
    NotificareDeviceInbox * item = [NotificareDeviceInbox new];
    [item setInboxId:[arg objectForKey:@"id"]];
    [item setMessage:[arg objectForKey:@"message"]];
    
    [[NotificarePushLib shared] openInboxItem:item];
    
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
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
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
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
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
        
        [callback call:@[info] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
    }];
}



-(void)fetchAssets:(id)arg{
    
    ENSURE_UI_THREAD(fetchAssets, arg);
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 1, KrollCallback);
    NSString * group = (NSString*)arg[0];
    KrollCallback *callback = (KrollCallback*)arg[1];
    
    
    NSMutableDictionary * trans = [NSMutableDictionary dictionary];
    
    [[NotificarePushLib shared] fetchAssets:group completionHandler:^(NSArray *files) {
        
        NSMutableArray * assets = [NSMutableArray array];
        
        for (NotificareAsset * f in files) {
            
            NSMutableDictionary * file = [NSMutableDictionary dictionary];
            [file setValue:[f assetTitle] forKey:@"title"];
            [file setValue:[f assetDescription] forKey:@"description"];
            [file setValue:[f assetUrl] forKey:@"url"];
            [file setObject:[f assetMetaData] forKey:@"metaData"];
            [file setObject:[f assetButton] forKey:@"button"];
            [assets addObject:file];
            
        }
        
        [trans setObject:assets forKey:@"assets"];
        
        [callback call:@[trans] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
    }];
    
    
}


-(void)fetchPass:(id)arg{
    
    ENSURE_UI_THREAD(fetchPass, arg);
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 1, KrollCallback);
    NSString * serial = (NSString*)arg[0];
    KrollCallback *callback = (KrollCallback*)arg[1];
    
    [[NotificarePushLib shared] fetchPass:serial completionHandler:^(NotificarePass *pass) {
        NSMutableDictionary * passObject = [NSMutableDictionary dictionary];
        NSMutableDictionary * p = [NSMutableDictionary dictionary];
        [p setValue:[pass passbook] forKey:@"passbook"];
        [p setValue:[pass serial] forKey:@"serial"];
        [p setObject:[pass data] forKey:@"data"];
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [dateFormatter stringFromDate:[pass date]];
        
        [p setObject:dateString forKey:@"date"];
        [p setObject:[pass limit] forKey:@"limit"];
        [p setObject:[pass redeemHistory] forKey:@"redeemHistory"];
        [p setObject:[pass redeem] forKey:@"redeem"];
        [p setObject:[NSNumber numberWithInt:[pass active]] forKey:@"active"];
        
        if([pass token]){
            [p setObject:[pass token] forKey:@"token"];
        }
        
        [passObject setObject:p forKey:@"pass"];
        
        [callback call:@[passObject] thisObject:self];
        
    } errorHandler:^(NSError *error) {
        
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
        
    }];
    
    
}


-(void)fetchDoNotDisturb:(id)arg{
    
    ENSURE_UI_THREAD(fetchDoNotDisturb, arg);
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 0, KrollCallback);
    KrollCallback *callback = (KrollCallback*)arg[0];
    
    [[NotificarePushLib shared] fetchDoNotDisturb:^(NSDictionary * _Nonnull info) {
        [callback call:@[info] thisObject:self];
    } errorHandler:^(NSError * _Nonnull error) {
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
    }];
    
}


-(void)updateDoNotDisturb:(id)arg{
    
    ENSURE_UI_THREAD(updateDoNotDisturb, arg);
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 2, KrollCallback);
    NSDate *start = (NSDate*)arg[0];
    NSDate *end = (NSDate*)arg[1];
    KrollCallback *callback = (KrollCallback*)arg[2];
    
    [[NotificarePushLib shared] updateDoNotDisturb:start endTime:end completionHandler:^(NSDictionary * _Nonnull info) {
        [callback call:@[info] thisObject:self];
    } errorHandler:^(NSError * _Nonnull error) {
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
    }];
    
}


-(void)clearDoNotDisturb:(id)arg{
    
    ENSURE_UI_THREAD(clearDoNotDisturb, arg);
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 0, KrollCallback);
    KrollCallback *callback = (KrollCallback*)arg[0];
    
    [[NotificarePushLib shared] clearDoNotDisturb:^(NSDictionary * _Nonnull info) {
        [callback call:@[info] thisObject:self];
    } errorHandler:^(NSError * _Nonnull error) {
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
    }];
    
}


-(void)fetchUserData:(id)arg{
    
    ENSURE_UI_THREAD(fetchUserData, arg);
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 0, KrollCallback);
    KrollCallback *callback = (KrollCallback*)arg[0];
    
    [[NotificarePushLib shared] fetchUserData:^(NSDictionary * _Nonnull info) {
        [callback call:@[info] thisObject:self];
    } errorHandler:^(NSError * _Nonnull error) {
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
    }];
    
}

-(void)updateUserData:(id)arg{
    
    ENSURE_UI_THREAD(updateUserData, arg);
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 1, KrollCallback);
    NSDictionary *data = (NSDictionary*)arg[0];
    KrollCallback *callback = (KrollCallback*)arg[1];
    
    [[NotificarePushLib shared] updateUserData:data completionHandler:^(NSDictionary * _Nonnull info) {
        [callback call:@[info] thisObject:self];
    } errorHandler:^(NSError * _Nonnull error) {
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
    }];
    
}

-(void)doCloudHostOperation:(id)arg{
    
    ENSURE_UI_THREAD(doCloudHostOperation, arg);
    
    ENSURE_UI_THREAD_1_ARG(arg);
    
    id _out = nil;
    ENSURE_ARG_AT_INDEX(_out, arg, 4, KrollCallback);
    NSString *http = (NSString*)arg[0];
    NSString *path = (NSString*)arg[1];
    NSDictionary *params = (NSDictionary*)arg[2];
    NSDictionary *body = (NSDictionary*)arg[3];
    KrollCallback *callback = (KrollCallback*)arg[4];
    
    [[NotificarePushLib shared] doCloudHostOperation:http path:path URLParams:params bodyJSON:body successHandler:^(NSDictionary * _Nonnull info) {
         [callback call:@[info] thisObject:self];
    } errorHandler:^(NotificareNetworkOperation * _Nonnull operation, NSError * _Nonnull error) {
        [callback call:@[[self dictionaryFromError:error]] thisObject:self];
    }];
    
}



/**
 * Helper method to convert NotificareNotification to a dictionary
 **/
-(NSDictionary *)dictionaryFromNotification:(NotificareNotification *)notification{
    NSMutableDictionary * message = [NSMutableDictionary dictionary];
    NSMutableDictionary * trans = [NSMutableDictionary dictionary];
    [trans setValue:[notification notificationID] forKey:@"id"];
    [trans setValue:[notification notificationType] forKey:@"type"];
    [trans setValue:[notification notificationTime] forKey:@"time"];
    [trans setValue:[notification notificationMessage] forKey:@"message"];
    
    if([notification notificationExtra]){
        [trans setObject:[notification notificationExtra] forKey:@"extra"];
    }
    
    [trans setObject:[notification notificationInfo] forKey:@"info"];
    [trans setObject:[notification notificationTags] forKey:@"tags"];
    [trans setObject:[notification notificationSegments] forKey:@"segments"];
    
    if([notification notificationLatitude] && [notification notificationLongitude] && [notification notificationDistance]){
        
        NSMutableDictionary * location = [NSMutableDictionary dictionary];
        [location setValue:[notification notificationLatitude] forKey:@"latitude"];
        [location setValue:[notification notificationLongitude] forKey:@"longitude"];
        [location setValue:[notification notificationDistance] forKey:@"distance"];
        [trans setObject:location forKey:@"location"];
        
    }
    
    NSMutableArray * content = [NSMutableArray array];
    for (NotificareContent * c in [notification notificationContent]) {
        NSMutableDictionary * cont = [NSMutableDictionary dictionary];
        [cont setObject:[c type] forKey:@"type"];
        [cont setObject:[c data] forKey:@"data"];
        [content addObject:cont];
    }
    [trans setObject:content forKey:@"content"];
    
    NSMutableArray * actions = [NSMutableArray array];
    for (NotificareAction * a in [notification notificationActions]) {
        NSMutableDictionary * act = [NSMutableDictionary dictionary];
        [act setValue:[a actionLabel] forKey:@"label"];
        [act setValue:[a actionType] forKey:@"type"];
        [act setValue:[a actionTarget] forKey:@"type"];
        [act setObject:[NSNumber numberWithBool:[a actionCamera]] forKey:@"camera"];
        [act setObject:[NSNumber numberWithBool:[a actionKeyboard]] forKey:@"keyboard"];
        [actions addObject:act];
    }
    [trans setObject:actions forKey:@"actions"];
    
    
    [message setObject:trans forKey:@"notification"];
    
    return message;
}

/**
 * Helper method to convert SKDownload to NSDictionary
 */
-(NSDictionary *)dictionaryFromSKDownload:(SKDownload *)download{
    
    NSMutableDictionary * payload = [NSMutableDictionary dictionary];
    NSMutableDictionary * theDownload = [NSMutableDictionary dictionary];
    [theDownload setObject:[download contentIdentifier] forKey:@"contentIdentifier"];
    [theDownload setObject:[download contentURL] forKey:@"contentURL"];
    [theDownload setObject:[NSNumber numberWithLong:[download contentLength]] forKey:@"contentLength"];
    [theDownload setObject:[download contentVersion] forKey:@"contentVersion"];
    [theDownload setObject:[NSNumber numberWithInt:[download downloadState]] forKey:@"downloadState"];
    [theDownload setObject:[NSNumber numberWithFloat:[download progress]] forKey:@"progress"];
    [theDownload setObject:[NSNumber numberWithDouble:[download timeRemaining]] forKey:@"timeRemaining"];
    [payload setObject:theDownload forKey:@"download"];
    
    return payload;
}


/**
 * Helper method to convert NotificareProduct to NSDictionary
 */
-(NSDictionary *)dictionaryFromProduct:(NotificareProduct *)product{
    
    NSMutableDictionary * payload = [NSMutableDictionary new];
    [payload setObject:[product identifier] forKey:@"identifier"];
    [payload setObject:[product productName] forKey:@"productName"];
    [payload setObject:[product productDescription] forKey:@"productDescription"];
    [payload setObject:[product price] forKey:@"price"];
    [payload setObject:[product priceLocale] forKey:@"priceLocale"];
    [payload setObject:[product stores] forKey:@"stores"];
    
    NSMutableArray * downloads = [NSMutableArray array];
    for (SKDownload * d in [product downloads]) {
        [downloads addObject:[self dictionaryFromSKDownload:d]];
    }
    [payload setObject:downloads forKey:@"downloads"];
    
    
    return payload;
}

-(NSDictionary*)dictionaryFromError:(NSError*)error{
    NSMutableDictionary * er = [NSMutableDictionary dictionary];
    NSMutableDictionary * obj = [NSMutableDictionary dictionary];
    [obj setObject:[NSString stringWithFormat:@"%li",(long)[error code]] forKey:@"code"];
    [obj setObject:[NSString stringWithFormat:@"%@",[[error userInfo] objectForKey:NSLocalizedDescriptionKey]] forKey:@"message"];
    
    [er setObject:obj forKey:@"error"];
    
    return er;
}



@end
