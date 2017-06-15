//
//  DWDPickUpCenterTimeLineLeaveSchoolDetailView.m
//  EduChat
//
//  Created by KKK on 16/3/19.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterTimeLineLeaveSchoolDetailView.h"

#import "DWDPickUpCenterDataBaseModel.h"

#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface DWDPickUpCenterTimeLineLeaveSchoolDetailView ()

@property (nonatomic, weak) UIImageView *picView;
@property (nonatomic, weak) UIImageView *symbolView;
@property (nonatomic, weak) UILabel *nameLabel;

@end

@implementation DWDPickUpCenterTimeLineLeaveSchoolDetailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    //布局子控件
    UIImageView *picView = [UIImageView new];
    picView.frame = CGRectMake(0, 0, (DWDScreenW - pxToW(236))/4.0, (DWDScreenW - pxToW(236))/4.0);
    DWDMarkLog(@"frame:%f", (DWDScreenW - pxToW(236))/4.0);
    [self addSubview:picView];
    self.picView = picView;
    
    UIImageView *symbolView = [UIImageView new];
    symbolView.frame = CGRectMake((DWDScreenW - pxToW(236))/4.0 - (DWDScreenW - pxToW(236))/4.0 * 0.1, 0, (DWDScreenW - pxToW(236))/4.0 * 0.2, (DWDScreenW - pxToW(236))/4.0 * 0.2);
    [self addSubview:symbolView];
    self.symbolView = symbolView;
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:nameLabel];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel = nameLabel;
    
//    [picView makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self);
//        make.top.equalTo(symbolView).offset(pxToW(6));
//        make.width.mas_equalTo(pxToW(120));
//        make.height.equalTo(make.width);
//    }];
//    [symbolView makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self);
//        make.right.equalTo(picView).offset(pxToW(10));
//        make.right.equalTo(self);
//    }];
//    [nameLabel makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(picView.bottom).offset(pxToW(20));
//        make.bottom.equalTo(self);
//        make.centerX.equalTo(picView);
//    }];
//    [super updateConstraints];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailViewDidSelected:)];
    [self addGestureRecognizer:tap];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.nameLabel.center = CGPointMake((DWDScreenW - pxToW(236))/4.0 / 2.0, (DWDScreenW - pxToW(236))/4.0 + pxToW(35));
}

#pragma mark - Event Response
- (void)detailViewDidSelected:(UITapGestureRecognizer *)tap {
    NSDictionary *dataDictionary = @{
                                     @"dataModel" : self.dataModel,
                                     };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"modalDetailViewWithNotification"
                                                        object:nil
                                                      userInfo:dataDictionary];
    
}

#pragma mark - Setter / Getter
- (void)setDataModel:(DWDPickUpCenterDataBaseModel *)dataModel {
    
    _dataModel = dataModel;
    
    [self.picView sd_setImageWithURL:[NSURL URLWithString:dataModel.photokey] placeholderImage:[[UIImage imageNamed:@"MSG_TF_head_placeholder"] clipWithCircle] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image && !error)
            [_picView setImage:[image clipCircleWithBorderWidth:0 borderColor:[UIColor whiteColor]]];
    }];
    //1 校车 0 校门
//    self.symbolView.image = dataModel.type ? [UIImage imageNamed:@"MSG_TF_Leave_Bus"]: [UIImage imageNamed:@"MSG_TF_Leave_Door"];
    if ([dataModel.contextual isEqualToString:@"OffAfterschoolBus"]) {
    self.symbolView.image =[UIImage imageNamed:@"MSG_TF_Leave_Bus"];
    } else if ([dataModel.contextual isEqualToString:@"Getoutschool"]) {
    self.symbolView.image = [UIImage imageNamed:@"MSG_TF_Leave_Door"];
    }
    self.nameLabel.text = dataModel.name;
    [self.nameLabel sizeToFit];
}

@end
