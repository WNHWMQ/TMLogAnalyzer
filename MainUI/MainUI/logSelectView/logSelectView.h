//
//  logSelectView.h
//  MainUI
//
//  Created by Henry on 2021/2/1.
//  Copyright © 2021 Henry. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "logHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface logSelectView : NSViewController <NSTableViewDataSource,NSTableViewDelegate,NSMenuDelegate,NSTabViewDelegate>{
    IBOutlet NSTabView *baseTabView;
    IBOutlet NSTableView *pivotTableView;
    IBOutlet NSTableView *failSummaryTableView;
    IBOutlet NSMenu *menuView;
    
    NSTableView *currentTableView;
    NSMutableDictionary *logItem;
    NSMutableArray *pivotData;
    NSMutableArray *failSummaryData;
    NSMutableArray *currentSourceData;
    NSMutableArray *currentSelectIndex;
    NSArray *failRowsIndex;
    NSArray *arrHeadIdentifier;
}

- (instancetype)initWithData:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
