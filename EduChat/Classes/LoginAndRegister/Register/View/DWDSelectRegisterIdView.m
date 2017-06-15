//
//  DWDSelectRegisterIdView.m
//  EduChat
//
//  Created by Gatlin on 16/1/20.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDSelectRegisterIdView.h"

@interface DWDSelectRegisterIdView ()

@property (weak, nonatomic) IBOutlet UIButton *teacherBtn;
@property (weak, nonatomic) IBOutlet UIButton *parentBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
@property (weak, nonatomic) IBOutlet UILabel *selectLabel;
@property (weak, nonatomic) IBOutlet UILabel *teacherLabel;
@property (weak, nonatomic) IBOutlet UILabel *parentLabel;
@end
@implementation DWDSelectRegisterIdView

+ (instancetype)selectRegisterIdView
{
    DWDSelectRegisterIdView *mySelf = [[DWDSelectRegisterIdView alloc]init];
    mySelf = [[NSBundle mainBundle] loadNibNamed:@"DWDSelectRegisterIdView" owner:nil options:nil][0];
    return mySelf;
}



#pragma mark - Setter
- (void)setSelectParentAction:(SEL)selectParentAction
{
    [self.parentBtn addTarget:self.target action:selectParentAction forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelectCancleAction:(SEL)selectCancleAction
{
    [self.cancleBtn addTarget:self.target action:selectCancleAction forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Button Action
- (IBAction)selectTeacherAction:(UIButton *)sender
{
    sender.hidden = YES;
    self.parentBtn.hidden = YES;
    self.teacherLabel.hidden = YES;
    self.parentLabel.hidden = YES;
    self.selectLabel.text = @"请选择任教科目";
    
    int col,row,btnX,btnY;
    int btnW = 120;
    int btnH = 40;
    int x = DWDScreenW/2 -140;
    int y = self.teacherBtn.y;
    int paddingX = (140 - 120)*2;
    int paddingY = 20;
    
    NSArray *arrTitles = @[@"语文",@"数学",@"英语",@"其他"];
    for (int i = 0; i < 4; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i+1;
        
        /** setup frame **/
        col = i % 2;
        row = i / 2;
        btnX = x + col * (btnW + paddingX);
        btnY =  y + row  * (btnH + paddingY);
        
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        
        [btn setTitle:arrTitles[i] forState:UIControlStateNormal];
        [btn setTitleColor:DWDColorMain forState:UIControlStateNormal];
        
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = btn.h/2;
        btn.layer.borderColor = DWDColorMain.CGColor;
        btn.layer.borderWidth = 1;
        
        [btn addTarget:self.target action:self.selectTeacherSubjectAction forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}


@end
