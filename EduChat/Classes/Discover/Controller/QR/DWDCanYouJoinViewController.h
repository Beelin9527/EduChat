//
//  DWDCanYouJoinViewController.h
//  EduChat
//
//  Created by Gatlin on 16/2/17.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DWDSacnResultType) {
    DWDSacnResultTypeApply,DWDSacnResultTypeJionChat
};
@interface DWDCanYouJoinViewController : UIViewController


@property (nonatomic, assign) DWDSacnResultType type;
@property (strong, nonatomic) NSDictionary *dictDataSource;
@end


/*  群组 非群成员返回信息   一直不喜欢用字典来接，好吧，让这样吧
 custId = 4010000005476;
 friendType = 2;
 groupId = 7010000001103;
 groupName = Hao;
 isFriend = 0;
 memberNum = 2;
*/


