//
//  AppDelegate.h
//  MainUI
//
//  Created by Henry on 2021/1/22.
//  Copyright © 2021 Henry. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "logSelectView.h"
#import "logDetailView.h"
#import "logManager.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    IBOutlet NSView *TopView;
    IBOutlet NSView *BottomView;
    IBOutlet NSWindow *winLaunch;
    //    NSOpenPanel * panelOpenZipFile;
//    BOOL panelIsOpenFlag;
    logDetailView *logDetailViewController;
    logSelectView *logSelectViewController;
    logManager *log_manager;
    
    NSRect TopViewRect;
    NSRect BottomViewRect;
    NSString *configFilePath;
    NSMutableDictionary *dicConfiguration;
    NSFileManager* FileManager;
//    NSString *currentZipPath;
}
@end

