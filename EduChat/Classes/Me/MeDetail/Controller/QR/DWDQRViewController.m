//
//  DWDRQViewController.m
//  EduChat
//
//  Created by Gatlin on 16/1/28.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDQRViewController.h"

#import "DWDQRImageView.h"

#import <SDVersion.h>
@interface DWDQRViewController ()
@property (weak, nonatomic) IBOutlet UIView *qr_view;
@property (weak, nonatomic) IBOutlet UILabel *nickname_lab;
@property (weak, nonatomic) IBOutlet UIImageView *avatar_imv;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet UILabel *introl_lab;

@property (strong, nonatomic) DWDQRImageView *QRImageView;
@end

@implementation DWDQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"二维码";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.qr_view.layer.masksToBounds = YES;
    self.qr_view.layer.cornerRadius = 10;
   
    self.avatar_imv.image = _image;
    self.nickname_lab.text = _nickname;
    
    if (self.type == DWDQRTypeGroup) {
        self.introl_lab.text = @"扫描二维码加入群聊";
    }else if(self.type == DWDQRTypeClass) {
        self.introl_lab.text = @"扫描二维码加入班级";
    }else{
        self.introl_lab.text = @"扫描二维码添加我为好友";
    }
    
    [self.view addSubview:self.QRImageView];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setShadowImage:nil];
}

#pragma mark - Getter
- (DWDQRImageView *)QRImageView
{
    if (!_QRImageView) {
        _QRImageView = [[DWDQRImageView alloc] initWithQRImageForString:self.info];

        NSInteger width = 0;
        if(DWDScreenH == 480){//iphone4
            width = 130;
        }else if (DWDScreenH == 568){//iphone5
            width = 130 * 1.2;
        }else{
            width = 130 * 2;
        }
        _QRImageView.frame = CGRectMake(DWDScreenW/2 -width/2, 130, width , width);

       
        
    }
    return _QRImageView;
}
@end
