//
//  TabBarItem.h
//  MainUI
//
//  Created by Henry on 2021/1/25.
//  Copyright © 2021 Henry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MMTabBarView/MMTabBarView.h>

NS_ASSUME_NONNULL_BEGIN

@interface TabBarItem : NSObject <MMTabBarItem>

@property (copy)   NSString *title;
@property (strong) NSImage  *largeImage;
@property (strong) NSImage  *icon;
@property (strong) NSString *iconName;

@property (assign) BOOL      isProcessing;
@property (assign) NSInteger objectCount;
@property (strong) NSColor   *objectCountColor;
@property (assign) BOOL      showObjectCount;
@property (assign) BOOL      isEdited;
@property (assign) BOOL      hasCloseButton;

// designated initializer
- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
