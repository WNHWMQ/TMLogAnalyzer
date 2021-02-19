//
//  logDetailView.m
//  MainUI
//
//  Created by Henry on 2021/1/25.
//  Copyright © 2021 Henry. All rights reserved.
//

#import "logDetailView.h"

@interface logDetailView ()

@end

@implementation logDetailView

- (instancetype)init
{
    self = [super init];
    if (self) {
        dicLogTextView = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // remove any tabs present in the nib
    for (NSTabViewItem *item in tabView.tabViewItems) {
        [tabView removeTabViewItem:item];
    }
    [self configTabBar];
}

-(void)UpdateViewLog:(NSDictionary *)dic
{
    NSTextView *view = [dic valueForKey:@"LogType"];
    NSString *str = [dic valueForKey:@"Content"];
    
    if ([str isEqualToString:@""] || str == nil) {
        return;
    }
    
    NSMutableString * pstr = [[view textStorage] mutableString];
    //    if ([str containsString:@"\n"])
    //    {
    //        [pstr appendFormat:@"%@",str];
    //    }
    //    else
    //    {
    //        [pstr appendFormat:@"%@\n",str];
    //    }
    [pstr setString:str];
    NSRange range = NSMakeRange([pstr length]-1,0);
    [view scrollRangeToVisible:range];//显示的文本滚动到最后一行
}

-(void)RefreshLogView:(NSString *)logType withContent:(NSString *)content
{
    NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:content,@"Content",[dicLogTextView valueForKey:logType],@"LogType",nil];
    [self performSelectorOnMainThread:@selector(UpdateViewLog:) withObject:dic waitUntilDone:YES];
}

-(void)NewLogView:(NSString *)logType withContent:(NSString *)content
{
    [self addNewTabWithTitle:logType];
    [self RefreshLogView:logType withContent:content];
}

- (void)addNewTabWithTitle:(NSString *)aTitle {
    NSScrollView * newScrollView = [[[logScrollViewController alloc]init].view subviews][0];
    NSArray* arrView = [newScrollView subviews];
    for (NSView* subView in arrView)
    {
        if ([subView isKindOfClass:[NSClipView class]])
        {
            NSArray* arrTextView = [subView subviews];
            for (NSView* newTextView in arrTextView)
            {
                if ([newTextView isKindOfClass:[NSTextView class]])
                {
                    NSTextView* logView = (NSTextView *)newTextView;
                    [dicLogTextView setObject:logView forKey:aTitle];
                    break;
                }
            }
        }
    }
    
    
    TabBarItem *tabBarItem = [[TabBarItem alloc] init];
    [tabBarItem setTitle:aTitle];
    NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:tabBarItem];
    [[newItem view] setFrame:NSMakeRect(0, 0, 946, 412)];
    [[newItem view] addSubview:newScrollView];
    
    [tabView addTabViewItem:newItem];
    [tabView selectTabViewItem:newItem];
}

- (IBAction)addNewTab:(id)sender {
    [self addNewTabWithTitle:@"Untitled"];
}

- (IBAction)closeTab:(id)sender {
    
    NSTabViewItem *tabViewItem = tabView.selectedTabViewItem;
    
    if ((tabBar.delegate) && ([tabBar.delegate respondsToSelector:@selector(tabView:shouldCloseTabViewItem:)])) {
        if (![tabBar.delegate tabView:tabView shouldCloseTabViewItem:tabViewItem]) {
            return;
        }
    }
    
    if ((tabBar.delegate) && ([tabBar.delegate respondsToSelector:@selector(tabView:willCloseTabViewItem:)])) {
        [tabBar.delegate tabView:tabView willCloseTabViewItem:tabViewItem];
    }
    
    [tabView removeTabViewItem:tabViewItem];
    
    if ((tabBar.delegate) && ([tabBar.delegate respondsToSelector:@selector(tabView:didCloseTabViewItem:)])) {
        [tabBar.delegate tabView:tabView didCloseTabViewItem:tabViewItem];
    }
}

- (MMTabBarView *)tabBar {
    return tabBar;
}

#pragma mark -
#pragma mark ---- tab bar config ----

- (void)configTabBar {
    [tabBar setStyleNamed:@"Mojave"];
    [tabBar setOrientation:MMTabBarHorizontalOrientation];
    [tabBar setTearOffStyle:MMTabBarTearOffMiniwindow];
    [tabBar setCanCloseOnlyTab:YES];
    [tabBar setDisableTabClose:NO];
    [tabBar setAllowsBackgroundTabClosing:YES];
    [tabBar setOnlyShowCloseOnHover:YES];
    [tabBar setHideForSingleTab:NO];
    [tabBar setShowAddTabButton:YES];
    [tabBar setUseOverflowMenu:NO];
    [tabBar setAutomaticallyAnimates:YES];
    [tabBar setAllowsScrubbing:NO];
    [tabBar setButtonMinWidth:100];
    [tabBar setButtonMaxWidth:280];
    [tabBar setButtonOptimumWidth:130];
    [tabBar setSizeButtonsToFit:NO];
}

#pragma mark -
#pragma mark ---- tab view delegate ----

- (void)tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    // need to update bound values to match the selected tab
    TabBarItem* const tabBarItem = tabViewItem.identifier;
}

- (BOOL)tabView:(NSTabView *)aTabView shouldCloseTabViewItem:(NSTabViewItem *)tabViewItem {
//    NSWindow* const window = NSApp.keyWindow;
//    if (window == nil) {
//        return NO;
//    }
    return YES;
}

- (void)tabView:(NSTabView *)aTabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem {
//    NSLog(@"didCloseTabViewItem: %@", tabViewItem.label);
}

- (void)tabView:(NSTabView *)aTabView didMoveTabViewItem:(NSTabViewItem *)tabViewItem toIndex:(NSUInteger)index
{
    NSLog(@"tab view did move tab view item %@ to index:%ld",tabViewItem.label,index);
}

- (void)addNewTabToTabView:(NSTabView *)aTabView {
    [self addNewTab:aTabView];
}

- (NSArray<NSPasteboardType> *)allowedDraggedTypesForTabView:(NSTabView *)aTabView {
    return @[NSFilenamesPboardType, NSPasteboardTypeString];
}

- (BOOL)tabView:(NSTabView *)aTabView acceptedDraggingInfo:(id <NSDraggingInfo>)draggingInfo onTabViewItem:(NSTabViewItem *)tabViewItem {
    NSPasteboardType const pasteboardType = draggingInfo.draggingPasteboard.types[0];
    if (pasteboardType == nil) {
        return NO;
    }
    NSLog(@"acceptedDraggingInfo: %@ onTabViewItem: %@", [draggingInfo.draggingPasteboard stringForType:pasteboardType], tabViewItem.label);
    return YES;
}

- (NSMenu *)tabView:(NSTabView *)aTabView menuForTabViewItem:(NSTabViewItem *)tabViewItem {
    NSLog(@"menuForTabViewItem: %@", tabViewItem.label);
    return nil;
}

- (BOOL)tabView:(NSTabView *)aTabView shouldAllowTabViewItem:(NSTabViewItem *)tabViewItem toLeaveTabBarView:(MMTabBarView *)tabBarView {
    return YES;
}

- (BOOL)tabView:(NSTabView*)aTabView shouldDragTabViewItem:(NSTabViewItem *)tabViewItem inTabBarView:(MMTabBarView *)tabBarView {
    return YES;
}

- (NSDragOperation)tabView:(NSTabView*)aTabView validateDrop:(id<NSDraggingInfo>)sender proposedItem:(NSTabViewItem *)tabViewItem proposedIndex:(NSUInteger)proposedIndex inTabBarView:(MMTabBarView *)tabBarView {
    
    return NSDragOperationMove;
}

- (NSDragOperation)tabView:(NSTabView *)aTabView validateSlideOfProposedItem:(NSTabViewItem *)tabViewItem proposedIndex:(NSUInteger)proposedIndex inTabBarView:(MMTabBarView *)tabBarView {
    return NSDragOperationMove;
}

- (void)tabView:(NSTabView*)aTabView didDropTabViewItem:(NSTabViewItem *)tabViewItem inTabBarView:(MMTabBarView *)tabBarView {
    NSLog(@"didDropTabViewItem: %@ inTabBarView: %@", tabViewItem.label, tabBarView);
}

- (void)tabView:(NSTabView *)aTabView closeWindowForLastTabViewItem:(NSTabViewItem *)tabViewItem {
    NSLog(@"closeWindowForLastTabViewItem: %@", tabViewItem.label);
//    [self.window close];
}

- (void)tabView:(NSTabView *)aTabView tabBarViewDidHide:(MMTabBarView *)tabBarView {
    NSLog(@"tabBarViewDidHide: %@", tabBarView);
}

- (void)tabView:(NSTabView *)aTabView tabBarViewDidUnhide:(MMTabBarView *)tabBarView {
    NSLog(@"tabBarViewDidUnhide: %@", tabBarView);
}

- (NSString *)tabView:(NSTabView *)aTabView toolTipForTabViewItem:(NSTabViewItem *)tabViewItem {
    return tabViewItem.label;
}

- (NSString *)accessibilityStringForTabView:(NSTabView *)aTabView objectCount:(NSInteger)objectCount {
    return (objectCount == 1) ? @"item" : @"items";
}

- (void)dealloc
{
    [super dealloc];
}

@end
