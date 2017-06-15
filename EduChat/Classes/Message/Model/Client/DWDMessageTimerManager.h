//
//  DWDMessageTimerManager.h
//  EduChat
//
//  Created by Superman on 16/4/26.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDMessageTimerManager : NSObject
DWDSingletonH(MessageTimerManager)

@property (nonatomic , strong) NSMutableDictionary *timerCachDict;

- (void)judgeSendingError:(NSTimer *)timer;
@end
