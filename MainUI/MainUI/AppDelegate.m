//
//  AppDelegate.m
//  MainUI
//
//  Created by Henry on 2021/1/22.
//  Copyright © 2021 Henry. All rights reserved.
//

#import "AppDelegate.h"
#import "logAnalyzer/logTypeController.h"

#define kShowAlertMessageBox    @"kShowAlertMessageBox"
#define kRefreshDetailView      @"kRefreshDetailView"
#define sequencer               @"sequencer.log"

#define Key_ZipLogPath             @"ZipLogPath"

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
        
        FileManager = [[NSFileManager alloc] init];
        dicConfiguration = [[NSMutableDictionary alloc]init];
//        TopViewRect = [TopView frame];
//        BottomViewRect = [BottomView frame];
        NSString* resourcePath = [[NSBundle bundleForClass:[self class]] resourcePath];
        configFilePath = [[NSString alloc] initWithFormat:@"%@/Config.plist",resourcePath];
        [self LoadConfig:configFilePath];
    }
    return self;
}

- (void)LoadConfig:(NSString*)path
{
    if (![FileManager fileExistsAtPath:path])
    {
        NSString* str = [NSString stringWithFormat:@"/Users/%@/Documents",NSUserName()];
        [dicConfiguration setValue:str forKey:Key_ZipLogPath];
        [self SaveConfig:path];
    }
    else
    {
        [dicConfiguration setValuesForKeysWithDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    }
}

- (void)SaveConfig:(NSString*)path
{
    NSString* floderPath = [path stringByDeletingLastPathComponent];
    if (![FileManager fileExistsAtPath:floderPath])
    {
        [self CreateDirectoy:floderPath];
    }
    [dicConfiguration writeToFile:path atomically:YES];
}

-(BOOL)CreateDirectoy:(NSString*)path
{
    if (![path isAbsolutePath])
    {
        NSLog(@"TMLogAnalyzer App: '%@' is not a absolute path!",path);
        return NO;
    }
    
    if (![[path pathExtension] isEqualToString:@""])
    {
        NSLog(@"TMLogAnalyzer App: '%@' is not a directory path!",path);
        return NO;
    }
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* pathCheck = @"/";
    NSArray* arr = [path componentsSeparatedByString:@"/"];
    for(NSString* component in arr)
    {
        BOOL isDir;
        pathCheck = [pathCheck stringByAppendingPathComponent:component];
        if(!([fm fileExistsAtPath:pathCheck isDirectory:&isDir] && YES == isDir))
        {
            if (![fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil])
            {
                NSLog(@"TMLogAnalyzer App: create directory '%@' fail",pathCheck);
                return NO;
            }
        }
    }
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [_window center];
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
    [oldView removeFromSuperview];
//    [[oldView superview] replaceSubview:oldView with:newView];
}

//打开新的App command + N
- (IBAction)newApplication:(NSMenuItem *)sender {
    NSString *executablePath = [[NSBundle mainBundle] executablePath];
    NSTask *task    = [[NSTask alloc] init];
    task.launchPath = executablePath;
    [task launch];
}

- (IBAction)openZipFile:(NSMenuItem *)sender {
    
    NSString *zipPath = nil;
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setDirectoryURL:[NSURL fileURLWithPath:[dicConfiguration valueForKey:Key_ZipLogPath] isDirectory:YES]];
    [panel setCanChooseDirectories:NO];
    [panel setCanCreateDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:@[@"zip"]];
    [panel setMessage:@"Please select log file"];
    panel.prompt = @"Choose";
    if ([panel runModal] == NSModalResponseOK) {
        zipPath = [[NSString alloc]initWithString:[panel.URL path]];
    }
    
    if (log_manager) {
        [log_manager dealloc];
    }

    if (logDetailViewController) {
//        [logDetailViewController dealloc];
    }
    
    if (logSelectViewController) {
        [logSelectViewController dealloc];
    }
    
    log_manager = [[logManager alloc] initWithZipPath:zipPath];
    
    if (log_manager) {
        
        [dicConfiguration setObject:zipPath forKey:Key_ZipLogPath];
        [self SaveConfig:configFilePath];
        
        //init log select view
        logSelectViewController = [[logSelectView alloc]initWithData:log_manager->logSelectHandlerDic];
        [self ReplaceView:TopView with:logSelectViewController.view];
        TopView = logSelectViewController.view;
        
        //init log detail view
        logDetailViewController = [[logDetailView alloc]init];
        [self ReplaceView:BottomView with:logDetailViewController.view];
        BottomView = logDetailViewController.view;
        
        logHandler *lh;
        for (NSString *key in log_manager->logDetailHandlerDic) {
            lh = [log_manager->logDetailHandlerDic valueForKey:key];
            [logDetailViewController NewLogView:lh->logType withContent:lh->fileContent];
        }
    }
    
    [zipPath release];
}

//打开新的log文件 command + T
- (IBAction)addNewTab:(id)sender {
    
    if (log_manager) {
        NSString *filePath;
        NSMutableArray *selectFiles = [[NSMutableArray alloc]init];
        logTypeController *typeController = [[logTypeController alloc]init];
        NSOpenPanel * panel = [NSOpenPanel openPanel];
        [panel setDirectoryURL:[NSURL fileURLWithPath:log_manager->unzipPath isDirectory:YES]];
        [panel setCanChooseDirectories:NO];
        [panel setCanCreateDirectories:NO];
        [panel setCanChooseFiles:YES];
        [panel setAllowsMultipleSelection:YES];
        [panel setAllowedFileTypes:@[@"log",@"csv",@"txt"]];
        [panel setMessage:@"Please select log file"];
        panel.prompt = @"Choose";
        if ([panel runModal] == NSModalResponseOK) {
            for (int i = 0; i < [panel.URLs count]; i++) {
                filePath = [panel.URLs[i] path];
                if ([typeController isDetailViewLog:filePath]) {
                    [selectFiles addObject:[typeController getLogType:filePath]];
                }else{
                    NSLog(@"Invalid file: %@",filePath);
                }
            }
        }
        
        logHandler *lh;
        for (int i = 0; i < [selectFiles count]; i++) {
            lh = [log_manager->logDetailHandlerDic valueForKey:selectFiles[i]];
            [logDetailViewController NewLogView:selectFiles[i] withContent:lh->fileContent];
        }
    }
}

//关闭log文件 command + W
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
    
    @autoreleasepool {
        logHandler *lh;
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        
        int i = 0;
        int j = 0;
        
        NSString *start_tp = nil;
        NSString *end_tp = nil;
        
        do {
            j = i + 1;
            
            if (j == [indexs count]) {
                start_tp = indexs[i];
                end_tp = indexs[i];
                [arr addObject:@[start_tp,end_tp]];
                break;
            }
            
            start_tp = indexs[i];
            while ([indexs[j] intValue] - [indexs[j-1] intValue] == 1) {
                end_tp = indexs[j];
                j++;
                if (j == [indexs count]) {
                    end_tp = indexs[j-1];
                    break;
                }
            }
            
            if (i + 1 == j) {
                end_tp = indexs[i];
            }
            i = j;
            
            [arr addObject:@[start_tp,end_tp]];
        } while (i < [indexs count] && j < [indexs count]);
        
        
        for (NSString *key in log_manager->logDetailHandlerDic) {
            lh = [log_manager->logDetailHandlerDic valueForKey:key];
            [logDetailViewController RefreshLogView:lh->logType withContent:[lh getSubString:arr]];
        }
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
