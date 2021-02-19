//
//  logManager.h
//  MainUI
//
//  Created by Henry on 2021/2/1.
//  Copyright © 2021 Henry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "logHandler.h"
#import "logTypeController.h"

NS_ASSUME_NONNULL_BEGIN

@interface logManager : NSObject{

@public
     NSMutableDictionary *logDetailHandlerDic;
     NSMutableDictionary *logSelectHandlerDic;
}
- (instancetype)initWithZipPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
