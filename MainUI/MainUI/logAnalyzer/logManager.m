//
//  logManager.m
//  MainUI
//
//  Created by Henry on 2021/2/1.
//  Copyright © 2021 Henry. All rights reserved.
//

#import "logManager.h"

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

#define kShowAlertMessageBox    @"kShowAlertMessageBox"

@implementation logManager

- (instancetype)initWithZipPath:(NSString *)path
{
    self = [super init];
    if (self) {
        NSString *unzipPath = [self UnzipFile:path];
        logDetailHandlerDic = [[NSMutableDictionary alloc]init];
        logSelectHandlerDic = [[NSMutableDictionary alloc]init];
        logTypeController *typeController = [[logTypeController alloc]init];
        NSArray *arrLogPath = nil;
        logHandler *lh;
        
        if (unzipPath) {
            arrLogPath = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:unzipPath error:nil];
            for (int i = 0; i < [arrLogPath count]; i++) {
                lh = [[logHandler alloc] initWithFilePath:[unzipPath stringByAppendingPathComponent:arrLogPath[i]]
                                                   andTypeController:typeController];
                if (lh) {
                    if ([arrLogPath[i] containsString:pivot] || [arrLogPath[i] containsString:FAIL_Summary]) {
                        [logSelectHandlerDic setObject:lh forKey:lh->logType];
                        
                    }else{
                        [logDetailHandlerDic setObject:lh forKey:lh->logType];
                    }
                }
            }
            
            NSArray *failRows = [self findFailRows:[(logHandler *)[logSelectHandlerDic valueForKey:FAIL_Summary] data]
                                     fromPivotData:[(logHandler *)[logSelectHandlerDic valueForKey:pivot] data]];
            
            [logSelectHandlerDic setObject:failRows forKey:@"failRows"];
            [[logDetailHandlerDic valueForKey:sequencer] analyzeSequenceLog:[(logHandler *)[logSelectHandlerDic valueForKey:pivot] data]];
            
            logHandler *lh_temp;
            
            for (NSString *key in logDetailHandlerDic) {
                
//                logHandler *lh_temp = [logDetailHandlerDic valueForKey:key];
//                NSThread *thread = [[NSThread alloc]initWithTarget:self
//                                                          selector:@selector(initDetailLogData:)
//                                                            object:[logDetailHandlerDic valueForKey:key]];
//                [thread start];
                
                lh_temp = [logDetailHandlerDic valueForKey:key];
                if ([key isEqualToString:EngineLog] || [key isEqualToString:engine]) {
                    [lh_temp initSpecialLogSubString:[(logHandler *)[logDetailHandlerDic valueForKey:sequencer] data]
                                        fromStartStr:@"< Received >"
                                            toEndStr:@"< Result >"
                                        ignoreOption:@[@"start_test",@"end_test"]];
                }else if ([key isEqualToString:flow_plain]){
                    [lh_temp initSpecialLogSubString:[(logHandler *)[logDetailHandlerDic valueForKey:sequencer] data]
                                        fromStartStr:@"==Test:"
                                            toEndStr:lh_temp->timeTampType
                                        ignoreOption:@[]];
                    
                }else{
                    [lh_temp initCommonLogSubString:[(logHandler *)[logDetailHandlerDic valueForKey:sequencer] data]];
                }
            }
            
        }else{
            return nil;
        }
    }
    return self;
}

- (void)initDetailLogData:(logHandler *)lh
{
    [lh initCommonLogSubString:[(logHandler *)[logDetailHandlerDic valueForKey:sequencer] data]];
}

//解压 zip log
- (NSString *)UnzipFile:(NSString *)filePath
{
    //新建临时文件夹，方便获取解压后文件名
    NSString *tempPath = @"/tmp/tmTempLog";
    NSFileManager *fm =[NSFileManager defaultManager];
    BOOL isDir = NO;
    if (!([fm fileExistsAtPath:tempPath isDirectory:&isDir] && YES == isDir)) {
        if (![fm createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil])
        {
            NSLog(@"create directory '%@' fail",tempPath);
            return nil;
        }
    }
    
    //将文件解压至临时文件夹，并将路径空格进行转义
    NSString *system_path = [filePath stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    NSString *cmd = [NSString stringWithFormat:@"unzip -o %@ -d %@ -x __MACOSX/*",system_path,tempPath];
    int ret = system([cmd UTF8String]);
    if ( ret != 0) {
        NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:@"无法解压该文件!",@"message", nil];
        [[NSDistributedNotificationCenter defaultCenter]postNotificationName:kShowAlertMessageBox object:nil userInfo:dic];
        return nil;
    }
    
    //获取临时文件夹中的解压文件，并将此唯一的文件剪切至原目录，清空临时文件夹
    NSArray *arrItem = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempPath error:nil];
    NSString *unZipFileName = nil;
    for (NSString *item in arrItem) {
        if ([item isNotEqualTo:@".DS_Store"])
        {
            unZipFileName = item;
        }
    }
    if (unZipFileName == nil) {
        return nil;
    }
    [fm moveItemAtPath:[tempPath stringByAppendingPathComponent:unZipFileName]
                toPath:[[filePath stringByDeletingLastPathComponent]stringByAppendingPathComponent:unZipFileName]
                 error:nil];//需注意目标路径参数以目标文件名结尾
    [fm removeItemAtPath:tempPath error:nil];
    
    //判断原路径是否存在解压文件
    NSString *unZipPath = [[filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:unZipFileName];
    if (([[NSFileManager defaultManager]fileExistsAtPath:unZipPath isDirectory:&isDir])) {
        return unZipPath;
    }else{
        NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:@"解压错误!",@"message", nil];
        [[NSDistributedNotificationCenter defaultCenter]postNotificationName:kShowAlertMessageBox object:nil userInfo:dic];
        return nil;
    }
    return nil;
}

//返回fail_summary的fail项对应在pivot中的位置
- (NSMutableArray *)findFailRows:(NSMutableArray *)fData fromPivotData:(NSMutableArray *)pData
{
    NSMutableArray *rows = [[NSMutableArray alloc]init];
    
    if ([fData count] <= 0) {
        return rows;
    }
    
    for (int i = 0; i < [pData count]; i++) {
        if ([[pData[i] valueForKey:@"result"]isEqualToString:@"Fail"]) {
            [rows addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return rows;
}

- (void)dealloc
{
    [super dealloc];
}

@end
