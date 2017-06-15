//
//  DWDPickUpCenterParentDataBaseModel.h
//  EduChat
//
//  Created by KKK on 16/3/17.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDPickUpCenterParentDataBaseModel : NSObject

/*
 //            "custId":,				//家长id
 //            "name":"",				//家长姓名
 //            "photokey":""},			//家长头像
 */
@property (nonatomic, strong) NSNumber *custId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *photokey;

@end
