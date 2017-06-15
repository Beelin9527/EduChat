//
//  DWDPersonerDataEntity.h
//  EduChat
//
//  Created by Gatlin on 16/3/7.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWDPhotoMetaModel.h"

@interface DWDPersonerDataEntity : NSObject
//用户个人信息
@property (strong, nonatomic) NSNumber *custId;         //用户ID
@property (strong, nonatomic) NSNumber *friendId;       //好友ID

@property (copy, nonatomic) NSString *nickname;         //用户昵称
@property (copy, nonatomic) NSString *name;             //用户姓名
@property (copy, nonatomic) NSString *educhatAccount;   //多维度号

@property (copy, nonatomic) NSString *photoKey;         //头像Key
@property (strong, nonatomic) DWDPhotoMetaModel *photohead;  //头像模型

@property (strong, nonatomic) NSString *mobile;         //手机号
@property (strong, nonatomic) NSNumber *custType;       //用户身份  int	客户类别:1-教育管理机构 2-学校，含公办民办 3-培训结构 4-教师号 5-家长号 6-学生号 7-班级 8-群组 9-平台管理员

@property (strong, nonatomic) NSNumber *gender;         //性别
@property (strong, nonatomic) NSNumber *education;      //学历 0-学前1-幼儿园2-小学3-初中4-高中5-中专6-专科7-本科8-硕士9-博士10-博士后
@property (copy, nonatomic) NSString *regionName;       //区域名称
@property (copy, nonatomic) NSString *signature;        //个性签名
@property (copy, nonatomic) NSString *birthday;         //生日

@property(strong, nonatomic) NSNumber *isFriend;        //是否为好友

@end







