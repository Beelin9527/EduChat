//
//  DWDLeavePaperCellGroup.h
//  EduChat
//
//  Created by KKK on 16/5/13.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDLeavePaperDetailModel;

@interface DWDLeavePaperCellGroup : UITableViewCell
@end

@interface DWDLeavePaperHeadCell : UITableViewCell
@property (nonatomic, strong) DWDLeavePaperDetailModel *model;
@end

@interface DWDLeavePaperVacateCell : UITableViewCell
@property (nonatomic, strong) DWDLeavePaperDetailModel *model;
@end

@interface DWDLeavePaperCheckCell : UITableViewCell
@property (nonatomic, strong) DWDLeavePaperDetailModel *model;
@end

@interface DWDLeavePaperRefuseCell : UITableViewCell
@property (nonatomic, strong) DWDLeavePaperDetailModel *model;
@end

@interface DWDLeavePaperNotCheckCell : UITableViewCell
@property (nonatomic, strong) DWDLeavePaperDetailModel *model;
@end

@class DWDLeavePaperAproveCell;
@protocol DWDLeavePaperAproveCellDelegate <NSObject>
@optional
//点击同意按钮
- (void)aproveCellDidClickAgreeButton:(DWDLeavePaperAproveCell *)cell;
//点击拒绝(不同意)按钮
- (void)aproveCellDidClickRefuseButton:(DWDLeavePaperAproveCell *)cell;
@end
@interface DWDLeavePaperAproveCell : UITableViewCell
@property (nonatomic, strong) DWDLeavePaperDetailModel *model;
@property (nonatomic, weak) id<DWDLeavePaperAproveCellDelegate> delegate;
@end

@class DWDLeavePaperTeacherRefuseCell;
@protocol DWDLeavePaperTeacherRefuseCellDelegate <NSObject>
@required
- (void)teacherRefuseCell:(DWDLeavePaperTeacherRefuseCell *)cell didChangeText:(NSString *)text;
@end

@interface DWDLeavePaperTeacherRefuseCell : UITableViewCell
@property (nonatomic, strong) DWDLeavePaperDetailModel *model;
@property (nonatomic, weak) id<DWDLeavePaperTeacherRefuseCellDelegate> delegate;
@end


