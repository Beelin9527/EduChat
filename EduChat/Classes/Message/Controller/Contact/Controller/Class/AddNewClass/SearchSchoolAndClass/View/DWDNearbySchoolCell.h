//
//  DWDNearbySchoolCell.h
//  EduChat
//
//  Created by Superman on 15/12/17.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDNearbySchoolModel;
@interface DWDNearbySchoolCell : UITableViewCell

@property (nonatomic , weak) UILabel *schoolName;
@property (nonatomic , weak) UILabel *addressName;
@property (nonatomic , strong) DWDNearbySchoolModel *schoolModel;

@end
