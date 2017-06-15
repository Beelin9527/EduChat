//
//  Macros.h
//  EduChat
//
//  Created by Gatlin on 16/2/19.
//  Copyright © 2016年 dwd. All rights reserved.
//  宏

#pragma mark Frame
/** 屏幕宽高 */
#define DWDScreenW [UIScreen mainScreen].bounds.size.width
#define DWDScreenH [UIScreen mainScreen].bounds.size.height
#define DWDToolBarHeight 49          //Tabar高度
#define DWDTopHight 64               //导航样高度
#define DWDLineH 0.7                 //线条高度或宽度
#define DWDPadding 10                //间隙
#define DWDPaddingMax 15


#pragma mark - 设备机型
//#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
//#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
//  ====================立超区域================================
// 多维度屏幕适配 (根据iPhone6的像素算出各屏幕对应的尺寸)   
#define pxToW(k) (([UIScreen mainScreen].bounds.size.width == 375 && [UIScreen mainScreen].bounds.size.height == 667) || ([UIScreen mainScreen].bounds.size.width == 320 && [UIScreen mainScreen].bounds.size.height == 480) || ( [UIScreen mainScreen].bounds.size.width == 320 && [UIScreen mainScreen].bounds.size.height == 568) ? (k)/750.0 * DWDScreenW : ((k)/750.0*1242.0) / 1242.0 * 414)
#define pxToH(n) ([UIScreen mainScreen].bounds.size.width == 414 && [UIScreen mainScreen].bounds.size.height == 736 ? ((n)/1334.0*2208.0) / 2208.0 * 736 : (n)/1334.0 * DWDScreenH)

// 系统版本
#define IOS_SYSTEM_STRING [[UIDevice currentDevice] systemVersion]

//判断 iOS 8 或更高的系统版本  ([[UIDevice currentDevice] systemVersion] 浮点计算会丢精度 [[UIDevice currentDevice] systemVersion] 字符串比较靠谱)
#define IOS_VERSION_8_OR_LATER (([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0)? (YES):(NO))


#pragma mark Color
/**  设置颜色 */
#define DWDColorMain DWDRGBColor(90,136, 231)                   //主调色
#define DWDColorBackgroud DWDRGBColor(245,245, 245)             //背景色
#define DWDColorSeparator DWDRGBColor(221,221, 221)             //分割线色

#define DWDColorBody DWDRGBColor(43,43, 43)                     //正常文本色
#define DWDColorContent DWDRGBColor(102,102, 102)               //内容文本色
#define DWDColorSecondary DWDRGBColor(153,153, 153)             //次要辅助色
#define DWDColorHighlight DWDRGBColor(60,93, 161)               //按钮高亮色


#define DWDRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]// RGB色
#define DWDRGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]// RGB色
#define DWDRandomColor DWDRGBColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))// 随机色
#define UIColorFromRGB(rgbValue) UIColorFromRGBWithAlpha(rgbValue, 1.0f)
#define UIColorFromRGBWithAlpha(rgbValue, alpha1) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alpha1]//十六进制转RGB色



#pragma mark Font
/**  设置字体大小 */
#define DWDFontBody [UIFont systemFontOfSize:16]            //文章标题、输入文字
#define DWDFontContent [UIFont systemFontOfSize:14]         //一般字号，文章正文
#define DWDFontMin [UIFont systemFontOfSize:12]             //注释文字，解释说明


#pragma mark Use Class
/** 常用类 */
#import "HttpClient.h"          //网络请求类
#import "DWDWebManager.h"
#import "DWDCustInfo.h"         //个人信息模型类
#import "DWDPersonDataBiz.h"    //用户信息逻辑处理
/** 常用分类 */
#import "UIView+Extension.h"    
#import "NSString+extend.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Utils.h"
/** 常用第三方类 */
#import <MBProgressHUD/MBProgressHUD.h> //网络请求提示框  菊花拉
#import "DWDProgressHUD.h"              //自家封了MBProgressHUD 的提示框
#import "DWDAliyunManager.h"            // 上传下载图片文件
/*   DatabaseQueue   */
#import "DWDDataBaseHelper.h"           //全局数据库队列
/*
 全局图片模型
 **/
#import "DWDPhotoMetaModel.h"
/*
 *  权限控制
 **/
#import "DWDPrivacyManager.h"


#pragma mark Othor

/** 本地数据库路径 */
#define DWDDatabasePath [[NSHomeDirectory() stringByAppendingString:@"/Documents/"] stringByAppendingString:[[NSString stringWithFormat:@"%llu",[[DWDCustInfo shared].custId unsignedLongLongValue]] stringByAppendingString:@".sqlite"]]

/** 生成UUID */
#define DWDUUID [NSUUID UUID].UUIDString

/** 自动布局 */
#define MAS_SHORTHAND

/** 弱引用 self */
#define WEAKSELF __weak typeof(self) weakSelf = self

/** 默认图片  头像*/
#define DWDDefault_GroupImage [UIImage imageNamed:@"MSG_Group_HP"]     //群组头像
#define DWDDefault_GradeImage [UIImage imageNamed:@"MSG_Class_HP"]      //班级头像
#define DWDDefault_MeBoyImage [UIImage imageNamed:@"ME_User_HP_Boy"]    //联系人头像
#define DWDDefault_MeGrilImage [UIImage imageNamed:@"ME_User_HP_Girl"]

#define DWDDefault_infoPhotoImage [UIImage imageNamed:@"small"]     //资讯 图片默认底图
#define DWDDefault_infoVideoImage [UIImage imageNamed:@"big"]   //资讯 视频默认底图
//KKK部分
#ifdef DEBUG
#define DWDMarkLog(...) DWDLog(@"##############################"); \
                        DWDLog(__VA_ARGS__); \
                        DWDLog(@"------------------------------");
#else
#define DWDMarkLog(...)
#endif
