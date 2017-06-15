//
//  DWDContactModel.h
//  EduChat
//
//  Created by Gatlin on 16/3/23.
//  Copyright © 2016年 dwd. All rights reserved.
//  联系人 Model

#import <Foundation/Foundation.h>

@class DWDPhotoMetaModel;
@interface DWDContactModel : NSObject

@property (nonatomic , strong) NSNumber *custId;
@property (nonatomic , copy) NSString *photoKey;
@property (nonatomic , copy) NSString *nickname;
@property (nonatomic , copy) NSString *remarkName;
@property (nonatomic , strong) NSNumber *isFriend;
@property (nonatomic , strong) NSNumber *status;
@property (nonatomic , strong) NSNumber *custType;
@property (nonatomic, strong) DWDPhotoMetaModel *photohead;

@property (nonatomic , assign) BOOL selected;

@property (nonatomic , assign) DWDChatType chatType;


@end
