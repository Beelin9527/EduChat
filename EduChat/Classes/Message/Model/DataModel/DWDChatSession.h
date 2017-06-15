//
//  DWDChatSession.h
//  EduChat
//
//  Created by apple on 1/8/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDChatSession : NSObject

@property (strong, nonatomic) NSNumber *chatId;
@property (strong, nonatomic) NSNumber *myCustId;

@property (strong, nonatomic) NSNumber *interlocutorId;
@property (copy, nonatomic) NSString *avatar;
@property (copy, nonatomic) NSString *title;


@property (strong, nonatomic) NSNumber *unreadCount;

@property (strong, nonatomic) NSNumber *lastUpdateTime;

@property (copy, nonatomic) NSString *digest;
@property (copy, nonatomic) NSString *state;
@end
