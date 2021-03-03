//
//  winDelegateLaunch.h
//  MainUI
//
//  Created by Henry on 2021/3/3.
//  Copyright © 2021 Henry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

#define kNotificationStartupLog         @"Startup_log"
#define kStartupMsg                     @"msg"
#define kStartupLevel                   @"level"

typedef enum {
    MSG_LEVEL_NORMAL,
    MSG_LEVEL_WARNNING,
    MSG_LEVEL_ERROR,
}MSG_LEVEL;

@interface winDelegateLaunch : NSObject
{
    IBOutlet NSTextView *launchTextView;
//    dispatch_queue_t serialQueue;
}

-(void)ClearLog;

@end

NS_ASSUME_NONNULL_END
