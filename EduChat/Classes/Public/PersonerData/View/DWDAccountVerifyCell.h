//
//  DWDAccountVerifyCell.h
//  EduChat
//
//  Created by apple on 12/11/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWDAccountVerifyCellDelegate <NSObject>

@required
- (void)accountVerifyCellDidReply;

@end

@interface DWDAccountVerifyCell : UITableViewCell

@property (weak, nonatomic) id<DWDAccountVerifyCellDelegate> accountVerifyDelegate;

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end
