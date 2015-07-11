/**
 * notificare-titanium-ios
 *
 * Created by Your Name
 * Copyright (c) 2015 Your Company. All rights reserved.
 */

#import "TiModule.h"
#import "NotificarePushLib.h"

@interface TiNotificareModule : TiModule <NotificarePushLibDelegate> {
    NSString * userId;
    NSString * username;
}

@end
