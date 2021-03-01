//
//  logHandler.m
//  MainUI
//
//  Created by Henry on 2021/1/28.
//  Copyright © 2021 Henry. All rights reserved.
//

#import "logHandler.h"
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

@implementation logHandler

- (instancetype)initWithFilePath:(NSString *)path andTypeController:(logTypeController *)typeController
{
    self = [super init];
    if (self) {
        fileManager = [[NSFileManager alloc]init];
        arrSubString = [[NSMutableArray alloc]init];
        fileName = [path lastPathComponent];
        
        if ([fileManager fileExistsAtPath:path] && [typeController isValidLogType:fileName]) {
            filePath = [[NSString alloc]initWithFormat:@"%@",path];
            fileName = [[NSString alloc]initWithFormat:@"%@",[filePath lastPathComponent]];
            logType = [typeController getLogType:fileName];
            fileContent = [[NSString alloc]initWithFormat:@"%@",[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]];

//            NSLog(@"filePath: %@",filePath);
//            NSLog(@"fileName: %@",fileName);
//            NSLog(@"logType: %@",logType);
            
            if ([typeController isValidTimeTampType:fileContent withLogType:logType]) {
                timeTampType = [typeController getTimeTampType:fileContent withLogType:logType];
                msPrecisionLength = [TimeTamp measure_msPrecisionLength:fileContent withTimeTampType:timeTampType];
            }else{
                timeTampType = nil;
            }
            
            if ([logType containsString:pivot] || [logType containsString:FAIL_Summary]) {
                data = [self InitCSVData:fileContent];
            }else{
                data = nil;
            }
            
            if ([logType containsString:EngineLog] || [logType containsString:engine]) {
                allowSkip = YES;
            }else{
                allowSkip = NO;
            }
            
        }else{
            return nil;
        }
    }
    return self;
}

//解析pivot及fail_summary csv文件
- (NSMutableArray *)InitCSVData:(NSString *)content
{
    NSArray *rowData = [content componentsSeparatedByString:@"\n"];
    NSArray *headItem = [rowData[0] componentsSeparatedByString:@","];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    NSMutableDictionary *dic;
    NSArray *rowItem;
    
    for (int i = 1; i < [rowData count]; i++) {
        if (rowData[i] && [rowData[i] isNotEqualTo:@""]) {
            rowItem = [rowData[i] componentsSeparatedByString:@","];
            dic = [[NSMutableDictionary alloc]init];
            for (int j = 0; j < [rowItem count]; j++) {
                [dic setValue:rowItem[j] forKey:headItem[j]];
            }
            [arr addObject:dic];
        }
    }
    
    return arr;
}

//按时间戳及"runing test"字符串，分组解析sequence.log数据
- (void)analyzeSequenceLog:(NSArray *)pivotData
{
    if (![fileName containsString:sequencer]) {
        NSLog(@"Can't analyze other file without sequencer.log!");
        return;
    }
    
    NSUInteger length;
    NSUInteger location = 0;
    NSString *subString = nil;
    NSString *line = nil;
    NSMutableString *groupStr = nil;
    int add_len = 0;
    NSString *line_break = nil;
    BOOL firstFilterFlag = YES;
    
    
    NSArray *arrGroup = [fileContent componentsMatchedByRegex:[NSString stringWithFormat:@"%@.+running test",timeTampType]];
    if ([arrGroup count] != [pivotData count]) {
        NSLog(@"Analyze sequence log error, indexs is different from pivot log");
        return;
    }
    
    data = [[NSMutableArray alloc]initWithCapacity:[arrGroup count]];
    
////    dispatch_group_t group = dispatch_group_create();
////    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    for (int i = 0; i < [arrGroup count] - 1; i++) {
//
////        dispatch_group_enter(group);
////        dispatch_async(queue, ^{
//        NSLog(@"%d",i);
//            NSString *begin = arrGroup[i];
//            if ( (i+1) < [arrGroup count]) {
//                NSString *end = arrGroup[i+1];
//                NSString *regex = [NSString stringWithFormat:@"(%@[\\s|\\S]*%@)",begin,end];
//                NSString *groupStr = [[fileContent stringByMatching:regex]stringByMatching:@"([\\s|\\S]*\n)"];
//                SequenceGroup *sg =[[SequenceGroup alloc]initWithGroupStr:groupStr andSkipValue:[pivotData[i] valueForKey:@"result"]];
//                [data addObject:sg];
//            }
////
////            dispatch_group_leave(group);
////        });
//    }
////    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
//    if ([arrGroup count] > 0) {
//        NSString *lastGroupStr = [fileContent stringByMatching:[NSString stringWithFormat:@"(%@[\\s|\\S]*)",[arrGroup lastObject]]];
//        [data addObject:[[SequenceGroup alloc]initWithGroupStr:lastGroupStr andSkipValue:[[pivotData lastObject] valueForKey:@"result"]]];
//    }
    
    
    
    length = [fileContent length];

    //过滤第一个running test之前的无效字符
    NSString *regex = [NSString stringWithFormat:@"([\\s|\\S]*%@)",[fileContent stringByMatching:arrGroup[0]]];
    location = [[[fileContent stringByMatching:regex]stringByMatching:@"([\\s|\\S]*\n)"] length];

    for (int i = 0; i < [arrGroup count]; i++) {
//        NSLog(@"%d",i);
        @autoreleasepool {
            groupStr = [[NSMutableString alloc]init];

            while (location < length) {

                subString = [fileContent substringFromIndex:location];
                line = [subString stringByMatching:@".*"];

                if (([subString length] >= [line length] + 2) && [[subString substringToIndex:[line length]+2] containsString:[NSString stringWithFormat:@"%@\r\n",line]]){
                    //            [line appendString:@"\r\n"];
                    add_len = 2;
                    line_break = @"\r\n";
                }else if (([subString length] >= [line length] + 1) && [[subString substringToIndex:[line length]+1] containsString:[NSString stringWithFormat:@"%@\n",line]]){
                    //            [line appendString:@"\n"];
                    add_len = 1;
                    line_break = @"\n";
                }else if (([subString length] >= [line length] + 1) && [[subString substringToIndex:[line length]+1] containsString:[NSString stringWithFormat:@"%@\r",line]]){
                    //            [line appendString:@"\r"];
                    add_len = 1;
                    line_break = @"\r";
                }

                if (i + 1 < [arrGroup count]) {
                    if ([line containsString:arrGroup[i + 1]]) {//非最后一组时搜索下一组的时间戳
                        [data addObject:[[SequenceGroup alloc]initWithGroupStr:groupStr andSkipValue:[pivotData[i] valueForKey:@"result"]]];
                        [groupStr setString:@""];
                        break;
                    }
                }else{//最后一组时通过剩余subString初始化
                    [data addObject:[[SequenceGroup alloc]initWithGroupStr:subString andSkipValue:[[pivotData lastObject] valueForKey:@"result"]]];
                    break;
                }

                [groupStr appendFormat:@"%@%@",line,line_break];

                location = location + [line length] + add_len;
            }
        }
    }
    
    
    
}

//通过特殊字符索引
- (void)initSpecialLogSubString:(NSArray *)arr fromStartStr:(NSString *)start_str toEndStr:(NSString *)end_str ignoreOption:(NSArray *)optArr
{
    NSUInteger length;
    NSUInteger location = 0;
    NSMutableString *retString;
    NSString *subString = nil;
    NSString *line = nil;
    BOOL ignoreFlag = NO;
    NSString *line_break = nil;
    int add_len = 0;
    
    for (int i = 0; i < [arr count]; i++) {
        
        if (allowSkip && ((SequenceGroup *)arr[i])->skipValue) {
            [arrSubString addObject:@"\nSKIP\n"];
            continue;
        }
        
        length = [fileContent length];
        retString = [[NSMutableString alloc]init];
        
        @autoreleasepool{
            while (location < length) {
                subString = [fileContent substringFromIndex:location];
                line = [subString stringByMatching:@".*"];
                
                if (([subString length] >= [line length] + 2) && [[subString substringToIndex:[line length]+2] containsString:[NSString stringWithFormat:@"%@\r\n",line]]){
                    //                [line appendString:@"\r\n"];
                    add_len = 2;
                    line_break = @"\r\n";
                }else if (([subString length] >= [line length] + 1) && [[subString substringToIndex:[line length]+1] containsString:[NSString stringWithFormat:@"%@\n",line]]){
                    //                [line appendString:@"\n"];
                    add_len = 1;
                    line_break = @"\n";
                }else if (([subString length] >= [line length] + 1) && [[subString substringToIndex:[line length]+1] containsString:[NSString stringWithFormat:@"%@\r",line]]){
                    //                [line appendString:@"\r"];
                    add_len = 1;
                    line_break = @"\r";
                }
                
                [retString appendFormat:@"%@%@",line,line_break];
                location = location + [line length] + add_len;
                
                
                if ([[line stringByMatching:start_str] length] > 0) {
                    
                    ignoreFlag = YES;
                    for (int j = 0; j < [optArr count]; j++) {
                        if ([[line stringByMatching:optArr[j]] length] > 0) {
                            ignoreFlag = NO;
                        }
                    }
                }
                
                if (ignoreFlag && [[line stringByMatching:end_str] length] > 0) {
                    ignoreFlag = NO;
                    break;
                }
            }
            
            if (i == [arr count] - 1) {
                [retString appendString:subString];
            }
        }
        
        [arrSubString addObject:retString];
    }
}

//通过时间戳索引
- (void)initCommonLogSubString:(NSArray *)arr
{
    NSArray *arrGroup = [fileContent componentsMatchedByRegex:timeTampType];
    
    NSUInteger length;
    NSUInteger location = 0;
    NSMutableString *retString = nil;
    NSString *subString = nil;
    NSString *line = nil;
    TimeTamp *tempTp = nil;
    BOOL ignoreTimeTampFlag = NO;
    NSString *line_break = nil;
    int add_len = 0;
    
    for (int i = 0; i < [arr count]; i++) {
        TimeTamp *sub_tp1 = [[TimeTamp alloc]initWithString:((SequenceGroup *)arr[i])->startTime
                                          msPrecisionLength:msPrecisionLength
                                                integerType:@"DOWN"];
        TimeTamp *sub_tp2 = [[TimeTamp alloc]initWithString:((SequenceGroup *)arr[i])->endTime
                                          msPrecisionLength:msPrecisionLength
                                                integerType:@"UP"];
        
        TimeTamp *tp1 = [[TimeTamp alloc]initWithString:arrGroup[0]
                                      msPrecisionLength:msPrecisionLength
                                            integerType:@"DEFAULT"];
        TimeTamp *tp2 = [[TimeTamp alloc]initWithString:[arrGroup lastObject]
                                      msPrecisionLength:msPrecisionLength
                                            integerType:@"DEFAULT"];
        
        if ([tp1 isLaterThanTimeTamp:sub_tp2] || [tp2 isBeforeThanTimeTamp:sub_tp1]) {
            [arrSubString addObject:@""];
            continue;
        }
        
        length = [fileContent length];
        retString = [[NSMutableString alloc]init];
        
        @autoreleasepool {
            while (location < length) {
                
                subString = [fileContent substringFromIndex:location];
                line = [subString stringByMatching:@".*"];
                
                if (([subString length] >= [line length] + 2) && [[subString substringToIndex:[line length]+2] containsString:[NSString stringWithFormat:@"%@\r\n",line]]){
                    //                [line appendString:@"\r\n"];
                    add_len = 2;
                    line_break = @"\r\n";
                }else if (([subString length] >= [line length] + 1) && [[subString substringToIndex:[line length]+1] containsString:[NSString stringWithFormat:@"%@\n",line]]){
                    //                [line appendString:@"\n"];
                    add_len = 1;
                    line_break = @"\n";
                }else if (([subString length] >= [line length] + 1) && [[subString substringToIndex:[line length]+1] containsString:[NSString stringWithFormat:@"%@\r",line]]){
                    //                [line appendString:@"\r"];
                    add_len = 1;
                    line_break = @"\r";
                }
                
                tempTp = [[TimeTamp alloc]initWithString:[line stringByMatching:timeTampType]
                                       msPrecisionLength:msPrecisionLength
                                             integerType:@"DEFAULT"];
                if(tempTp != nil){
                    if([tempTp isLaterThanTimeTamp:sub_tp2]){
                        ignoreTimeTampFlag = NO;
                        break;
                    }else{
                        
                        [retString appendFormat:@"%@%@",line,line_break];
                        ignoreTimeTampFlag = YES;
                    }
                }
                
                if (ignoreTimeTampFlag && tempTp == nil) {
                    [retString appendFormat:@"%@%@",line,line_break];
                }
                
                location = location + [line length] + add_len;
                
                [tempTp release];
                //            [line release];
                //            [subString release];
            }
        }
        
        [arrSubString addObject:retString];
        
        [tp1 release];
        [tp2 release];
        [sub_tp1 release];
        [sub_tp2 release];
    }
}

//- (NSString *)subString:(NSString *)content withTimeTampArr:(NSArray *)arr
//{
//    NSArray *arrGroup = [content componentsMatchedByRegex:timeTampType];
//    
//    TimeTamp *sub_tp1 = [[TimeTamp alloc]initWithString:arr[0] msPrecisionLength:msPrecisionLength integerType:@"DOWN"];
//    TimeTamp *sub_tp2 = [[TimeTamp alloc]initWithString:[arr lastObject] msPrecisionLength:msPrecisionLength integerType:@"UP"];
//    
//    TimeTamp *tp1 = [[TimeTamp alloc]initWithString:arrGroup[0] msPrecisionLength:msPrecisionLength integerType:@"DEFAULT"];
//    TimeTamp *tp2 = [[TimeTamp alloc]initWithString:[arrGroup lastObject] msPrecisionLength:msPrecisionLength integerType:@"DEFAULT"];
//    
//    if ([tp1 isLaterThanTimeTamp:sub_tp2] || [tp2 isBeforeThanTimeTamp:sub_tp1]) {
//        NSLog(@"Do not contain these timp tamp!");
//        return nil;
//    }
//    
//    NSUInteger length = [content length];
//    NSUInteger location = 0;
//    
//    NSMutableString *retString = [[NSMutableString alloc]init];
//    NSMutableString *subString = nil;
//    NSMutableString *line = nil;
//    TimeTamp *tempTp = nil;
//    BOOL ignoreTimeTampFlag = NO;
//    
//    while (location <= length) {
//        
//        subString = [[NSMutableString alloc]initWithString:[content substringFromIndex:location]];
//        line = [[NSMutableString alloc]initWithString:[subString stringByMatching:@".*"]];
//        
//        if ([[subString substringToIndex:[line length]+2] containsString:[NSString stringWithFormat:@"%@\r\n",line]]){
//            [line appendString:@"\r\n"];
//        }else if ([[subString substringToIndex:[line length]+1] containsString:[NSString stringWithFormat:@"%@\n",line]]){
//            [line appendString:@"\n"];
//        }else if ([[subString substringToIndex:[line length]+1] containsString:[NSString stringWithFormat:@"%@\r",line]]){
//            [line appendString:@"\r"];
//        }
//        
//        tempTp = [[TimeTamp alloc]initWithString:[line stringByMatching:timeTampType]
//                               msPrecisionLength:msPrecisionLength
//                                     integerType:@"DEFAULT"];
//        if(tempTp != nil){
//            if(([tempTp isLaterThanTimeTamp:sub_tp1] || [tempTp isEqualToTimeTamp:sub_tp1]) && ([tempTp isBeforeThanTimeTamp:sub_tp2] || [tempTp isEqualToTimeTamp:sub_tp2])){
//                [retString appendString:line];
//                ignoreTimeTampFlag = YES;
//            }else if([tempTp isLaterThanTimeTamp:sub_tp2]){
//                ignoreTimeTampFlag = NO;
//                break;
//            }
//        }
//        
//        if (ignoreTimeTampFlag && tempTp == nil) {
//            [retString appendString:line];
//        }
//        
//        location += [line length];
//        
//        [tempTp release];
//        [line setString:@""];
//        [subString setString:@""];
//    }
//    
//    [tempTp release];
//    [line release];
//    [subString release];
//    [tp1 release];
//    [tp2 release];
//    
//    return retString;
//}

//根据Select View所勾选获取对应log
- (NSString *)getSubString:(NSArray *)arr
{
    NSString *str;
    NSUInteger loc;
    NSUInteger len;
    NSUInteger start;
    NSUInteger end;
    
    NSArray *subArr;
    NSMutableString *retString = [[NSMutableString alloc]init];
    
    @autoreleasepool {
        for (int i = 0; i < [arr count]; i++) {
            
            start = [arr[i][0] integerValue];
            end = [[arr[i] lastObject] integerValue];
            
            if (start >= [arrSubString count] || start < 0) {
                NSLog(@"Can't get sub string from %@ log, index out of range",logType);
                return @"";
            }
            
            loc = start;
            len = end - start + 1;
            
            subArr = [arrSubString subarrayWithRange:NSMakeRange(loc, len)];
            
            for (int j = 0; j < [subArr count]; j++) {
                str = subArr[j];
                if ([str length] > 0) {
                    [retString appendFormat:@"%@",str];
                }
            }
        }
        return retString;
    }

}

- (NSMutableArray *)data{
    return data;
}

- (void)dealloc
{
    [fileManager release];
    [data removeAllObjects];
    [data release];
    [filePath release];
    [fileName release];
    [fileContent release];
    [logType release];
    [timeTampType release];
    [arrSubString removeAllObjects];
    [super dealloc];
}

@end
