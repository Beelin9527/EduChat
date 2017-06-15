//
//  DWDAccountVerifyCell.m
//  EduChat
//
//  Created by apple on 12/11/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDAccountVerifyCell.h"

@interface DWDAccountVerifyCell ()

@property (weak, nonatomic) IBOutlet UIButton *replyBtn;

@end

@implementation DWDAccountVerifyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.replyBtn setTitle:NSLocalizedString(@"Reply", nil) forState:UIControlStateNormal];
    
    [self.replyBtn setBackgroundImage:[UIImage imageNamed:@"btn_add_to_normal"] forState:UIControlStateNormal];
    [self.replyBtn setBackgroundImage:[UIImage imageNamed:@"btn_add_to_press"] forState:UIControlStateHighlighted];
    [self.replyBtn addTarget:self action:@selector(reply:) forControlEvents:UIControlEventTouchUpInside];
}


- (IBAction)reply:(id)sender {
    if (self.accountVerifyDelegate && [self.accountVerifyDelegate respondsToSelector:@selector(accountVerifyCellDidReply)]) {
        [self.accountVerifyDelegate accountVerifyCellDidReply];
    }
}

@end
