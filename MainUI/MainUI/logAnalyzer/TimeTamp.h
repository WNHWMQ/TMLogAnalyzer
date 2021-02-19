//
//  TimeTamp.h
//  Test
//
//  Created by Henry on 2021/2/11.
//  Copyright © 2021 Henry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimeTamp : NSObject
{
    int year;
    int month;
    int day;
    int hour;
    int minute;
    int second;
    int microsec;
    int msPrecisionLength;
}

- (int)year;
- (int)month;
- (int)day;
- (int)hour;
- (int)minute;
- (int)second;
- (int)microsec;
- (int)msPrecisionLength;
- (instancetype)initWithString:(NSString *)str msPrecisionLength:(int)mpl integerType:(NSString *)type;
- (BOOL)isLaterThanTimeTamp:(TimeTamp *)tp;
- (BOOL)isBeforeThanTimeTamp:(TimeTamp *)tp;
- (BOOL)isEqualToTimeTamp:(TimeTamp *)tp;
+ (int)measure_msPrecisionLength:(NSString *)str withTimeTampType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
