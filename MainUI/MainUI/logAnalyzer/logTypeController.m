//
//  logTypeController.m
//  MainUI
//
//  Created by Henry on 2021/1/28.
//  Copyright © 2021 Henry. All rights reserved.
//

#import "logTypeController.h"

//log file type
#define pivot           @"pivot.csv"
#define FAIL_Summary    @"FAIL_Summary.csv"
#define EngineLog       @"EngineLog.log"
#define smcLog          @"smcLog.log"
#define engine          @"engine.log"
#define flow_plain      @"flow_plain.log"
#define hw              @"hw.log"
#define iefi            @"iefi.log"
#define sequencer       @"sequencer.log"
#define uart            @"uart.txt"
#define uart2           @"uart2.txt"
#define uart3           @"uart3.txt"
#define power           @"power.log"
#define efi0_kis        @"efi0-kis.log"
#define efi0_uart       @"efi0-uart.log"
#define usbfs           @"usbfs.log"

//time tamp type
#define oc_time_regex1      @"(\\d+\\-\\d+\\-\\d+\\_\\d+\\-\\d+\\-\\d+\\-\\d+)"
#define lua_time_regex1     @"%d-%-%d-%-%d-%_%d-%-%d-%-%d-%-%d+"

#define oc_time_regex2      @"(\\d+\\-\\d+\\-\\d+\\s\\d+\\:\\d+\\:\\d+\\.\\d+)"
#define lua_time_regex2     @"%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+"

#define oc_time_regex3      @"(\\d+\\-\\d+\\-\\d+\\s\\d+\\:\\d+\\:\\d+\\.\\d+\\:)"
#define lua_time_regex3     @"%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+%:"

#define oc_time_regex4      @"(\\d+\\/\\d+\\/\\d+\\s\\d+\\:\\d+\\:\\d+\\.\\d+)"
#define lua_time_regex4     @"%d-%/%d-%/%d- %d-%:%d-%:%d-%.%d+"

#define oc_time_regex5      @"(\\d+\\-\\d+\\-\\d+\\s\\d+\\:\\d+\\:\\d+\\.\\d+\\: TestEngine)"
#define lua_time_regex5     @"%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+%: TestEngine"

//lua match group str regex
//2020-12-23 20:34:42.246: TestEngine: < Received >
#define Engine_regex        @"(.-%d-%-%d-%-%d-%_%d-%-%d-%-%d-%-%d+%s-%< Received %>.-)%d-%-%d-%-%d-%_%d-%-%d-%-%d-%-%d+%s-%< Received %>"
#define engine_regex1       @"(.-%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+%s-%< Received %>.-)%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+%s-%< Received %>"
#define engine_regex2       @"(.-%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+%:%s-TestEngine%:%s-%< Received %>.-)%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+%:%s-TestEngine%:%s-%< Received %>"
#define flow_plain_regex    @"(.-%=%=Test%:.-)%=%=Test%:"
#define sequencer_regex1    @"(.-%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+%:.-description.-)%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+%:[^\n]-description"
#define sequencer_regex2    @"(.-%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+%s-running test.-)%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+%s-running test"

@implementation logTypeController

- (instancetype)init
{
    self = [super init];
    if (self) {
        logTypeList = [[NSArray alloc]initWithObjects:pivot,FAIL_Summary,EngineLog,smcLog,engine,flow_plain,hw,iefi,sequencer,uart,uart2,uart3,power,efi0_kis,efi0_uart,usbfs,nil];
        timeTampTypeList = [[NSArray alloc]initWithObjects:oc_time_regex1,oc_time_regex2,oc_time_regex3,oc_time_regex4,oc_time_regex5,nil];
        lua_TimeTampTypeList = [[NSArray alloc]initWithObjects:lua_time_regex1,lua_time_regex2,lua_time_regex3,lua_time_regex4,lua_time_regex5,nil];
    }
    return self;
}

- (BOOL)isDetailViewLog:(NSString *)fileName
{
    if ([self isValidLogType:fileName]) {
        if ([fileName containsString:pivot] || [fileName containsString:FAIL_Summary]) {
            return NO;
        }else{
            return YES;
        }
    }else{
        return NO;
    }
    
}

- (BOOL)isSelectViewLog:(NSString *)fileName
{
    if ([self isValidLogType:fileName]) {
        if ([fileName containsString:pivot] || [fileName containsString:FAIL_Summary]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
    
    
}


- (BOOL)isValidLogType:(NSString *)fileName
{
    for ( int i = 0; i < [logTypeList count]; i++) {
        if ([fileName containsString:logTypeList[i]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isValidTimeTampType:(NSString *)content withLogType:(NSString *)logType
{
    if ([logType containsString:pivot] || [logType containsString:FAIL_Summary]) {
        return NO;
    }
    
    for ( int i = 0; i < [timeTampTypeList count]; i++) {
        if ([[content stringByMatching:timeTampTypeList[i]] length] > 0) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)getLogType:(NSString *)fileName
{
    for ( int i = 0; i < [logTypeList count]; i++) {
        if ([fileName containsString:logTypeList[i]]) {
            return logTypeList[i];
        }
    }
    return nil;
}

- (NSString *)getTimeTampType:(NSString *)content withLogType:(NSString *)logType
{
    if ([logType containsString:pivot] || [logType containsString:FAIL_Summary]) {
        return nil;
    }
    
    if ([logType containsString:sequencer] && [[content stringByMatching:oc_time_regex3] length] > 0) {
        return oc_time_regex3;
    }
    
    if ([logType containsString:engine] && [[content stringByMatching:oc_time_regex5] length] > 0) {
        return oc_time_regex5;
    }
    
    for ( int i = 0; i < [timeTampTypeList count]; i++) {
        if ([[content stringByMatching:timeTampTypeList[i]] length] > 0) {
            return timeTampTypeList[i];
        }
    }
    return nil;
}

- (NSString *)getLuaTimeTampType:(NSString *)oc_timptamp
{
    if ([timeTampTypeList containsObject:oc_timptamp]) {
        NSUInteger index = [timeTampTypeList indexOfObject:oc_timptamp];
        return lua_TimeTampTypeList[index];
    }else{
        return nil;
    }
}

- (NSString *)getMatchStr:(NSString *)logType withTimeTampType:(NSString *)type
{
    if ([logType containsString:EngineLog]) {
        
        return Engine_regex;
        
    }else if ([logType containsString:engine]){
        
        if ([type containsString:oc_time_regex5]) {
            return engine_regex2;
        }else{
            return engine_regex1;
        }
        
    }else if ([logType containsString:flow_plain]){
        
        return flow_plain_regex;
        
    }else if ([logType containsString:sequencer]){
        
        if ([type containsString:oc_time_regex3]) {
            return sequencer_regex1;
        }else{
            return sequencer_regex2;
        }
        
    }else{
        
        NSLog(@"Error logType for get MatchStr!");
        return nil;
        
    }
}

- (NSArray *)getIgnoreOption:(NSString *)logType
{
    if ([logType containsString:EngineLog] || [logType containsString:engine]) {
        return @[@"start_test",@"end_test"];
    }else{
        return @[];
    }
}

- (void)dealloc
{
    [logTypeList release];
    [timeTampTypeList release];
    [super dealloc];
}

@end
