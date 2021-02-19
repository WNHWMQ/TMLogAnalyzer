//
//  TabBarItem.m
//  MainUI
//
//  Created by Henry on 2021/1/25.
//  Copyright © 2021 Henry. All rights reserved.
//

#import "TabBarItem.h"

@implementation TabBarItem

- (instancetype)init {
    if ((self = [super init]) != nil) {
        _isProcessing = NO;
        _icon = nil;
        _iconName = nil;
        _largeImage = nil;
        _objectCount = 0;
        _isEdited = NO;
        _hasCloseButton = YES;
        _title = @"Untitled";
        _objectCountColor = nil;
        _showObjectCount = NO;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
