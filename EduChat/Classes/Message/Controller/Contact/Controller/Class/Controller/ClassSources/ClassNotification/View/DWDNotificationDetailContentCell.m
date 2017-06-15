//
//  DWDNotificationDetailContentCell.m
//  EduChat
//
//  Created by doublewood on 15/12/10.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDNotificationDetailContentCell.h"
#import "UIImage+Utils.h"
#import <Masonry/Masonry.h>

@interface DWDNotificationDetailContentCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgHeader;
@property (weak, nonatomic) IBOutlet UILabel *labAuthorld;
@property (weak, nonatomic) IBOutlet UILabel *labAddTime;

@property (weak, nonatomic) UIButton *btnIknow;
@property (weak, nonatomic) UIButton *btnYES;
@property (weak, nonatomic) UIButton *btnNO;

@property (weak, nonatomic) UILabel *labContent;
@property (weak, nonatomic) UIImageView *img;
@property (weak, nonatomic) UIView *line;
@end
@implementation DWDNotificationDetailContentCell

- (void)awakeFromNib {
    
    
    //设置线条
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(DWDScreenW/2-100,150, 200, DWDLineH)];
    self.line = line;
    line.backgroundColor = DWDColorSeparator;
    [self.contentView addSubview:line];
    
    //设置通知内容
    UILabel *labContent = [[UILabel alloc]init];
    self.labContent = labContent;
    labContent.textColor = DWDColorContent;
    labContent.font = DWDFontContent;
    labContent.numberOfLines = 0;
    [self.contentView addSubview:labContent];
 
    
    //设置按钮
    UIButton *btn = [self createButtonTitle:@"我知道了"];
    _btnIknow = btn;
    
    UIButton *btnYES = [self createButtonTitle:@"YES"];
    _btnYES = btnYES;
    
    UIButton *btnNO = [self createButtonTitle:@"NO"];
    _btnNO = btnNO;
    
    
    //设置图片
    UIImageView *img = [[UIImageView alloc]init];
    self.img = img;
    img.image = [UIImage imageNamed:@"bg_notice_notification_details"];
    [self.contentView addSubview:img];
    
}

- (void)setDictDataSource:(NSDictionary *)dictDataSource
{
    _dictDataSource = dictDataSource;
    
    _labAuthorld.text = dictDataSource[@"author"][@"name"];
    _labAddTime.text = dictDataSource[@"author"][@"addtime"];
    
    
    _labContent.text = dictDataSource[@"notice"][@"content"];
    CGSize labContentSize = [_labContent.text boundingRectWithfont:_labContent.font sizeMakeWidth:self.bounds.size.width];
    _labContent.frame = CGRectMake(self.bounds.origin.x+DWDPadding, CGRectGetMaxY(self.line.frame)+15, labContentSize.width-20, labContentSize.height+DWDPadding);
    DWDLog(@"%@",NSStringFromCGRect(_labContent.frame));
    
    
    UIButton *btn ;
    
    self.type = dictDataSource[@"notice"][@"type"];
    if ([self.type isEqualToNumber:@1]) {
        
        _btnIknow.frame = CGRectMake(DWDScreenW/2-DWDPadding*5-10, CGRectGetMaxY(_labContent.frame) + 20,100, DWDPadding*4);
        _btnIknow.layer.masksToBounds = YES;
        _btnIknow.layer.cornerRadius = self.btnIknow.frame.size.height/2;
        
        btn = self.btnIknow;
    }else{
        _btnYES.frame = CGRectMake(DWDScreenW/4-DWDPadding*5-10, CGRectGetMaxY(_labContent.frame) + 20,100, DWDPadding*4);
        _btnYES.layer.masksToBounds = YES;
        _btnYES.layer.cornerRadius = self.btnYES.frame.size.height/2;
        
        _btnNO.frame = CGRectMake(DWDScreenW/4*3-DWDPadding*5-10, CGRectGetMaxY(_labContent.frame) + 20,100, DWDPadding*4);
        _btnNO.layer.masksToBounds = YES;
        _btnNO.layer.cornerRadius = self.btnNO.frame.size.height/2;
        
        btn = self.btnYES;
    }
    
    [_img makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.centerX);
        make.height.equalTo(@5);
        make.width.equalTo(@355);
        make.top.equalTo(@(CGRectGetMaxY(btn.frame)+20));
        
    }];
    

    //cell height
     _notiDetailContentHight = CGRectGetMaxY(btn.frame)+25;
}


// create btn
- (UIButton *)createButtonTitle:(NSString *)title
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:DWDColorContent] forState:UIControlStateSelected];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contentView addSubview:btn];
    
    return btn;

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setFrame:(CGRect)frame
{
    CGRect F = frame;
    F.origin.x += 10;
    F.size.width -= 20;
    F.origin.y -= 10;
    [super setFrame:F];
}
@end
