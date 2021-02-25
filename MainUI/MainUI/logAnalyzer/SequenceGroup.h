//
//  SequenceGroup.h
//  MainUI
//
//  Created by Henry on 2021/2/9.
//  Copyright © 2021 Henry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"
#import "TimeTamp.h"

NS_ASSUME_NONNULL_BEGIN

@interface SequenceGroup : NSObject
{
@public
    NSString *startTime;
    NSString *endTime;
    NSString *TestName;
    NSString *SubTestName;
    NSString *SubSubTestName;
    BOOL skipValue;
}
//@property (strong) NSString *startTime;
//@property (strong) NSString *endTime;
//@property (strong) NSString *TestName;
//@property (strong) NSString *SubTestName;
//@property (strong) NSString *SubSubTestName;

- (instancetype)initWithGroupStr:(NSString *)groupStr andSkipValue:(NSString *)sv;
@end

NS_ASSUME_NONNULL_END
