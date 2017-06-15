//
//  DWDDetailSystemMessageVerifyCell.h
//  EduChat
//
//  Created by apple on 3/1/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDDetailSystemMessageVerifyCell;
@protocol DWDDetailSystemMessageVerifyCellDelegate <NSObject>
@optional
- (void)verifyCell:(DWDDetailSystemMessageVerifyCell *)cell clickReplyToShowAlertController:(UIAlertController *)controller;

- (void)verifyCell:(DWDDetailSystemMessageVerifyCell *)cell clickComfirmButtonToSendText:(NSString *)text;
@end

@interface DWDDetailSystemMessageVerifyCell : UITableViewCell

@property (nonatomic, copy) NSString *verifyInfo;
@property (nonatomic, strong) NSNumber *verifyId;
//@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) id<DWDDetailSystemMessageVerifyCellDelegate> delegate;
@end
