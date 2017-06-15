//
//  DWDExpertListCell.h
//  EduChat
//
//  Created by Catskiy on 16/8/10.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWDInfoExpertModel.h"
#import "YGCommonCell.h"

#define ExpertCellHeight 100.0

@protocol DWDInfoExpertCellDelegate <NSObject>

- (void)expertCellDidClickedSubscribeButton:(UIButton *)button WithExpert:(DWDInfoExpertModel *)expert;

@end

typedef NS_ENUM(NSUInteger, ExpertListCellStyle) {
    ExpertListCellStyleNomal,
    ExpertListCellStyleSubsc,
};

@interface DWDExpertListCell : UITableViewCell

@property (nonatomic, weak) id<DWDInfoExpertCellDelegate> delegate;
@property (nonatomic, assign) ExpertListCellStyle style;
@property (nonatomic, assign) DWDInfoExpertModel *model;
@property (nonatomic, assign) BOOL isSub;
@property (nonatomic, copy) void(^subscribeBlock)(NSNumber *expertId);

@end
