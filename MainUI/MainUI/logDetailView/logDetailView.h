//
//  logDetailView.h
//  MainUI
//
//  Created by Henry on 2021/1/25.
//  Copyright © 2021 Henry. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MMTabBarView/MMTabBarView.h>
#import "TabBarItem.h"
#import "logScrollViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface logDetailView : NSViewController <MMTabBarViewDelegate>{
    IBOutlet MMTabBarView *tabBar;
    IBOutlet NSTabView *tabView;
    NSMutableDictionary *dicLogTextView;
}
- (IBAction)addNewTab:(id)sender;
- (IBAction)closeTab:(id)sender;
-(void)RefreshLogView:(NSString *)logType withContent:(NSString *)content;
-(void)NewLogView:(NSString *)logType withContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
