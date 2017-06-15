//
//  DWDPickUpCenterTimeLineCell.h
//  EduChat
//
//  Created by KKK on 16/3/18.
//  Copyright © 2016年 dwd. All rights reserved.
//


#define kNumberFontSize 16
#define kTextFontSize 14

#define kNameColor DWDRGBColor(51, 51, 51)

#import <UIKit/UIKit.h>

#import "DWDPickUpCenterDataBaseModel.h"


@interface DWDPickUpCenterTimeLineCell : UITableViewCell

@property (nonatomic, weak) UILabel *timeLabel;

@property (nonatomic, strong) NSDictionary *dataDictionary;

@property (nonatomic, assign) CGFloat cellHeight;

@end
