//
//  logHandler.h
//  MainUI
//
//  Created by Henry on 2021/1/28.
//  Copyright © 2021 Henry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "logTypeController.h"
#import "SequenceGroup.h"
#import "TimeTamp.h"
#import "../LuaAPI/LuaScriptCore.h"
#import "../winDelegateLaunch.h"

NS_ASSUME_NONNULL_BEGIN

@interface logHandler : NSObject{
    NSFileManager *fileManager;
    int msPrecisionLength;
    NSMutableArray *data;
    
@public
    NSString *filePath;
    NSString *fileName;
    NSString *fileContent;
    NSString *logType;
    NSString *timeTampType;
    NSString *lua_TimeTampType;
    NSMutableArray *arrSubString;
    BOOL allowSkip;
}

- (void)analyzeSequenceLog:(NSArray *)pivotData withMatchStr:(NSString *)match_str;
- (NSMutableArray *)data;
- (instancetype)initWithFilePath:(NSString *)path andTypeController:(logTypeController *)typeController;
- (NSString *)getSubString:(NSArray *)arr;
- (void)initCommonLogSubString:(NSArray *)arr withLuaTimeTampType:(NSString *)time_regex;
- (void)initSpecialLogSubString:(NSArray *)arr fromStartStr:(NSString *)start_str toEndStr:(NSString *)end_str ignoreOption:(NSArray *)optArr;
- (void)initSpecialLogSubString:(NSArray *)arr withMatchStr:(NSString *)match_str ignoreOption:(NSArray *)optArr;

@property(nonatomic, strong) LSCContext *context;

@end

NS_ASSUME_NONNULL_END
