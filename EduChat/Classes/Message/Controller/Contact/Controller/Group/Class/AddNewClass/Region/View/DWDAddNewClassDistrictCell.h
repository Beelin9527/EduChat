//
//  DWDAddNewClassDistrictCell.h
//  EduChat
//
//  Created by Superman on 15/12/11.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger,DWDTextStyle) {
    DWDTextStyleLocation,DWDTextStyleArea
};
@interface DWDAddNewClassDistrictCell : UITableViewCell
@property (nonatomic , copy) NSString *currentLocation;

@end
