//
//  DWDHomeWorkCompletenessCell.h
//  EduChat
//
//  Created by apple on 12/30/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDHomeWorkCompletenessCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *countLabel;

@property (strong, nonatomic) NSArray *peoples;

- (CGFloat)getHeight;

@end
