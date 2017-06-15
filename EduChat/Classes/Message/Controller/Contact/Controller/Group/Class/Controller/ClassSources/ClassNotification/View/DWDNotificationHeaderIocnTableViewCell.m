//
//  DWDNotificationHeaderIocnTableViewCell.m
//  EduChat
//
//  Created by Gatlin on 15/12/10.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDNotificationHeaderIocnTableViewCell.h"
#import <UIButton+WebCache.h>

#define KBtnImgW 50
#define KBtnTitleH 20
#define KPaddingWithImgTitle 5
#define KBtnViewH 75
#define KPadding  ( DWDScreenW - KColumn * KBtnImgW ) / (KColumn + 1)
#define KColumn  ((int)DWDScreenW / KBtnImgW -1)

@interface DWDNotificationHeaderIocnTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *personNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *replyTypeLabel;
@property (strong, nonatomic) NSMutableArray *arrBtns;
@end
@implementation DWDNotificationHeaderIocnTableViewCell

- (void)awakeFromNib {

    
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

- (void)setUserArray:(NSArray *)userArray {
    _userArray = userArray;
    
    NSString *typeStr;
    if ([self.type isEqual:@1]) {
        if ([self.reuseIdentifier isEqualToString:@"DWDNotificationHeaderIocnReadedTableViewCell"]) {
            typeStr = @"已读";
        } else {
            typeStr = @"未读";
        }
    } else {
        if ([self.reuseIdentifier isEqualToString:@"DWDNotificationHeaderIocnReadedTableViewCell"]) {
            typeStr = @"YES";
        } else {
            typeStr = @"NO";
        }
    }
    
    self.replyTypeLabel.text = typeStr;
    self.personNumberLabel.text = [NSString stringWithFormat:@"%ld 人", self.userArray.count];
    
    
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
    UIView *lastButtonView = [[UIView alloc] init];
    for(int i = 0 ; i < userArray.count ; i ++){
        
        //设置头像与文字View
        UIView *btnView = [[UIView alloc]init];
        [self.contentView addSubview:btnView];
        
        //设置头像
        UIButton *btnImg = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [btnImg setBackgroundImage:[UIImage imageNamed:@"AvatarMe"] forState:UIControlStateNormal];
        [btnImg sd_setImageWithURL:[NSURL URLWithString:userArray[i][@"photoKey"]] forState:UIControlStateNormal placeholderImage:nil];
        btnImg.frame = CGRectMake(0, 0, KBtnImgW, KBtnImgW);
        [btnView addSubview:btnImg];
        
        //设置文字
        UIButton *btnTitle = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnTitle setTitleColor:DWDColorContent forState:UIControlStateNormal];
        btnTitle.titleLabel.font = DWDFontMin;
        [btnTitle setTitle:userArray[i][@"name"] forState:UIControlStateNormal];
        btnTitle.frame = CGRectMake(0, KBtnImgW +KPaddingWithImgTitle, KBtnImgW, KBtnTitleH);
        [btnView addSubview:btnTitle];
        
        
        col = i % KColumn;
        row = i / KColumn;
        btnViewX = (col + 1) * paddingX + col * btnViewW;
        btnViewY = paddingOY + row * paddingY + row * btnViewH;
        //设置viewFrame    35 是距离 cell.orgin.y 的
        btnView.frame = CGRectMake(btnViewX,btnViewY,btnViewW,btnViewH);
        
        lastButtonView = btnView;
    }
    
    //计算高度
    //    int num =  20%KColumn== 0 ? 20 / KColumn:20 / KColumn +1;
    //    _cellHight = btnViewH *(20/num) + 35;
    CGFloat cellHeight = pxToW(100);
    if (CGRectGetMaxY(lastButtonView.frame) > cellHeight) {
        _cellHight = CGRectGetMaxY(lastButtonView.frame);
    } else {
        _cellHight = cellHeight;
    }
    
}

@end
