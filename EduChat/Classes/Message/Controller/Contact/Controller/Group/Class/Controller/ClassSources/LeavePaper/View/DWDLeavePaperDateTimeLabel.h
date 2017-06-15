//
//  DWDLeavePaperDateTimeLabel.h
//  EduChat
//
//  Created by KKK on 16/5/25.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDLeavePaperDateTimeLabel;
@protocol DWDLeavePaperDateTimeLabelDelegate <NSObject>

@optional
- (void)label:(DWDLeavePaperDateTimeLabel *)label didClickToolbarDoneButton:(NSDate *)date;
@end

@interface DWDLeavePaperDateTimeLabel : UILabel
@property (nonatomic, weak) id<DWDLeavePaperDateTimeLabelDelegate> delegate;

@end
