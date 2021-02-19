//
//  TimeTamp.m
//  Test
//
//  Created by Henry on 2021/2/11.
//  Copyright © 2021 Henry. All rights reserved.
//

#import "TimeTamp.h"
#define UP      @"UP"       //高精度转低精度时向上取整
#define DOWN    @"DOWN"     //高精度转低精度时向下取整
#define DEFAULT @"DEFAULT"  //默认取整

@implementation TimeTamp

- (instancetype)initWithString:(NSString *)str msPrecisionLength:(int)mpl integerType:(NSString *)type
{
    self = [super init];
    if (self) {
        NSArray *arr = [str componentsMatchedByRegex:@"(\\d+)"];
        if ([arr count] != 7) {
            return nil;
        }
        
        year = [arr[0] intValue];
        month = [arr[1] intValue];
        day = [arr[2] intValue];
        hour = [arr[3] intValue];
        minute = [arr[4] intValue];
        second = [arr[5] intValue];
        msPrecisionLength = mpl;
        
        if ([arr[6] length] <= mpl) {
            microsec = [arr[6] intValue] * pow(10, (mpl - ( [arr[6] length] )));
        }else{
            if ([type isEqualToString:UP]) {
                microsec = [[arr[6] substringToIndex:mpl] intValue] + 1;
            }else if ([type isEqualToString:DOWN]){
                microsec = [[arr[6] substringToIndex:mpl] intValue];
            }else{
                microsec = [[arr[6] substringToIndex:mpl] intValue];
            }
            
        }
    
//        NSLog(@"%d,%d,%d,%d,%d,%d,%d",year,month,day,hour,minute,second,microsec);
    }
    return self;
}

+ (int)measure_msPrecisionLength:(NSString *)str withTimeTampType:(NSString *)type
{
    NSArray *arr = [[str stringByMatching:type] componentsMatchedByRegex:@"(\\d+)"];
    if ([arr count] != 7) {
        return -1;
    }
    
    return [[NSString stringWithFormat:@"%lu",(unsigned long)[arr[6] length]] intValue];
}

- (BOOL)isLaterThanTimeTamp:(TimeTamp *)tp
{
    if (tp == nil) {
        return NO;
    }
    
    if (year > [tp year]) {
        return YES;
    }else if (year < [tp year]){
        return NO;
    }
    
    if(month > [tp month]){
        return YES;
    }else if (month < [tp month]){
        return NO;
    }
    
    if(day > [tp day]){
        return YES;
    }else if (day < [tp day]){
        return NO;
    }
    
    if(hour > [tp hour]){
        return YES;
    }else if (hour < [tp hour]){
        return NO;
    }
    
    if(minute > [tp minute]){
        return YES;
    }else if (minute < [tp minute]){
        return NO;
    }
    
    if(second > [tp second]){
        return YES;
    }else if (second < [tp second]){
        return NO;
    }
    
    if(microsec > [tp microsec]){
        return YES;
    }else if (microsec < [tp microsec]){
        return NO;
    }
    
    return NO;
}

- (BOOL)isBeforeThanTimeTamp:(TimeTamp *)tp
{
    if (tp == nil) {
        return NO;
    }
    
    if (year < [tp year]) {
        return YES;
    }else if (year > [tp year]){
        return NO;
    }
    
    if(month < [tp month]){
        return YES;
    }else if (month > [tp month]){
        return NO;
    }
    
    if(day < [tp day]){
        return YES;
    }else if (day > [tp day]){
        return NO;
    }
    
    if(hour < [tp hour]){
        return YES;
    }else if (hour > [tp hour]){
        return NO;
    }
    
    if(minute < [tp minute]){
        return YES;
    }else if (minute > [tp minute]){
        return NO;
    }
    
    if(second < [tp second]){
        return YES;
    }else if (second > [tp second]){
        return NO;
    }
    
    if(microsec < [tp microsec]){
        return YES;
    }else if (microsec > [tp microsec]){
        return NO;
    }
    
    return NO;

}

- (BOOL)isEqualToTimeTamp:(TimeTamp *)tp
{
    if (tp == nil) {
        return NO;
    }
    
    if (year == [tp year] && month == [tp month] && day == [tp day] && hour == [tp hour] && minute == [tp minute] && second == [tp second] && microsec == [tp microsec]) {
        return YES;
    }else{
        return NO;
    }
}

- (int)year
{
    return year;
}

- (int)month
{
    return month;
}

- (int)day
{
    return day;
}

- (int)hour
{
    return hour;
}

- (int)minute
{
    return minute;
}

- (int)second
{
    return second;
}

- (int)microsec
{
    return microsec;
}

- (int)msPrecisionLength
{
    return msPrecisionLength;
}

- (void)dealloc
{
    [super dealloc];
}

@end
