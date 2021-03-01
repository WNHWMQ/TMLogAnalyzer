//
//  logSelectView.m
//  MainUI
//
//  Created by Henry on 2021/2/1.
//  Copyright © 2021 Henry. All rights reserved.
//

#import "logSelectView.h"

#define ITEM_IDENTIFIER     @"site,sn,testname,subtestname,subsubtestname,unit,low,high,month,day,hour,minute,second,microsec,result,value,fail_msg"
#define kRefreshDetailView  @"kRefreshDetailView"
#define pivot               @"pivot.csv"
#define FAIL_Summary        @"FAIL_Summary.csv"

@interface logSelectView ()

@end

@implementation logSelectView

- (instancetype)initWithData:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        pivotData = [(logHandler *)[dic valueForKey:pivot] data];
        failSummaryData = [(logHandler *)[dic valueForKey:FAIL_Summary] data];
        failRowsIndex = [dic valueForKey:@"failRows"];
        arrHeadIdentifier = [ITEM_IDENTIFIER  componentsSeparatedByString:@","];
        currentSelectIndex = [[NSMutableArray alloc]init];
        [self initCheckButton];
    }
    return self;
}

- (void)initCheckButton
{
    for (int i = 0; i < [pivotData count]; i++) {
        NSButton *check_button = [NSButton checkboxWithTitle:@"" target:self action:@selector(btCheckButton:)];
        [check_button setFrame:NSMakeRect(0, 0, 40, 20)];
        [check_button setTarget:self];
        [check_button setImagePosition:NSImageOverlaps];
        check_button.identifier = [NSString stringWithFormat:@"%d",i];
        [pivotData[i] setValue:check_button forKey:@"checkButton"];
    }
    
    for (int i = 0; i < [failSummaryData count]; i++) {
        NSButton *check_button = [NSButton checkboxWithTitle:@"" target:self action:@selector(btCheckButton:)];
        [check_button setFrame:NSMakeRect(0, 0, 40, 20)];
        [check_button setTarget:self];
        [check_button setImagePosition:NSImageOverlaps];
        check_button.identifier = [NSString stringWithFormat:@"%d",i];
        [failSummaryData[i] setValue:check_button forKey:@"checkButton"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    baseTabView.delegate = self;
    [baseTabView selectTabViewItemAtIndex:0];
    currentTableView = pivotTableView;
    currentSourceData = pivotData;
    
    pivotTableView.dataSource = self;
    pivotTableView.delegate = self;
    menuView.delegate = self;
    pivotTableView.menu = menuView;
    
    failSummaryTableView.dataSource = self;
    failSummaryTableView.delegate = self;
    failSummaryTableView.menu = menuView;
    
//    [self endbleDefaultCheckButton];
    
    [pivotTableView reloadData];
    [failSummaryTableView reloadData];

    // Do view setup here.
}

- (void)UpdateOtherTabView:(int)idx withState:(NSControlStateValue)state
{
    NSButton *bt;
    if ([currentTableView.identifier isEqualToString:@"pivot"]) {
        for (int i = 0; i < [failRowsIndex count]; i++) {
            if ([failRowsIndex[i] intValue] == idx) {
                bt = [self->failSummaryData[i] valueForKey:@"checkButton"];
                bt.state = state;
            }
        }
    }else{
        bt = [self->pivotData[[failRowsIndex[idx] intValue]] valueForKey:@"checkButton"];
        bt.state = state;
    }
}

- (void)UpdateCurrentSelectIndex:(NSArray *)indexs withState:(NSArray *)states{
    
    NSString *obj = nil;
    for ( int i = 0; i < [indexs count]; i++) {
        if ([currentTableView.identifier isEqualToString:@"pivot"]){
            obj = indexs[i];
        }else{
            obj = failRowsIndex[[indexs[i] intValue]];
        }
        
        if ((NSControlStateValue)[states[i] intValue] == NSControlStateValueOn) {
            if (![currentSelectIndex containsObject:obj]) {
                [currentSelectIndex addObject:obj];
            }
            
        }else if ((NSControlStateValue)[states[i] intValue] == NSControlStateValueOff){
            if ([currentSelectIndex containsObject:obj]) {
                [currentSelectIndex removeObject:obj];
            }
        }else{
            NSLog(@"Update Error Current state");
            return;
        }
    }
    
    NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:currentSelectIndex,@"message",nil];
    [[NSDistributedNotificationCenter defaultCenter]postNotificationName:kRefreshDetailView object:nil userInfo:dic];
}

- (void)btCheckButton:(id)sender
{
    NSButton *bt;
    NSDictionary *dic;
    NSArray *indexs;
    NSArray *states;
    
    if ([sender isKindOfClass:[NSDictionary class]]) {
        
        dic = (NSDictionary *)sender;
        indexs = [dic valueForKey:@"indexs"];
        states = [dic valueForKey:@"states"];
        for (int i = 0; i <[indexs count]; i++) {
            bt = [[dic valueForKey:@"data"][[indexs[i] intValue]] valueForKey:@"checkButton"];
            bt.state = (NSControlStateValue)[states[i] intValue];
            [self UpdateOtherTabView:[indexs[i] intValue] withState:bt.state];
        }
        [self UpdateCurrentSelectIndex:indexs withState:states];
        
        
    }else if([sender isKindOfClass:[NSButton class]]){
        
        bt = (NSButton *)sender;
        [self UpdateCurrentSelectIndex:[[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%d",[bt.identifier intValue]], nil]
                             withState:[[NSArray alloc]initWithObjects:[NSString stringWithFormat:@"%ld",(long)bt.state], nil]];
        [self UpdateOtherTabView:[bt.identifier intValue] withState:bt.state];
    }else{
        NSLog(@"Error Select:%@",[sender class]);
    }
    
}

- (void)endbleDefaultCheckButton
{
    NSButton *bt;
    for (int i = 0; i < [failRowsIndex count]; i++) {
        bt = [pivotData[[failRowsIndex[i] intValue]] valueForKey:@"checkButton"];
        bt.state = NSControlStateValueOn;
        [self UpdateOtherTabView:[failRowsIndex[i] intValue] withState:NSControlStateValueOn];
    }
}

- (IBAction)enableCheckButton:(id)sender
{
    NSMutableArray *arrIndex = [[NSMutableArray alloc]init];
    NSMutableArray *arrState = [[NSMutableArray alloc]init];
    [currentTableView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
        [arrIndex addObject:[NSString stringWithFormat:@"%lu",(unsigned long)idx]];
        [arrState addObject:[NSString stringWithFormat:@"%lu",(unsigned long)NSControlStateValueOn]];
    }];
    
    NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:currentSourceData,@"data",
                         arrIndex,@"indexs",
                         arrState,@"states",
                         nil];
    [self btCheckButton:dic];

}

- (IBAction)disableCheckButton:(id)sender
{
    NSMutableArray *arrIndex = [[NSMutableArray alloc]init];
    NSMutableArray *arrState = [[NSMutableArray alloc]init];
    [currentTableView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
        [arrIndex addObject:[NSString stringWithFormat:@"%lu",(unsigned long)idx]];
        [arrState addObject:[NSString stringWithFormat:@"%lu",(unsigned long)NSControlStateValueOff]];
    }];
    
    NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:currentSourceData,@"data",
                         arrIndex,@"indexs",
                         arrState,@"states",
                         nil];
    [self btCheckButton:dic];
}

/**
 pragma mark - NSTabViewDelegate
 **********************************************************************************************************************************************/
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if ([tabViewItem.label isEqualToString:@"Pivot"]) {
        currentTableView = pivotTableView;
        currentSourceData = pivotData;
        [pivotTableView reloadData];
    }else{
        currentTableView = failSummaryTableView;
        currentSourceData = failSummaryData;
        [failSummaryTableView reloadData];
    }
}

/**
 pragma mark - NSMenuDelegate
 **********************************************************************************************************************************************/
- (void)menuNeedsUpdate:(NSMenu *)menu
{
    if (![[currentTableView selectedRowIndexes]containsIndex:[currentTableView clickedRow]]) {
        [currentTableView selectRowIndexes:[NSIndexSet indexSetWithIndex: [currentTableView clickedRow]]
                      byExtendingSelection:YES];
    }
}


/**
 pragma mark-TableViewDataSource
 **********************************************************************************************************************************************/
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    //返回表格共有多少行数据
    return [currentSourceData count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *column = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if ([tableColumn.identifier isEqualToString:@"select"]) {
        [column addSubview:[currentSourceData[row] valueForKey:@"checkButton"]];
    }else{
        NSTextField *textField = [column subviews][0];
        textField.stringValue = [currentSourceData[row] valueForKey:tableColumn.title];
        if ([currentTableView.identifier isEqualToString:@"pivot"]) {
            
            if ([failRowsIndex containsObject:[NSString stringWithFormat:@"%ld",(long)row]]) {
                textField.textColor = NSColor.redColor;
            }else{
                textField.textColor = NSColor.blackColor;
            }
        }else{
            textField.textColor = NSColor.redColor;
        }
    }
    return column;
}

- (void)dealloc
{
    [currentTableView release];
    [logItem removeAllObjects];
    [logItem release];
    [pivotData removeAllObjects];
    [pivotData release];
    [failSummaryData removeAllObjects];
    [failSummaryData release];
    
    [currentSelectIndex removeAllObjects];
    [currentSelectIndex release];
    [failRowsIndex release];
//    [arrHeadIdentifier release];
    [super dealloc];
}

@end
