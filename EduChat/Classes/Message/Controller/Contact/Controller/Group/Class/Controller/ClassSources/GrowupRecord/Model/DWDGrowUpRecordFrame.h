//
//  DWDGrowUpRecordFrame.h
//  EduChat
//
//  Created by Superman on 16/1/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DWDGrowUpRecordModel;

@interface DWDGrowUpRecordFrame : NSObject
@property (nonatomic , strong) DWDGrowUpRecordModel *growupModel;
@property (nonatomic , assign) CGRect iconViewF;
@property (nonatomic , assign) CGRect nameLabelF;
@property (nonatomic , assign) CGRect dateLabelF;
@property (nonatomic , assign) CGRect midLittleImageF;
//缩略内容
@property (nonatomic , assign) CGRect bodyLabelF;
//完整内容按钮(点击全文)
@property (nonatomic , assign) CGRect allBodyBtnF;


@property (nonatomic , assign) CGRect commentBtnF;

@property (nonatomic , assign) CGRect commentContainerF;

@property (nonatomic , assign) CGRect flowerViewF;
@property (nonatomic , assign) CGRect zanPeopleF;
@property (nonatomic , strong) NSMutableArray *commentsFrames;
//全部图片
@property (nonatomic , strong) NSMutableArray *picturesFrames;

@property (nonatomic , assign) CGRect extendBtnF;

@property (nonatomic , assign) CGFloat cellHeight;

@property (nonatomic , copy) void(^reCountFrames)(NSArray *arr);

@end
