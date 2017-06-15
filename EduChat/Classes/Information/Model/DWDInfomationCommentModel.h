//
//  DWDInfomationCommentModel.h
//  EduChat
//
//  Created by KKK on 16/5/22.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDInfomationCommentModel : NSObject

@property (nonatomic, copy) NSString *addtime;
@property (nonatomic, strong) NSNumber *commentId;
@property (nonatomic, copy) NSString *commentTxt;
@property (nonatomic, strong) NSNumber *custId;
@property (nonatomic, strong) NSNumber *forCustId;
@property (nonatomic, strong) NSNumber *forCommentId; //被评论的评论
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *forNickname;
@property (nonatomic, strong) DWDPhotoMetaModel *photohead;
@property (nonatomic, copy) NSString *photoKey;

//@property (nonatomic, assign) CGFloat cellHeight;
- (CGFloat)cellHeight;
@end


