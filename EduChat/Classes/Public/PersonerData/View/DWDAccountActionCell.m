//
//  DWDAccountActionCell.m
//  EduChat
//
//  Created by apple on 12/11/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDAccountActionCell.h"

@interface DWDAccountActionCell ()

@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

@end

@implementation DWDAccountActionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (void)setActionType:(DWDAccountActionType )actionType {
    _actionType = actionType;
    if (_actionType == DWDAccountActionTypeSend) {
        [self.actionBtn setTitle:NSLocalizedString(@"SendMsg", nil) forState:UIControlStateNormal];
    } else if (_actionType == DWDAccountActionTypeAddContact){
        [self.actionBtn setTitle:NSLocalizedString(@"AddContact", nil) forState:UIControlStateNormal];
    } else if (_actionType == DWDAccountActionTypePassVerify ){
        [self.actionBtn setTitle:NSLocalizedString(@"PassVerify", nil) forState:UIControlStateNormal];
    }
}

- (IBAction)action:(id)sender {
    if (self.actionType == DWDAccountActionTypeSend) {
        if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(accountActionDidSendMsg)]) {
            [self.actionDelegate accountActionDidSendMsg];
        }
    }else  if (self.actionType == DWDAccountActionTypeAddContact) {
        if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(accountActionDidAddContact)]) {
            [self.actionDelegate accountActionDidAddContact];
        }
    }
    else if (self.actionType == DWDAccountActionTypePassVerify){
        if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(accountActionDidPassVerify)]) {
            [self.actionDelegate accountActionDidPassVerify];
        }
    }
}

@end
