//
//  DWDChatSessionCell.h
//  EduChat
//
//  Created by apple on 11/4/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYLabel.h>
@class DWDRecentChatModel;
@interface DWDChatSessionCell : UITableViewCell

@property (nonatomic , strong) DWDRecentChatModel *recentChatModel;
@property (nonatomic , weak) CALayer *seperatorLayer;

@end
