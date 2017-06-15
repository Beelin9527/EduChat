//
//  DWDPickUpCenterTimeLineCell.m
//  EduChat
//
//  Created by KKK on 16/3/18.
//  Copyright © 2016年 dwd. All rights reserved.
//
#import "DWDPickUpCenterTimeLineCell.h"



@interface DWDPickUpCenterTimeLineCell ()




@end

@implementation DWDPickUpCenterTimeLineCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    //颜色
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    //左侧时间轴
    //时间label
    UILabel *timeLabel = [UILabel new];
    timeLabel.font = [UIFont systemFontOfSize:kNumberFontSize];
    timeLabel.textColor = kNameColor;
    timeLabel.frame = CGRectMake(pxToW(20), pxToW(40), pxToW(136 - 20 - 12), pxToW(30));
    

    [self.contentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    //圆形标志
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MSG_TF_Leave_Time"]];
    [self.contentView addSubview:imageView];
    imageView.frame = CGRectMake(pxToW(136 - 9.5), pxToW(40), pxToW(19), pxToW(19));

    
    //masonry
//    [timeLabel makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(pxToW(20));
//        make.top.equalTo(self.contentView).offset(pxToW(20));
//    }];
//    [imageView makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(timeLabel.right).offset(pxToW(12));
//        make.centerY.equalTo(timeLabel);
//        make.width.height.mas_equalTo(pxToW(19));
//    }];
//    
//    [containerView makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(imageView).offset(pxToW(20));
//        make.top.equalTo(self.contentView).offset(pxToW(20));
//        make.bottom.equalTo(self.contentView).offset(-pxToW(10));
//        make.right.equalTo(self.contentView).offset(-pxToW(10));
//    }];
    return self;
}

@end
