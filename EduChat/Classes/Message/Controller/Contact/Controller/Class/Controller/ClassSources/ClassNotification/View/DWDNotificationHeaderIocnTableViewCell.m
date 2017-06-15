//
//  DWDNotificationHeaderIocnTableViewCell.m
//  EduChat
//
//  Created by doublewood on 15/12/10.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDNotificationHeaderIocnTableViewCell.h"
#define KBtnImgW 50
#define KBtnTitleH 20
#define KPaddingWithImgTitle 5
#define KBtnViewH 75
#define KPadding  ( DWDScreenW - KColumn * KBtnImgW ) / (KColumn + 1)
#define KColumn  ((int)DWDScreenW / KBtnImgW -1)

@interface DWDNotificationHeaderIocnTableViewCell()
@property (strong, nonatomic) NSMutableArray *arrBtns;
@end
@implementation DWDNotificationHeaderIocnTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    int col;
    int row;
    int btnViewW = KBtnImgW;
    int btnViewH = KBtnViewH;
    int paddingX = KPadding;
    int paddingY = KPadding *2;
    int paddingOY = 35;

    int btnViewX;
    int btnViewY;
    //设置头像
    for(int i = 0 ; i < 20 ; i ++){
        
        //设置头像与文字View
        UIView *btnView = [[UIView alloc]init];
        [self.contentView addSubview:btnView];
        
        //设置头像
        UIButton *btnImg = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnImg setBackgroundImage:[UIImage imageNamed:@"AvatarMe"] forState:UIControlStateNormal];
        btnImg.frame = CGRectMake(0, 0, KBtnImgW, KBtnImgW);
        [btnView addSubview:btnImg];
        
        //设置文字
        UIButton *btnTitle = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnTitle setTitleColor:DWDColorContent forState:UIControlStateNormal];
        btnTitle.titleLabel.font = DWDFontMin;
        [btnTitle setTitle:@"李小明" forState:UIControlStateNormal];
          btnTitle.frame = CGRectMake(0, KBtnImgW +KPaddingWithImgTitle, KBtnImgW, KBtnTitleH);
        [btnView addSubview:btnTitle];
        
        
        col = i % KColumn;
        row = i / KColumn;
        btnViewX = (col + 1) * paddingX + col * btnViewW;
        btnViewY = paddingOY + row * paddingY + row * btnViewH;
        //设置viewFrame    35 是距离 cell.orgin.y 的
        btnView.frame = CGRectMake(btnViewX,btnViewY,btnViewW,btnViewH);
    }
    
    //计算高度
    int num =  20%KColumn== 0 ? 20 / KColumn:20 / KColumn +1;
    _cellHight = btnViewH *(20/num) + 35;
    
    
}
//-(void)layoutSubviews
//{
//    [super layoutSubviews];
//    for (int i = 0; i < self.arrBtns.count; i++) {
//        UIButton *btn = self.arrBtns[i];
//        btn.frame = CGRectMake(DWDPadding + (int)(self.bounds.size.width) % (int)KNumW, DWDPadding, KBtnW, KBtnW);
//    }
//    
//}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//-(void)setFrame:(CGRect)frame
//{
//    CGRect F = frame;
//    F.origin.x += 10;
//    F.size.width -= 20;
//    F.origin.y -= 10;
//    [super setFrame:F];
//}
@end
