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
#define time_regex1     @"(\\d+\\-\\d+\\-\\d+\\_\\d+\\-\\d+\\-\\d+\\-\\d+)"
#define time_regex2     @"(\\d+\\-\\d+\\-\\d+\\s\\d+\\:\\d+\\:\\d+\\.\\d+)"
#define time_regex3     @"(\\d+\\/\\d+\\/\\d+\\s\\d+\\:\\d+\\:\\d+\\.\\d+)"

@implementation logTypeController

- (instancetype)init
{
    self = [super init];
    if (self) {
        logTypeList = [[NSArray alloc]initWithObjects:pivot,FAIL_Summary,EngineLog,smcLog,engine,flow_plain,hw,iefi,sequencer,uart,uart2,uart3,power,efi0_kis,efi0_uart,usbfs,nil];
        timeTampTypeList = [[NSArray alloc]initWithObjects:time_regex1,time_regex2,time_regex3,nil];
    }
    return self;
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
    
    for ( int i = 0; i < [timeTampTypeList count]; i++) {
        if ([[content stringByMatching:timeTampTypeList[i]] length] > 0) {
            return timeTampTypeList[i];
        }
    }
    return nil;
}

- (void)dealloc
{
    [super dealloc];
}

@end
