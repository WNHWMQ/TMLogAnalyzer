//
//  winDelegateLaunch.m
//  MainUI
//
//  Created by Henry on 2021/3/3.
//  Copyright © 2021 Henry. All rights reserved.
//

#import "winDelegateLaunch.h"

@implementation winDelegateLaunch

- (void)awakeFromNib{
//    serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnNotification:) name:kNotificationStartupLog object:nil];
}

- (void)OnNotification:(NSNotification *)nf
{
//    dispatch_sync(serialQueue,^{
        NSString * name = [nf name];
        if([name isEqualToString:kNotificationStartupLog])
        {
            //        NSLog(@" got kNotificationStartupLog");
            [self performSelectorOnMainThread:@selector(UpdateLog:) withObject:[nf userInfo] waitUntilDone:YES];
            [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
        }
//    });
}

- (void)UpdateLog:(id)sender
{
    NSString * str = [sender objectForKey:kStartupMsg];
    NSNumber * level = [sender objectForKey:kStartupLevel];
    if(!str) return;
    NSColor * color = nil;
    if(level)
    {
        switch ([level integerValue]) {
            case MSG_LEVEL_NORMAL:
                color = [NSColor blueColor];
                break;
            case MSG_LEVEL_ERROR:
                color = [NSColor redColor];
                break;
            case MSG_LEVEL_WARNNING:
                color = [NSColor orangeColor];
                break;
            default:
                break;
        }
    }
    else
        color = [NSColor blackColor];
    
    NSDateFormatter * fmt = [[NSDateFormatter alloc]init];
    [fmt setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS : "];
    NSString * date = [NSString stringWithFormat:@"%@\t %@\r\n",[fmt stringFromDate:[NSDate date]],str];
    
    NSAttributedString * attStr = [[NSAttributedString alloc]initWithString:date attributes:[NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName , nil]];
    [[launchTextView textStorage] appendAttributedString:attStr];
    NSRange range = NSMakeRange([[launchTextView textStorage] length],0);
    [launchTextView scrollRangeToVisible:range];
}

-(void)ClearLog
{
    [launchTextView setString:@""];
}

@end
