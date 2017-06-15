//
//  DWDAccountActionCell.h
//  EduChat
//
//  Created by apple on 12/11/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWDAccountActionDelegate <NSObject>

@optional
- (void)accountActionDidSendMsg;
- (void)accountActionDidPassVerify;
- (void)accountActionDidAddContact;

@end

typedef NS_ENUM(NSInteger, DWDAccountActionType) {
    DWDAccountActionTypeSend,
    DWDAccountActionTypeAddContact,
    DWDAccountActionTypePassVerify
    
};


@interface DWDAccountActionCell : UITableViewCell

@property (weak, nonatomic) id<DWDAccountActionDelegate> actionDelegate;

@property (nonatomic) DWDAccountActionType actionType;

@end
