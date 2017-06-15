//
//  DWDDetailSystemMessageVerifyCell.m
//  EduChat
//
//  Created by apple on 3/1/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDDetailSystemMessageVerifyCell.h"
#import <Masonry.h>

@interface DWDDetailSystemMessageVerifyCell () <UITextFieldDelegate>

//@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *infoLabel;
@property (nonatomic, weak) UIButton *replyButton;

@property (nonatomic, weak) UIAlertAction *confirmAction;
@end

@implementation DWDDetailSystemMessageVerifyCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
//    UILabel *nameLabel = [UILabel new];
//    nameLabel.font = DWDFontBody;
//    nameLabel.textColor = DWDColorSecondary;
//    [self.contentView addSubview:nameLabel];
//    [nameLabel makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.contentView).offset(15);
//        make.left.equalTo(self.contentView).offset(10);
//    }];
//    self.nameLabel = nameLabel;
    
    
    UILabel *infoLabel = [UILabel new];
    infoLabel.font = DWDFontBody;
    infoLabel.textColor = DWDColorSecondary;
    infoLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:infoLabel];
    [infoLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(15);
        make.left.equalTo(self.contentView).offset(10);
        make.right.equalTo(self.contentView).offset(-10);
    }];
    self.infoLabel = infoLabel;
    
    /*******
     
     回复按钮  没做完
    
    *******/
    
    
    
    UIButton *replyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [replyButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"回复"
                                                                    attributes:
                                     @{NSFontAttributeName : [UIFont systemFontOfSize:14],
                            NSForegroundColorAttributeName : DWDRGBColor(51, 51, 51)}]
                           forState:UIControlStateNormal];
    [replyButton addTarget:self action:@selector(replyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    replyButton.layer.borderWidth = 1.1;
    [replyButton.layer setBorderColor:DWDRGBColor(153, 153, 153).CGColor];
    replyButton.layer.cornerRadius = 5;
    replyButton.layer.masksToBounds = YES;
    [self.contentView addSubview:replyButton];
    [replyButton makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(60);
        make.right.equalTo(self.contentView).offset(-pxToH(44));
        make.bottom.equalTo(self.contentView).offset(-pxToH(20));
        make.top.equalTo(infoLabel.bottom).offset(pxToH(20));
    }];
    self.replyButton = replyButton;
    
    [super updateConstraints];
   
    return self;
}

- (void)replyButtonClick:(UIButton *)button {
    DWDMarkLog(@"yesReplyButton");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"回复" message:nil preferredStyle:UIAlertControllerStyleAlert];
    WEAKSELF;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.delegate = weakSelf;
        textField.placeholder = @"回复";
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"发送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
        UITextField *textField = [alertController.textFields lastObject];
        NSString *replyStr = textField.text;
        if (replyStr.length <= 0) {
            return;
        }
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(verifyCell:clickComfirmButtonToSendText:)]) {
            [weakSelf.delegate verifyCell:weakSelf clickComfirmButtonToSendText:replyStr];
        }
    }];
    _confirmAction = confirmAction;
    confirmAction.enabled = NO;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    }];
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    if (_delegate && [_delegate respondsToSelector:@selector(verifyCell:clickReplyToShowAlertController:)]) {
        [_delegate verifyCell:self clickReplyToShowAlertController:alertController];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if (string.length == 0 && textField.text.length == 0) {
//        _confirmAction.enabled = NO;
//    } else {
//        _confirmAction.enabled = YES;
//    }
    NSMutableString *str = [[NSMutableString alloc] initWithString:textField.text];
    [str replaceCharactersInRange:range withString:string];
    
    if (str.length == 0) {
        _confirmAction.enabled = NO;
    } else {
        _confirmAction.enabled = YES;
    }
    
    return YES;
}

#pragma mark - Setter / Getter
//- (void)setName:(NSString *)name {
//    _name = name;
//    
//    NSString *newName;
//    if (name.length > 6) {
//        newName = [name substringToIndex:5];
//        newName = [newName stringByAppendingString:@".."];
//    } else {
//        newName = name;
//    }
//    self.nameLabel.text = newName;
//    [self.nameLabel sizeToFit];
//}

- (void)setVerifyInfo:(NSString *)verifyInfo {
    _verifyInfo = verifyInfo;
    self.infoLabel.text = verifyInfo;
}

@end
