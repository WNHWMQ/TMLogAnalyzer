//
//  AppDelegate.m
//  MainUI
//
//  Created by Henry on 2021/1/22.
//  Copyright © 2021 Henry. All rights reserved.
//

#import "AppDelegate.h"

#define kShowAlertMessageBox    @"kShowAlertMessageBox"
#define kRefreshDetailView      @"kRefreshDetailView"
#define sequencer               @"sequencer.log"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSDistributedNotificationCenter defaultCenter]addObserver:self selector:@selector(showAlertMessageBox:) name:kShowAlertMessageBox object:nil suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
        [[NSDistributedNotificationCenter defaultCenter]addObserver:self selector:@selector(RefreshDetailView:) name:kRefreshDetailView object:nil suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];

        NSString *zipPath = [[NSString alloc]initWithString:@"/Users/henry/Desktop/TM LOG/MAC FCT/C020362000KPY5X3S_20200902-162204.721491_J457_FCT_FCT_C020362000KPY5X3S_FAIL.zip"];
        log_manager = [[logManager alloc] initWithZipPath:zipPath];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [_window center];
    
//    init log select view
    logSelectViewController = [[logSelectView alloc]initWithData:log_manager->logSelectHandlerDic];
    [self ReplaceView:TopView with:logSelectViewController.view];

    //init log detail view
    logDetailViewController = [[logDetailView alloc]init];
    [self ReplaceView:BottomView with:logDetailViewController.view];
    
    
    logHandler *lh;
    for (NSString *key in log_manager->logDetailHandlerDic) {
        lh = [log_manager->logDetailHandlerDic valueForKey:key];
        [logDetailViewController NewLogView:lh->logType withContent:lh->fileContent];
    }
    
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

-(void)ReplaceView:(NSView *)oldView with:(NSView *)newView
{
    [newView setFrame:[oldView frame]];
    [[oldView superview] addSubview:newView];
    [[oldView superview] replaceSubview:oldView with:newView];
    [oldView setHidden:YES];
}

- (IBAction)addNewTab:(id)sender {
    [logDetailViewController addNewTab:sender];
}

- (IBAction)closeTab:(id)sender {
    [logDetailViewController closeTab:sender];
}

- (void)showAlertMessageBox:(NSNotification *)note{
    NSString *info = [[note userInfo]valueForKey:@"message"];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"确认"];//增加一个按钮
    [alert setMessageText:@"警告"];//提示的标题
    [alert setInformativeText:info];//提示的详细内容
    [alert setAlertStyle:NSAlertStyleCritical];//设置警告⻛格
    [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode){
    }];
}

//快速排序
- (void)QuickSort:(NSMutableArray *)s withLeftIndex:(int)l andRightIndex:(int)r
{
    if (l < r)
    {
        int i = l, j = r, x = [s[l] intValue];
        while (i < j)
        {
            while(i < j && [s[j] intValue] >= x) // 从右向左找第一个小于x的数
                j--;
            if(i < j)
                s[i++] = s[j];
            
            while(i < j && [s[i] intValue] < x) // 从左向右找第一个大于等于x的数
                i++;
            if(i < j)
                s[j--] = s[i];
        }
        s[i] = [NSString stringWithFormat:@"%lu",(unsigned long)x];
        [self QuickSort:s withLeftIndex:l andRightIndex:i - 1];// 分治法递归调用
        [self QuickSort:s withLeftIndex:i + 1 andRightIndex:r];
    }
}

//根据提取所选时间戳的二维数组索引LOG
- (void)UpdateLogSubString:(NSArray *)indexs
{
    if ([indexs count] < 1) {
        return;
    }
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    logHandler *lh = (logHandler *)[log_manager->logDetailHandlerDic valueForKey:sequencer];
    NSString *start_tp = nil;
    NSString *end_tp = nil;
        
    int i = 0;
    int j = 0;
    
    do {
        j = i + 1;
        
        if (j == [indexs count]) {
            start_tp = ((SequenceGroup *)[lh data][[indexs[i] intValue]])->startTime;
            end_tp = ((SequenceGroup *)[lh data][[indexs[i] intValue]])->endTime;
            [arr addObject:@[start_tp,end_tp]];
            break;
        }
        
        start_tp = ((SequenceGroup *)[lh data][[indexs[i] intValue]])->startTime;
        while ([indexs[j] intValue] - [indexs[j-1] intValue] == 1) {
            end_tp = ((SequenceGroup *)[lh data][[indexs[j] intValue]])->endTime;;
            j++;
            if (j == [indexs count]) {
                end_tp = ((SequenceGroup *)[lh data][[indexs[j-1] intValue]])->endTime;;
                break;
            }
        }
        
        if (i + 1 == j) {
            end_tp = ((SequenceGroup *)[lh data][[indexs[i] intValue]])->endTime;;
        }
        i = j;
        
        [arr addObject:@[start_tp,end_tp]];
    } while (i < [indexs count] && j < [indexs count]);
    
    for (NSString *key in log_manager->logDetailHandlerDic) {
        lh = [log_manager->logDetailHandlerDic valueForKey:key];
        [logDetailViewController RefreshLogView:lh->logType withContent:[lh getSubString:arr]];
    }
}

//根据Table所选,刷新Log内容
- (void)RefreshDetailView:(NSNotification *)note{
    
    NSMutableArray *arr = [[note userInfo]valueForKey:@"message"];
    
    if ([arr count] < 1) {
        for (NSString *key in log_manager->logDetailHandlerDic) {
            logHandler *lh = [log_manager->logDetailHandlerDic valueForKey:key];
            [logDetailViewController RefreshLogView:lh->logType withContent:lh->fileContent];
        }
        return;
    }
    
    [self QuickSort:arr
      withLeftIndex:0
      andRightIndex:[[NSString stringWithFormat:@"%lu",(unsigned long)[arr count]]intValue] - 1];
    NSLog(@"currentSelectIndex : %@",arr);
    [self UpdateLogSubString:arr];
}

- (void)dealloc
{
    [super dealloc];
}

@end
