//
//  DWDInfoSubsExpertCell.h
//  EduChat
//
//  Created by Catskiy on 16/8/11.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "YGCommonCell.h"
#import "DWDInfoExpertModel.h"

@interface DWDInfoSubsExpertCell : YGCommonCell

@property (nonatomic, copy) NSArray *experts;
@property (nonatomic, copy) void(^subsExpertCellBlock)(NSNumber *expertId);

+ (CGFloat)getHeight;
- (void)addOneExpert:(DWDInfoExpertModel *)expert;

@end


@interface DWDInfoExpertAvatarView : UIView

@property (nonatomic ,strong) DWDInfoExpertModel *expert;
@property (nonatomic, copy) void(^subsExpertViewBlock)(NSNumber *expertId);

@end