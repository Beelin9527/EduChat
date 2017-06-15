//
//  DWDArticleFrameModel.h
//  EduChat
//
//  Created by Beelin on 16/11/10.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DWDArticleModel;
@interface DWDArticleFrameModel : NSObject
@property (nonatomic, assign, readonly) CGRect nicknameFrame; //来源
@property (nonatomic, assign, readonly) CGRect titleFrame; //标题
@property (nonatomic, assign, readonly) CGRect readIconFrame; //阅读icon
@property (nonatomic, assign, readonly) CGRect readcntFrame; //阅读数
@property (nonatomic, assign, readonly) CGRect timeFrame; //发布时间

@property (nonatomic, assign, readonly) CGRect photo1Frame; //图片
@property (nonatomic, assign, readonly) CGRect photo2Frame; //
@property (nonatomic, assign, readonly) CGRect photo3Frame; //

@property (nonatomic, assign, readonly) CGRect videoIconFrame; //视频icon
@property (nonatomic, assign, readonly) CGRect videoTimeFrame; //视频时长

@property (nonatomic, assign, readonly) CGFloat cellHeight; //

@property (nonatomic, strong) DWDArticleModel *articleModel;
@end
