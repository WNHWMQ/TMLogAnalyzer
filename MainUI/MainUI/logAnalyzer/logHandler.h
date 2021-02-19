//
//  logHandler.h
//  MainUI
//
//  Created by Henry on 2021/1/28.
//  Copyright © 2021 Henry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "logTypeController.h"
#import "SequenceGroup.h"
#import "TimeTamp.h"

NS_ASSUME_NONNULL_BEGIN

@interface logHandler : NSObject{
    NSFileManager *fileManager;
    int msPrecisionLength;
    NSMutableArray *data;
    
@public
    NSString *filePath;
    NSString *fileName;
    NSString *fileContent;
    NSString *logType;
    NSString *timeTampType;
}

//@property (nonatomic,strong) NSString *filePath;
//@property (nonatomic,strong) NSString *fileName;
//@property (nonatomic,strong) NSString *fileContent;
//@property (nonatomic,strong) NSString *logType;
//@property (nonatomic,strong) NSString *timeTampType;

- (NSMutableArray *)data;
- (instancetype)initWithFilePath:(NSString *)path andTypeController:(logTypeController *)typeController;
- (NSString *)getSubString:(NSArray *)arr;

@end

NS_ASSUME_NONNULL_END
