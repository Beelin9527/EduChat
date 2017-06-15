//
//  DWDHomeWorkDetailCell.h
//  EduChat
//
//  Created by apple on 12/30/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface DWDHomeWorkDetailCell : UITableViewCell

@property (strong, nonatomic) UILabel *contentTitleLabel;
@property (strong, nonatomic) UILabel *deadlineTitleLabel;
@property (strong, nonatomic) UILabel *fromTitleLabel;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subjectLabel;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) TTTAttributedLabel *contentLabel;
@property (strong, nonatomic) UILabel *deadlineLabel;
@property (strong, nonatomic) TTTAttributedLabel *fromLabel;

@property (strong, nonatomic) NSArray *attachmentPaths;
- (CGFloat)getHeight;
@end
