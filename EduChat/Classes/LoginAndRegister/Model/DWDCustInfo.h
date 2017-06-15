//
//  DWDUser.h
//  EduChat
//
//  Created by Gatlin on 15/12/7.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWDPhotoMetaModel.h"

@interface DWDCustInfo : NSObject

//用户个人信息
@property (strong, nonatomic) NSNumber *custId;             //用户ID
@property (copy, nonatomic) NSString *custUserName;         //登录帐号
@property (copy, nonatomic) NSString *custOrignPwd;         //原始密码
@property (copy, nonatomic) NSString *custMD5Pwd;           //用户Md5密码
@property (nonatomic, copy) NSString *custEncryptPwd;       //加密密码


@property (copy, nonatomic) NSString *custNickname;         //用户昵称
@property (copy, nonatomic) NSString *custName;             //用户姓名
@property (copy, nonatomic) NSString *custEduchatAccount;   //多维度号

@property (nonatomic, strong) DWDPhotoMetaModel *photoMetaModel; //头像模型 建议用这个 下面三个需要重构
@property (copy, nonatomic) NSString *custPhotoKey;         //头像Key
@property (copy, nonatomic) NSString *custThumbPhotoKey;    //缩略图头像Key
@property (copy, nonatomic) NSString *custOrignPhotoKey;    //原头像Key

@property (strong, nonatomic) NSString *custMobile;         //手机号
@property (strong, nonatomic) NSNumber *custIdentity;       //用户身份  1.  2.  3.  4.老师.  5.  6.家长
@property (strong, nonatomic) NSString *custGender;         //性别
@property (copy, nonatomic) NSString *custRegionName;       //地区名
@property (copy, nonatomic) NSString *custSignature;        //个性签名
@property (copy, nonatomic) NSString *custBirthday;         //生日
@property (copy, nonatomic) NSString *regionCode;           //区域编码

@property (copy, nonatomic) NSString *registrationID;       //JPush ID

/** 家长持有参数 */
@property (copy, nonatomic) NSString *custMyChildName;      //我的孩子姓名

//  aliyun
@property (copy, nonatomic) NSString *AccessKey;
@property (copy, nonatomic) NSString *SecretKey;
@property (copy, nonatomic) NSString *ossUrl;

@property (nonatomic, strong, readonly) NSNumber *systemCustId;


@property (getter=isTeacher, nonatomic ,readonly) BOOL teacher;    //全局判断用户是否为老师
/*
 *  登录状态  NO 未登录   YES 已登录
*/
@property (getter=isLogin, nonatomic) BOOL loginState;

/** 是否被迫下线 */
@property (assign, nonatomic) BOOL forceOffLine;

+(instancetype)shared;

/*
 *  加载用户信息
 */
- (void)loadUserInfoData;

/*
 *  清除用户信息
 */
- (void)clearUserInfoData;

/*
 *  请求
 */
- (void)requestUserInfoExWithCustId:(NSNumber *)custId success:(void(^)(void))succes failure:(void(^)(void))failure;
@end
/*
 参数	类型	说明
 educhatAccount	String	多维度号
 name	String	姓名
 mobile	String	手机号
 nickname	String	昵称
 gender	int	性别
 1-男
 2-女
 education	int	学历
 0-学前
 1-幼儿园
 2-小学
 3-初中
 4-高中
 5-中专
 6-专科
 7-本科
 8-硕士
 9-博士
 10-博士后
 nationality	String	民族
 property	int	职业性质
 regionCode	String	区域代码
 regionName	String	区域名称
 photoKey	String	个人头像
 signature	String	个性签名
 level	int	客户级别
 1-注册
 2-铜牌
 3-银牌
 4-金牌
 5-钻石
 status	int	客户状态
 1-未激活
 2-正常
 3-冻结
 4-注销
 5-黑名单
 birthday	String	生日.格式YYYY-MM-DD
 extensions=all时返回
 enterpriseId	long	所在机构ID
 extensions=all时返回
 enterpriseName	String	所在机构名称
 extensions=all时返回
 email	String	电子邮箱
 extensions=all时返回
 qq	String	QQ号码
 extensions=all时返回
 weixin	String	微信号
 extensions=all时返回
 
 */
