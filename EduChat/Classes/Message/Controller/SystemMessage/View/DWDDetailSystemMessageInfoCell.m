//
//  DWDDetailSystemMessageInfoCell.m
//  EduChat
//
//  Created by apple on 3/1/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDDetailSystemMessageInfoCell.h"
#import <Masonry.h>

#define maxNameWidth 90

@interface DWDDetailSystemMessageInfoCell ()
@property (nonatomic, weak) UILabel *addressLabel;
@property (nonatomic, weak) UILabel *signatureLabel;
@property (nonatomic, weak) UILabel *sourceLabel;

@end

@implementation DWDDetailSystemMessageInfoCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    
    
    UILabel *addressNameLabel = [UILabel new];
    addressNameLabel.text = @"地区";
    addressNameLabel.textColor = DWDColorSecondary;
    [self.contentView addSubview:addressNameLabel];
    UILabel *signaureNameLabel = [UILabel new];
    signaureNameLabel.text = @"个性签名";
    signaureNameLabel.textColor = DWDColorSecondary;
    [self.contentView addSubview:signaureNameLabel];
    UILabel *sourceNameLabel = [UILabel new];
    sourceNameLabel.text = @"申请加入";
    sourceNameLabel.textColor = DWDColorSecondary;
    [self.contentView addSubview:sourceNameLabel];
    
    UIView *line0View = [UIView new];
    line0View.backgroundColor = DWDRGBColor(241, 241, 241);
    [self.contentView addSubview:line0View];
    
    UIView *line1View = [UIView new];
    line1View.backgroundColor = DWDRGBColor(241, 241, 241);
    [self.contentView addSubview:line1View];
    
    UILabel *addressLabel = [UILabel new];
    [self.contentView addSubview:addressLabel];
    self.addressLabel = addressLabel;
    UILabel *signatureLabel = [UILabel new];
    [self.contentView addSubview:signatureLabel];
    self.signatureLabel = signatureLabel;
    UILabel *sourceLabel = [UILabel new];
    [self.contentView addSubview:sourceLabel];
    self.sourceLabel = sourceLabel;
    
    [addressNameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
//        make.centerY.mas_equalTo(pxToH(44));
        make.top.equalTo(self.contentView).offset(15);
        make.width.mas_equalTo(maxNameWidth - 10);
    }];
    [addressNameLabel sizeToFit];
    
    [addressLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(addressNameLabel);
        make.left.equalTo(self.contentView).offset(maxNameWidth + 15);
        make.right.equalTo(self.contentView).offset(-10);
    }];
    
    [line0View makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(addressLabel.bottom).offset(15);
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
    
    [signaureNameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line0View.bottom).offset(15);
        make.left.equalTo(addressNameLabel);
        make.width.mas_equalTo(maxNameWidth - 10);
    }];
    [signaureNameLabel sizeToFit];
    
    [signatureLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(signaureNameLabel);
        make.left.equalTo(self.contentView).offset(maxNameWidth + 15);
        make.right.equalTo(self.contentView).offset(-10);
    }];
    
    [line1View makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(signatureLabel.bottom).offset(15);
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
    
    [sourceNameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(addressNameLabel);
        make.top.equalTo(line1View.bottom).offset(15);
        make.bottom.equalTo(self.contentView).offset(-15);
        make.width.mas_equalTo(maxNameWidth - 10);
    }];
    [sourceNameLabel sizeToFit];
    
    [sourceLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sourceNameLabel);
        make.left.equalTo(self.contentView).offset(maxNameWidth + 15);
        make.right.equalTo(self.contentView).offset(-10);
    }];
    
    [super updateConstraints];
    
    return self;
}

- (void)setAddress:(NSString *)address {
    _address = address;
    if ([address isEqualToString:@""] || address == nil) {
        address = @" ";
    }
    self.addressLabel.text = address;
    [self.addressLabel sizeToFit];
}

- (void)setSignature:(NSString *)signature {
    _signature = signature;
    if ([signature isEqualToString:@""] || signature == nil) {
        signature = @"TA啥都没留下";
    }
    self.signatureLabel.text = signature;
    [self.signatureLabel sizeToFit];
}

- (void)setVerifySource:(NSString *)verifySource {
    _verifySource = verifySource;
    NSString *text;
    if ([verifySource isEqualToString:@""] || verifySource == nil) {
        text = @" ";
    } else {
        text = verifySource;
    }
    self.sourceLabel.text = text;
    [self.sourceLabel sizeToFit];
}

@end
