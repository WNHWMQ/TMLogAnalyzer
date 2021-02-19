//
//  logHandler.m
//  MainUI
//
//  Created by Henry on 2021/1/28.
//  Copyright © 2021 Henry. All rights reserved.
//

#import "logHandler.h"
#define pivot           @"pivot.csv"
#define FAIL_Summary    @"FAIL_Summary.csv"
#define sequencer       @"sequencer.log"

@implementation logHandler

- (instancetype)initWithFilePath:(NSString *)path andTypeController:(logTypeController *)typeController
{
    self = [super init];
    if (self) {
        fileManager = [[NSFileManager alloc]init];
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
            }else if([logType containsString:sequencer]){
//                NSThread *thread = [[NSThread alloc]initWithTarget:self
//                                                          selector:@selector(analyzeSequenceLog:)
//                                                            object:@{@"content":_fileContent,@"timeTampType":_timeTampType}];
//                [thread start];
                
                [self analyzeSequenceLog:@{@"content":fileContent,@"timeTampType":timeTampType}];
            }else{
                data = nil;
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
    
    for (int i = 1; i < [rowData count]; i++) {
        if (rowData[i] && [rowData[i] isNotEqualTo:@""]) {
            NSArray *rowItem = [rowData[i] componentsSeparatedByString:@","];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            for (int j = 0; j < [rowItem count]; j++) {
                [dic setValue:rowItem[j] forKey:headItem[j]];
            }
            [arr addObject:dic];
        }
    }
    
    return arr;
}

//按时间戳及"runing test"字符串，分组解析sequence.log数据
- (void)analyzeSequenceLog:(NSDictionary *)dic
{
//    logHandler *lh = [_logDetailHandlerDic valueForKey:sequencer];
    
    NSString *content = [dic valueForKey:@"content"];
    NSString *timeTampType = [dic valueForKey:@"timeTampType"];
    NSArray *arrGroup = [content componentsMatchedByRegex:[NSString stringWithFormat:@"%@.+running test",timeTampType]];
    data = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [arrGroup count] - 1; i++) {
        NSString *begin = arrGroup[i];
        if ( (i+1) < [arrGroup count]) {
            NSString *end = arrGroup[i+1];
            NSString *regex = [NSString stringWithFormat:@"(%@[\\s|\\S]*%@)",begin,end];
            NSString *groupStr = [[content stringByMatching:regex]stringByMatching:@"([\\s|\\S]*\n)"];
            [data addObject:[[SequenceGroup alloc]initWithGroupStr:groupStr]];
        }
    }
    
    if ([arrGroup count] > 0) {
        NSString *lastGroupStr = [content stringByMatching:[NSString stringWithFormat:@"(%@[\\s|\\S]*)",[arrGroup lastObject]]];
        [data addObject:[[SequenceGroup alloc]initWithGroupStr:lastGroupStr]];
    }
    
//    NSLog(@"%lu",(unsigned long)[_data count]);
//
//    for (int i = 0; i < [_data count]; i++) {
//        NSLog(@"%@  %@  %@  %@  %@\n",
//              [_data[i] startTime],
//              [_data[i] endTime],
//              [_data[i] TestName],
//              [_data[i] SubTestName],
//              [_data[i] SubSubTestName]);
//    }
}

- (NSString *)subString:(NSString *)content withTimeTampArr:(NSArray *)arr
{
    NSArray *arrGroup = [content componentsMatchedByRegex:timeTampType];
    
    TimeTamp *sub_tp1 = [[TimeTamp alloc]initWithString:arr[0] msPrecisionLength:msPrecisionLength integerType:@"DOWN"];
    TimeTamp *sub_tp2 = [[TimeTamp alloc]initWithString:[arr lastObject] msPrecisionLength:msPrecisionLength integerType:@"UP"];
    
    TimeTamp *tp1 = [[TimeTamp alloc]initWithString:arrGroup[0] msPrecisionLength:msPrecisionLength integerType:@"DEFAULT"];
    TimeTamp *tp2 = [[TimeTamp alloc]initWithString:[arrGroup lastObject] msPrecisionLength:msPrecisionLength integerType:@"DEFAULT"];
    
    if ([tp1 isLaterThanTimeTamp:sub_tp2] || [tp2 isBeforeThanTimeTamp:sub_tp1]) {
        NSLog(@"Do not contain these timp tamp!");
        return nil;
    }
    
    NSUInteger length = [content length];
    NSUInteger location = 0;
    
    NSMutableString *retString = [[NSMutableString alloc]init];
    NSMutableString *subString = nil;
    NSMutableString *line = nil;
    TimeTamp *tempTp = nil;
    BOOL ignoreTimeTampFlag = NO;
    
    while (location <= length) {
        
        subString = [[NSMutableString alloc]initWithString:[content substringFromIndex:location]];
        line = [[NSMutableString alloc]initWithString:[subString stringByMatching:@".*"]];
        
        if ([[subString substringToIndex:[line length]+2] containsString:[NSString stringWithFormat:@"%@\r\n",line]]){
            [line appendString:@"\r\n"];
        }else if ([[subString substringToIndex:[line length]+1] containsString:[NSString stringWithFormat:@"%@\n",line]]){
            [line appendString:@"\n"];
        }else if ([[subString substringToIndex:[line length]+1] containsString:[NSString stringWithFormat:@"%@\r",line]]){
            [line appendString:@"\r"];
        }
        
        tempTp = [[TimeTamp alloc]initWithString:[line stringByMatching:timeTampType]
                               msPrecisionLength:msPrecisionLength
                                     integerType:@"DEFAULT"];
        if(tempTp != nil){
            if(([tempTp isLaterThanTimeTamp:sub_tp1] || [tempTp isEqualToTimeTamp:sub_tp1]) && ([tempTp isBeforeThanTimeTamp:sub_tp2] || [tempTp isEqualToTimeTamp:sub_tp2])){
                [retString appendString:line];
                ignoreTimeTampFlag = YES;
            }else if([tempTp isLaterThanTimeTamp:sub_tp2]){
                ignoreTimeTampFlag = NO;
                break;
            }
        }
        
        if (ignoreTimeTampFlag && tempTp == nil) {
            [retString appendString:line];
        }
        
        location += [line length];
        
        [tempTp release];
        [line setString:@""];
        [subString setString:@""];
    }
    
    [line release];
    [subString release];
    [tp1 release];
    [tp2 release];
    
    return retString;
}

- (NSString *)getSubString:(NSArray *)arr
{
    
    TimeTamp *start_tp;
    TimeTamp *end_tp;
    
    NSMutableString *retString = [[NSMutableString alloc]init];
    
    for (int i = 0; i < [arr count]; i++) {
        start_tp = (TimeTamp *)arr[i][0];
        end_tp = (TimeTamp *)[arr[i] lastObject];
        [retString appendFormat:@"\n\n%@",[self subString:fileContent withTimeTampArr:@[start_tp,end_tp]]];
    }
    
    return retString;
}

- (NSMutableArray *)data
{
    return data;
}

- (void)dealloc
{
    [super dealloc];
}

@end
