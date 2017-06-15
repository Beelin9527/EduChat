//
//  DWDPickUpCenterTimeLineDetailView.m
//  EduChat
//
//  Created by KKK on 16/3/18.
//  Copyright © 2016年 dwd. All rights reserved.
//

#define kNameColor DWDRGBColor(51, 51, 51)

#import "DWDPickUpCenterTimeLineGoSchoolDetailView.h"
#import "DWDPickUpCenterDataBaseModel.h"

#import <UIImageView+WebCache.h>

@interface DWDPickUpCenterTimeLineGoSchoolDetailView ()

@property (nonatomic, weak) UIImageView *picView;
@property (nonatomic, weak) UILabel *nameLabel;

@end

@implementation DWDPickUpCenterTimeLineGoSchoolDetailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.14f;
    self.layer.shadowRadius = 0.25;
    self.layer.shadowOffset = CGSizeMake(pxToW(2), pxToW(5));
    
    //布局子控件
    UIImageView *picView = [UIImageView new];
    picView.frame = CGRectMake(0, 0, (DWDScreenW - pxToW(236))/4.0, (DWDScreenW - pxToW(236))/4.0);
    [self addSubview:picView];
    self.picView = picView;
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.textColor = kNameColor;
    [self addSubview:nameLabel];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel = nameLabel;
    
//    [picView makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self);
//        make.top.equalTo(self);
//        make.right.equalTo(self);
//        make.bottom.equalTo(self);
//        make.width.and.height.mas_equalTo(pxToW(120));
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
    self.nameLabel.text = dataModel.name;
    [self.nameLabel sizeToFit];
}

@end
