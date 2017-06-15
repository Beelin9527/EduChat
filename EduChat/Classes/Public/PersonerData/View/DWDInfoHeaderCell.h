//
//  DWDInfoHeaderCell.h
//  EduChat
//
//  Created by apple on 16/4/21.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDInfoHeaderCell : UITableViewCell

@property (nonatomic, strong) NSString *avatarImg;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, copy) void(^addContactBlock)(void);

@end
