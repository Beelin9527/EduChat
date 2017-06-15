//
//  DWDContactHeaderCell.h
//  EduChat
//
//  Created by apple on 12/8/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDContactHeaderCell;

@protocol DWDContactHeaderCellDelegate <NSObject>

@required
- (void)contactHeaderCellDidShowNewFriendsWithTitle:(NSString *)title;
- (void)contactHeaderCellDidShowGroupsWithTitle:(NSString *)title;
- (void)contactHeaderCellDidShowClassesWithTitle:(NSString *)title;

@end

@interface DWDContactHeaderCell : UIView

@property (weak, nonatomic) id<DWDContactHeaderCellDelegate> actionDelegate;
@property (nonatomic , strong) UILabel *badgeLabel;
@end
