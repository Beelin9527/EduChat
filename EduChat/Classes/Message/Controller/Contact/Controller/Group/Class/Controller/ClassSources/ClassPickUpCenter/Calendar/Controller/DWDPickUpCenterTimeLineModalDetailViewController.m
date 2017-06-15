//
//  DWDPickUpCenterTimeLineModalDetailViewController.m
//  EduChat
//
//  Created by KKK on 16/3/28.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterTimeLineModalDetailViewController.h"
#import "DWDPickUpCenterDataBaseModel.h"

#import "NSString+extend.h"

#import <UIImageView+WebCache.h>
#import <Masonry.h>

@interface DWDPickUpCenterTimeLineModalDetailViewController ()

@property (nonatomic, weak) UIImageView *bigImageView;
@property (nonatomic, weak) UIImageView *littleImageView;
@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, weak) UILabel *dateTimeLabel;

@end

@implementation DWDPickUpCenterTimeLineModalDetailViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    UIImageView *bigImageView = [UIImageView new];
    [self.view addSubview:bigImageView];
    UIImageView *littleImageView = [UIImageView new];
    [self.view addSubview:littleImageView];
    UILabel *contentLabel = [UILabel new];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:contentLabel];
    UILabel *dateTimeLabel = [UILabel new];
    dateTimeLabel.textColor = DWDColorSecondary;
    dateTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:dateTimeLabel];
    
    self.bigImageView = bigImageView;
    self.littleImageView = littleImageView;
    self.contentLabel = contentLabel;
    self.dateTimeLabel = dateTimeLabel;
    
    [bigImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(pxToW(10));
        make.left.equalTo(self.view).offset(pxToW(10));
        make.right.equalTo(self.view).offset(-pxToW(10));
        
        make.height.mas_equalTo(pxToW(580));
    }];
    
    [littleImageView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bigImageView);
        make.top.equalTo(bigImageView.bottom).offset(pxToW(30));
        
        make.width.height.mas_equalTo(pxToW(80));
    }];
    
    [contentLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bigImageView);
        make.top.equalTo(littleImageView.bottom).offset(pxToW(30));
        
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    
    [dateTimeLabel makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bigImageView);
        make.top.equalTo(contentLabel.bottom).offset(pxToW(30));
        make.bottom.equalTo(self.view).offset(-pxToW(30));
        
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    
    [super updateViewConstraints];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controllerShouldDismiss)];
    [self.view.superview addGestureRecognizer:tap];
}

#pragma mark - Private Method
- (void)controllerShouldDismiss {
    if ([self.delegate respondsToSelector:@selector(controllerShouldDismiss:)]) {
        [self.delegate controllerShouldDismiss:self];
    }
}

#pragma mark - Event Response
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self controllerShouldDismiss];
}

#pragma mark - Setter / Getter
- (void)setDataModel:(DWDPickUpCenterDataBaseModel *)dataModel {
    _dataModel = dataModel;
    
    [_bigImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.photo] placeholderImage:[UIImage imageNamed:@"ME_User_HP_Boy"]];
    [_littleImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.photokey] placeholderImage:[[UIImage imageNamed:@"MSG_TF_head_placeholder"] clipWithCircle] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image && !error)
            [_littleImageView setImage:[image clipCircleWithBorderWidth:0 borderColor:[UIColor whiteColor]]];
    }];
    
    if ([dataModel.contextual isEqualToString:@"OffAfterschoolBus"]) {
//        小明已安全到家。
//        %@已安全到家。
    _contentLabel.text = [NSString stringWithFormat:@"%@已安全到家。", dataModel.name];
    } else if ([dataModel.contextual isEqualToString:@"Getoutschool"]) {
//       今天是小明爸爸接小明放学。
//       今天是%@%@接%@放学。
        _contentLabel.text = [NSString stringWithFormat:@"今天是%@%@接%@放学。", dataModel.name, [NSString parentRelationStringWithRelation:dataModel.relation], dataModel.name];
    } else if ([dataModel.contextual isEqualToString:@"Reachschool"] || [dataModel.contextual isEqualToString:@"OffGotoschoolBus"]) {
        _contentLabel.text = [NSString stringWithFormat:@"%@已到校。", dataModel.name];
    }
    [_contentLabel sizeToFit];
    
    NSString *dateStr = [NSString stringWithFormat:@"%@ %@", dataModel.date, dataModel.time];
    _dateTimeLabel.text = [NSString stringWithFormat:@"%@ %@", [NSString stringFormatYYYYMMddHHmmssDateToYYYYMMddString:dateStr], dataModel.time];
    [_dateTimeLabel sizeToFit];
}

@end
