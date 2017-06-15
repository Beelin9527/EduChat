//
//  DWDSystemMessageCell.m
//  EduChat
//
//  Created by apple on 2/28/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDSystemMessageCell.h"
#import "DWDSystemMessageDetailModel.h"

#import <UIImageView+WebCache.h>
#import <Masonry.h>

@interface DWDSystemMessageCell ()

@property (weak, nonatomic) UIImageView *facePicView;
@property (weak, nonatomic) UILabel *nameLabel;
@property (weak, nonatomic) UILabel *verifyInfoLabel;
@property (weak, nonatomic) UILabel *sourceLabel;
@property (weak, nonatomic) UILabel *stateLabel;
@property (nonatomic, weak) UIImageView *arrowView;


@end

@implementation DWDSystemMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *facePicView = [UIImageView new];
        [self.contentView addSubview:facePicView];
        [facePicView makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(60);
            make.centerY.mas_equalTo(self.contentView.centerY);
            make.left.mas_equalTo(self.contentView).with.offset(10);
        }];
        self.facePicView = facePicView;
        
        UILabel *nameLabel = [UILabel new];
        nameLabel.font = [UIFont systemFontOfSize:16];
        nameLabel.textColor = DWDColorBody;
        [self.contentView addSubview:nameLabel];
        [nameLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.facePicView);
            make.left.mas_equalTo(self.facePicView.right).offset(DWDPadding);
            make.width.mas_equalTo(DWDScreenW - 152);
        }];
        self.nameLabel = nameLabel;
        
        UILabel *verifyInfoLabel = [UILabel new];
        verifyInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        verifyInfoLabel.numberOfLines = 1;
        verifyInfoLabel.font = [UIFont systemFontOfSize:14];
        verifyInfoLabel.textColor = DWDColorContent;
        [self.contentView addSubview:verifyInfoLabel];
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = UIColorFromRGB(0xf0f0f0);
        [self.contentView addSubview:lineView];
        
        [verifyInfoLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.facePicView.right).offset(DWDPadding);
            make.centerY.mas_equalTo(self.contentView.centerY);
            make.width.mas_equalTo(DWDScreenW - 152);
        }];
        self.verifyInfoLabel = verifyInfoLabel;
        
        UILabel *sourceLabel = [UILabel new];
        sourceLabel.font = [UIFont systemFontOfSize:14];
        sourceLabel.textColor = DWDColorSecondary;
        [self.contentView addSubview:sourceLabel];
        [sourceLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.facePicView.right).offset(DWDPadding);
            make.bottom.mas_equalTo(self.facePicView.bottom);
        }];
        self.sourceLabel = sourceLabel;
        
        
//        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_clickable_normal"]];
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.userInteractionEnabled = YES;
        [self.contentView addSubview:imgView];
        [imgView makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView);
            make.width.height.mas_equalTo(22);
            make.right.mas_equalTo(self.contentView).offset(-5);
        }];
        self.arrowView = imgView;
        
        UILabel *stateLabel = [UILabel new];
        stateLabel.font = [UIFont systemFontOfSize:14];
        
        [self.contentView addSubview:stateLabel];
        [stateLabel makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(imgView);
            make.right.mas_equalTo(imgView.left);
        }];
        self.stateLabel = stateLabel;
        
        [lineView makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(20);
            make.right.equalTo(self.contentView);
            make.height.mas_equalTo(1);
        }];
    }
    
    return self;
}

- (void)setDetailModel:(DWDSystemMessageDetailModel *)detailModel {
    _detailModel = detailModel;
    [self.facePicView sd_setImageWithURL:[NSURL URLWithString:detailModel.photoKey] placeholderImage:DWDDefault_MeBoyImage];
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@", detailModel.nickName];
    
    
//    if (detailModel.verifyInfo.length >= 9) {
//        self.verifyInfoLabel.text = [[detailModel.verifyInfo substringToIndex:8] stringByAppendingString:@"..."];
//    } else {
//    }
    self.verifyInfoLabel.text = detailModel.verifyInfo;
    
    self.sourceLabel.text = [NSString stringWithFormat:@"申请加入:%@", detailModel.className];
    //    0-待验证
    //    1-通过
    //    2-已拒绝
    if ([detailModel.verifyState isEqual:@0]) {
        self.stateLabel.text = @"待验证";
        self.stateLabel.textColor = DWDColorBody;
        [self.arrowView setImage:[UIImage imageNamed:@"ic_clickable_press"]];
    } else if ([detailModel.verifyState isEqual:@1]) {
        self.stateLabel.text = @"已通过";
        self.stateLabel.textColor = DWDColorSecondary;
        [self.arrowView setImage:[UIImage imageNamed:@"ic_clickable_normal"]];
    } else {
        self.stateLabel.text = @"已拒绝";
        self.stateLabel.textColor = DWDColorSecondary;
        [self.arrowView setImage:[UIImage imageNamed:@"ic_clickable_normal"]];
    }
    [self updateConstraints];
}

@end
