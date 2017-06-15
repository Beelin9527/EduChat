//
//  DWDShareAppToFriendViewController.m
//  EduChat
//
//  Created by Gatlin on 16/10/20.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDShareAppToFriendViewController.h"

#import "UMSocial.h"
@interface DWDShareAppToFriendViewController ()

@end

@implementation DWDShareAppToFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"推荐给朋友";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)setupUI{
    CAGradientLayer *gradientLayerTop = [CAGradientLayer layer];  // 设置渐变效果
    gradientLayerTop.borderWidth = 0;
    gradientLayerTop.frame = (CGRect){0, 0, DWDScreenW, pxToH(490)};
    gradientLayerTop.colors = [NSArray arrayWithObjects:
                               (id)UIColorFromRGB(0x5a88e7).CGColor,
                               (id)UIColorFromRGB(0x58bfda).CGColor, nil];
    gradientLayerTop.startPoint = CGPointMake(0.5, 0.0);
    gradientLayerTop.endPoint = CGPointMake(0.5, 1.0);
    [self.view.layer addSublayer:gradientLayerTop];
    
    CAGradientLayer *gradientLayerBottom = [CAGradientLayer layer];  // 设置渐变效果
    gradientLayerBottom.borderWidth = 0;
    gradientLayerBottom.frame = (CGRect){0, DWDScreenH - DWDTopHight - pxToH(365),DWDScreenW, pxToH(365)};
    gradientLayerBottom.colors = [NSArray arrayWithObjects:
                               (id)UIColorFromRGB(0x58bfda).CGColor,
                               (id)UIColorFromRGB(0x56ded3).CGColor, nil];
    gradientLayerBottom.startPoint = CGPointMake(0.5, 0.0);
    gradientLayerBottom.endPoint = CGPointMake(0.5, 1.0);
    [self.view.layer addSublayer:gradientLayerBottom];

    [self.view addSubview:({
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDTopHight)];
        imv.image = [UIImage imageNamed:@"bg_recommend_me"];
        
       
        imv;
    })];
    
    NSArray *icon_array = @[@"ic_-wechat_me",@"ic_Circle_me",@"ic_qq_me",@"ic_space_me"];
    NSArray *title_array = @[@"微信好友",@"朋友圈",@"QQ好友",@"QQ空间"];
   
    CGFloat btnW = 65;
    CGFloat padding =  (DWDScreenW - btnW*4) / 5.0;
    for (int i = 0; i < icon_array.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        
        btn.frame = CGRectMake(padding *(1+i) +(i * btnW), pxToH(620), btnW, btnW);
        btn.titleLabel.font = DWDFontContent;
        [btn setTitleColor:DWDColorContent forState:UIControlStateNormal];
        [btn setTitle:title_array[i] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:icon_array[i]] forState:UIControlStateNormal];
        
        btn.titleEdgeInsets = UIEdgeInsetsZero;
        btn.imageEdgeInsets = UIEdgeInsetsZero;
         
        CGFloat offset = 10;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0,
                                                -btn.imageView.frame.size.width,
                                                -btn.imageView.frame.size.height - offset,
                                                0);
        // 由于iOS8中titleLabel的size为0，使用intrinsicContentSize
        btn.imageEdgeInsets = UIEdgeInsetsMake(-btn.titleLabel.intrinsicContentSize.height - offset,
                                                0,
                                                0,
                                                -btn.titleLabel.intrinsicContentSize.width);
        [btn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:btn];
    }
}

- (void)shareAction:(UIButton *)sender{
    NSString *type = nil;
    switch (sender.tag) {
        case 0:
            type = UMShareToWechatSession;
            [UMSocialData defaultData].extConfig.wechatSessionData.title = @"多维度，为孩子成长护航";
            [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://service.dwd-sj.com:8080/download2/download.html";
            break;
        case 1:
            type = UMShareToWechatTimeline;
            [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"多维度，为孩子成长护航";
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://service.dwd-sj.com:8080/download2/download.html";
            break;
        case 2:
            type = UMShareToQQ;
            [UMSocialData defaultData].extConfig.qqData.title = @"多维度，为孩子成长护航";
            [UMSocialData defaultData].extConfig.qqData.url = @"http://service.dwd-sj.com:8080/download2/download.html";
            break;
        case 3:
            type = UMShareToQzone;
            [UMSocialData defaultData].extConfig.qzoneData.title = @"多维度，为孩子成长护航";
            [UMSocialData defaultData].extConfig.qzoneData.url = @"http://service.dwd-sj.com:8080/download2/download.html";
            break;
            
        default:
            return;
            break;
    }
    
    [[UMSocialDataService defaultDataService] postSNSWithTypes:@[type] content:@"构建家校紧密的教育社交平台，家校共育，一切为了孩子。" image:[UIImage imageNamed:@"img_logo"] location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response) {
        
    }];
}

@end
