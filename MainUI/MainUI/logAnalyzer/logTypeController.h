//
//  logTypeController.h
//  MainUI
//
//  Created by Henry on 2021/1/28.
//  Copyright © 2021 Henry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"

NS_ASSUME_NONNULL_BEGIN

@interface logTypeController : NSObject{
    NSArray *logTypeList;
    NSArray *timeTampTypeList;
    NSArray *lua_TimeTampTypeList;
}

- (BOOL)isValidLogType:(NSString *)fileName;
- (BOOL)isValidTimeTampType:(NSString *)content withLogType:(NSString *)logType;
- (NSString *)getLogType:(NSString *)fileName;
- (NSString *)getTimeTampType:(NSString *)content withLogType:(NSString *)logType;
- (BOOL)isDetailViewLog:(NSString *)fileName;
- (BOOL)isSelectViewLog:(NSString *)fileName;
- (NSString *)getMatchStr:(NSString *)logType withTimeTampType:(NSString *)type;
- (NSArray *)getIgnoreOption:(NSString *)logType;
- (NSString *)getLuaTimeTampType:(NSString *)oc_timptamp;

@end



NS_ASSUME_NONNULL_END
