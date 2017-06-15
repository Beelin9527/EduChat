//
//  DWDTempContactModel.h
//  EduChat
//
//  Created by KKK on 16/12/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDTempContactModel : NSObject

//return: {
//    "friendNickname":"dwd_137****7777",
//    "createTime":1479366824953,
//    "photoKey":"",
//    "friendCustId":4010000005225,
//    "custId":4010000005226,
//    "nickname":"dwd_136****6666",
//    "source":2,
//    "photohead":{
//        "size":0,
//        "photoKey":"",
//        "width":0,
//        "height":0
//    },
//    "isFriend":false
//}

@property (nonatomic, copy) NSString *friendNickname;
@property (nonatomic, strong) NSNumber *createTime;
@property (nonatomic, copy) NSString *photoKey;
@property (nonatomic, strong) NSNumber *friendCustId;
@property (nonatomic, strong) NSNumber *custId;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, strong) NSNumber *source;
@property (nonatomic, strong) DWDPhotoMetaModel *photohead;
@property (nonatomic, strong) NSNumber *isFriend;

@end
