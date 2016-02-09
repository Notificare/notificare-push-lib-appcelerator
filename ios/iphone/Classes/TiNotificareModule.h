/**
 * notificare-titanium-ios
 *
 * Created by Joel Oliveira
 * Copyright (c) 2015 Notificare. All rights reserved.
 */

#import "TiModule.h"
#import "NotificarePushLib.h"

@interface TiNotificareModule : TiModule <NotificarePushLibDelegate> {
    NSString * userId;
    NSString * username;
}

@end
