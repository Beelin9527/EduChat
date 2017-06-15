//
//  DWDLeavePaperCell.h
//  EduChat
//
//  Created by apple on 15/12/8.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_OPTIONS(NSUInteger, DWDLeavePaperCellType) {
   DWDLeavePaperCellTypeNotApprove, DWDLeavePaperCellTypeApprove
};
@class DWDAuthorEntity,DWDNoteEntity;
@interface DWDLeavePaperCell : UITableViewCell

@property (strong, nonatomic) DWDAuthorEntity *authorEntity;
@property (strong, nonatomic) DWDNoteEntity *noteEntity;

@property (assign, nonatomic) DWDLeavePaperCellType type;
//+(instancetype)leavePaperCell;
@end
