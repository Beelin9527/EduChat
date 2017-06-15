//
//  DWDGroupInfoModel.h
//  EduChat
//
//  Created by Gatlin on 15/12/21.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,DWDGroupType) {
    DWDGroupTypeNone,DWDGroupTypeDetailTitle,DWDGroupTypeImg,DWDGroupTypeSwitch,DWDGroupTypeIndicator
};

//typedef void(^action)(void) ;
@interface DWDGroupInfoModel : NSObject
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *detailTitle;
@property (copy, nonatomic) NSString *imgName;
@property (assign, nonatomic) DWDGroupType type;
@property (assign, nonatomic) BOOL isOpen;
@property (strong,nonatomic) void(^action)();
@end
