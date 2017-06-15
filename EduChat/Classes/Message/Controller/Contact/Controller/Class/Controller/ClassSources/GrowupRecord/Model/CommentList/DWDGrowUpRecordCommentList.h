//
//  DWDGrowUpRecordCommentList.h
//  EduChat
//
//  Created by Superman on 16/1/6.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDGrowUpRecordCommentList : NSObject
@property (nonatomic , copy) NSString *addtime;
@property (nonatomic , strong) NSNumber *commentId;
@property (nonatomic , copy) NSString *commentTxt;
@property (nonatomic , strong) NSNumber *custId;
@property (nonatomic , strong) NSNumber *forCustId;
@property (nonatomic , copy) NSString *forNickname;
@property (nonatomic , copy) NSString *nickname;
@property (nonatomic , copy) NSString *photokey;

@property (nonatomic , assign) CGFloat cellHeight;

@property (nonatomic , assign) CGRect iconViewF;
@property (nonatomic , assign) CGRect nameLabelF;
@property (nonatomic , assign) CGRect pictureF;
@property (nonatomic , assign) CGRect bodyLabelF;
@property (nonatomic , assign) CGRect dateLabelF;

@end
