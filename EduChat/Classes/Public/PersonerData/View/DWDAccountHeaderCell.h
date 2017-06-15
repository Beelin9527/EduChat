//
//  DWDAccountHeaderCell.h
//  EduChat
//
//  Created by apple on 12/10/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, DWDAccountShowType) {
    DWDAccountShowTypeTeacher,
    DWDAccountShowTypeParent,
    DWDAccountShowTypeStudent,
};

typedef NS_ENUM(NSInteger, DWDAccountShowGenderType) {
    DWDAccountShowGenderTypeNone,
    DWDAccountShowGenderTypeMale,
    DWDAccountShowGenderTypeFemale,
};
@class DWDPersonerDataEntity;  //用户信息 实体类
@class DWDCustomUserInfoEntity;//对用户设置权限 实体类
@interface DWDAccountHeaderCell : UITableViewCell

@property (nonatomic) DWDAccountShowType showType;

@property (nonatomic) DWDAccountShowGenderType genderType;


@property (strong, nonatomic) IBOutlet UIImageView *avatarView;

@property (weak, nonatomic) IBOutlet UIImageView *genderImv;

@property (strong, nonatomic) IBOutlet UILabel *typeLab;

@property (weak, nonatomic) IBOutlet UILabel *eduAccountLab;

@property (strong, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (weak, nonatomic) IBOutlet UILabel *remarkNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *regionLabel;

@property (strong, nonatomic) IBOutlet UILabel *signatureLabel;

@property (strong, nonatomic) DWDPersonerDataEntity *personerDataEntity; //用户信息 实体类
@property (strong, nonatomic) DWDCustomUserInfoEntity *customUserInfoEntity; //用户信息 实体类

@property (nonatomic, copy) void(^clickAvatarBlock)(UIImageView *imv);
@end
