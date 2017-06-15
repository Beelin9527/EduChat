//
//  DWDHomeWorkCell.m
//  EduChat
//
//  Created by apple on 12/28/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDHomeWorkCell.h"

@interface DWDHomeWorkCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editLeading;
@property (weak, nonatomic) IBOutlet UIImageView *editImgView;


@end

@implementation DWDHomeWorkCell

- (void)layoutSubviews {
    
    if (self.editing) {
        self.iconViewLeading.constant = 42;
        self.editLeading.constant = 20;
    } else {
        self.iconViewLeading.constant = 22;
        self.editLeading.constant = -20;
    }
    if (self.isMultiSelected) {
        self.editImgView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_selected"];
    } else {
        self.editImgView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_normal"];
    }
}

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.editImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.editImgView addGestureRecognizer:tap];
}

- (UIEdgeInsets)separatorInset {
    return UIEdgeInsetsZero;
}

- (void)tap:(UITapGestureRecognizer *)sender {
    if (!self.indexPath) {
        DWDLog(@"you must set indexPath a non nil value when use it!!!");
    }
    
    if (!self.isMultiSelected && self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(homeWorkCellDidMultiSelectAtIndexPath:)]) {
        self.isMultiSelected = YES;
        self.editImgView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_selected"];
        [self.actionDelegate homeWorkCellDidMultiSelectAtIndexPath:self.indexPath];
    }
    
    else if (self.isMultiSelected && self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(homeWorkCellDidMultiDisselectAtIndexPath:)]) {
        self.isMultiSelected = NO;
        self.editImgView.image = [UIImage imageNamed:@"btn_point_marquee_select_contacts_normal"];
        [self.actionDelegate homeWorkCellDidMultiDisselectAtIndexPath:self.indexPath];
    }

}
@end
