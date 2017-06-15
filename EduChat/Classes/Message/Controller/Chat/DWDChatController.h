//
//  DWDChatController.h
//  EduChat
//
//  Created by apple on 11/5/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWDClassModel.h"
#import "DWDGroupEntity.h"
#import "DWDChatAddFileContainer.h"

@class DWDRecentChatModel;

@interface DWDChatController : UIViewController
@property (assign, nonatomic) DWDChatType chatType;

@property (strong, nonatomic) NSNumber *toUserId;

@property (nonatomic , strong) DWDRecentChatModel *recentChatModel;
@property (nonatomic , strong) DWDClassModel *myClass;
@property (nonatomic , strong) DWDGroupEntity *groupEntity;

@property (nonatomic, assign) BOOL lastVCisClassInfoVC; //标记是否从班级信息进入聊天界面

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewToBottom;

//add file views
@property (weak, nonatomic) IBOutlet DWDChatAddFileContainer *addFileContainerView;

@end
