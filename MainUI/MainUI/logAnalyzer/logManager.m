//
//  logManager.m
//  MainUI
//
//  Created by Henry on 2021/2/1.
//  Copyright © 2021 Henry. All rights reserved.
//

#import "logManager.h"

#define pivot                   @"pivot.csv"
#define FAIL_Summary            @"FAIL_Summary.csv"
#define kShowAlertMessageBox    @"kShowAlertMessageBox"
#define sequencer               @"sequencer.log"

@implementation logManager

- (instancetype)initWithZipPath:(NSString *)path
{
    self = [super init];
    if (self) {
        NSString *unzipPath = [self UnzipFile:path];
        NSArray *arrLogPath;
        logDetailHandlerDic = [[NSMutableDictionary alloc]init];
        logSelectHandlerDic = [[NSMutableDictionary alloc]init];
        logTypeController *typeController = [[logTypeController alloc]init];
        
        if (unzipPath) {
            arrLogPath = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:unzipPath error:nil];
            for (int i = 0; i < [arrLogPath count]; i++) {
                logHandler *lh = [[logHandler alloc] initWithFilePath:[unzipPath stringByAppendingPathComponent:arrLogPath[i]]
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
        }else{
            return nil;
        }
    }
    return self;
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
    NSString *cmd = [NSString stringWithFormat:@"unzip -o %@ -d %@",system_path,tempPath];
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
