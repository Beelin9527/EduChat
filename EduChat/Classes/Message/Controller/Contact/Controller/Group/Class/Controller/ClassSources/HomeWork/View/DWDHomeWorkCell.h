//
//  DWDHomeWorkCell.h
//  EduChat
//
//  Created by apple on 12/28/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWDHomeWorkCellDelegate <NSObject>

@required
- (void)homeWorkCellDidMultiSelectAtIndexPath:(NSIndexPath *)indexPath;
- (void)homeWorkCellDidMultiDisselectAtIndexPath:(NSIndexPath *)indexPath;

@end
@interface DWDHomeWorkCell : UITableViewCell

@property (weak, nonatomic) id<DWDHomeWorkCellDelegate> actionDelegate;

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *homeWorkLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeWorkSubjectLabel;

@property (nonatomic) BOOL isMultiSelected;
@property (strong, nonatomic) NSIndexPath *indexPath;
@end
