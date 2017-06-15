//
//  DWDContactListCell.h
//  EduChat
//
//  Created by Gatlin on 16/2/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDContactListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headerImv;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (strong, nonatomic) UIImageView *roleIcon;
@end
