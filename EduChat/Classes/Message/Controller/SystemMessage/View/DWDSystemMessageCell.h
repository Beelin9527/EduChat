//
//  DWDSystemMessageCell.h
//  EduChat
//
//  Created by apple on 2/28/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDSystemMessageDetailModel;
@interface DWDSystemMessageCell : UITableViewCell

@property (nonatomic, strong) DWDSystemMessageDetailModel *detailModel;
@end
