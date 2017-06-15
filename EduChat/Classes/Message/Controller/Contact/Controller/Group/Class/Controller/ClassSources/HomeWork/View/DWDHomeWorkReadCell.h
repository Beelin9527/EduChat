//
//  DWDHomeWorkReadCell.h
//  EduChat
//
//  Created by apple on 16/4/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDHomeWorkReadCell : UITableViewCell

@property (nonatomic, strong) NSArray *peoples;
@property (nonatomic, strong) void(^HomeWorkReadCellBlock)(NSNumber *custId);

- (CGFloat)getHeight;

@end
