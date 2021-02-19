//
//  SequenceGroup.m
//  MainUI
//
//  Created by Henry on 2021/2/9.
//  Copyright © 2021 Henry. All rights reserved.
//

#import "SequenceGroup.h"

@implementation SequenceGroup

- (instancetype)initWithGroupStr:(NSString *)groupStr
{
    self = [super init];
    if (self) {
        NSArray *arrItem = [groupStr componentsMatchedByRegex:@"(\\d+\\-\\d+\\-\\d+\\s\\d+\\:\\d+\\:\\d+\\.\\d+.+\n)"];
        startTime = [[NSString alloc]initWithFormat:@"%@",[arrItem[0] stringByMatching:@"(\\d+\\-\\d+\\-\\d+\\s\\d+\\:\\d+\\:\\d+\\.\\d+)"]];
        endTime = [[NSString alloc]initWithFormat:@"%@",[[arrItem lastObject] stringByMatching:@"(\\d+\\-\\d+\\-\\d+\\s\\d+\\:\\d+\\:\\d+\\.\\d+)"]];
        NSArray *tempArr = [arrItem[0] componentsSeparatedByString:@","];
        for (int i = 0; i < [tempArr count]; i++) {
            
            if ([tempArr[i] containsString:@"'GROUP':"]) {
                TestName = [[NSString alloc]initWithFormat:@"%@",[tempArr[i] stringByMatching:@"('GROUP': '.*')"]];
            }else if ([tempArr[i] containsString:@"'TID':"]){
                SubTestName = [[NSString alloc]initWithFormat:@"%@",[tempArr[i] stringByMatching:@"('TID': '.*')"]];
            }else if ([tempArr[i] containsString:@"'SUBSUBTESTNAME':"]){
                SubSubTestName = [[NSString alloc]initWithFormat:@"%@",[tempArr[i] stringByMatching:@"('SUBSUBTESTNAME': '.*')"]];
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
