//
//  DWDClassMenu.m
//  EduChat
//
//  Created by Superman on 15/11/23.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassMenu.h"
#import "DWDChatController.h"
#import "DWDClassSourceCheckScoreViewController.h"
#import "DWDClassSourceClassNotificationViewController.h"
#import "DWDClassSourceGrowupRecordViewController.h"
#import "DWDClassSourceHomeWorkViewController.h"
#import "DWDClassSourceLeavePaperViewController.h"
#import "DWDGrowUpViewController.h"

#import "DWDTeacherDetailViewController.h"
#import "DWDPickUpCenterChildTableViewController.h"
//#import "DWDClassSourceClassActivityViewController.h"
//#import "DWDClassSourceClassMoneyViewController.h"
//#import "DWDClassSourceClassVoteViewController.h"
//#import "DWDClassSourceSourceBoxViewController.h"

#define defaultMaginWidth 30
#define defaultMaginHeight 15

@interface DWDClassMenu()
@property (nonatomic , strong) UIImageView *contentImageView;
@property (nonatomic , assign) CGFloat contenMaxWidth;
@property (nonatomic , assign) CGFloat myBeginY;
@property (nonatomic , assign) CGFloat lastY;

@end

@implementation DWDClassMenu

/**
 *  清除自身颜色
 */
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.contentImageView];
    }
    return self;
}

/**
 *  设置内容和根据内容调整自己的宽高
 */
- (void)setTitles:(NSArray *)titles{
    _titles = titles;
    
    NSDictionary *dict = @{ NSFontAttributeName : [UIFont systemFontOfSize:17],
                            NSForegroundColorAttributeName : DWDRGBColor(102, 102, 102)};
    
    CGFloat btnX = 10;
    CGFloat btnY = 0;
    CGFloat btnW = 0;
    CGFloat btnH = 0;
    
    CGFloat totleH = 0;
    CGFloat maxW = 0;
    
    // 先算出按钮中最大的宽度值
    for (int i = 0; i < titles.count; i++) {
        NSString *title = titles[i];
        CGSize size = [title sizeWithAttributes:dict];
        if (size.width > maxW) {
            maxW = size.width;
        }
    }
    
    for (int i = 0; i < titles.count; i++) {
        NSString *title = titles[i];
        CGSize size = [title sizeWithAttributes:dict];
        btnH = size.height + 20;
        btnW = size.width + 20;
        btnY = btnH * i;

        // 添加按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:title attributes:dict];
        [btn setAttributedTitle:string forState:UIControlStateNormal];
        
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        [btn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchDown];
        
        btn.frame = CGRectMake(btnX + 5, btnY + 2, maxW, btnH);
        [self addSubview:btn];
        // 添加分割线
        if (i != (titles.count - 1)) {
            CALayer *seperaterLayer = [CALayer layer];
            seperaterLayer.backgroundColor = DWDRGBColor(210, 210, 210).CGColor;
            seperaterLayer.frame = CGRectMake(btnX + 5, btnY + btnH, maxW, 1);
            [self.contentImageView.layer addSublayer:seperaterLayer];
        }
        totleH += btnH;
    }
    
    CGRect F = _contentImageView.frame;
    F.size.width = maxW + defaultMaginWidth;
    F.size.height = totleH + defaultMaginHeight;
    self.contentImageView.frame = F;
    
    _contenMaxWidth = maxW;
    _lastY = totleH + defaultMaginHeight;
}

- (void)showFormView:(CGRect)fromRect{
    CGFloat showX = (fromRect.origin.x + fromRect.size.width * 0.5) - _contenMaxWidth * 0.5;
    CGFloat showBeginY = DWDScreenH - 64;
    _myBeginY = showBeginY;
    CGFloat showLastY = fromRect.origin.y - _lastY;
    
    self.frame = CGRectMake(showX - 15, showBeginY, _contenMaxWidth + defaultMaginWidth, _lastY);

    [UIView animateWithDuration:0.15 animations:^{
        self.y = showLastY;
    }];
}

- (void)dismiss{
    [UIView animateWithDuration:0.15 animations:^{
        self.y = _myBeginY;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (UIImageView *)contentImageView{
    if (!_contentImageView) {
        UIImage *image = [UIImage imageNamed:@"BottomMenu"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height*0.5, image.size.width*0.5, image.size.height*0.5, image.size.width*0.5) resizingMode:UIImageResizingModeStretch];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.userInteractionEnabled = YES;
        _contentImageView = imageView;
    }
    return _contentImageView;
}

- (void)btnclick:(UIButton *)btn{
    if ([btn.titleLabel.text isEqualToString:@"成长记录"]) {
        DWDGrowUpViewController *growupRecordVc = [[DWDGrowUpViewController alloc] init];
        growupRecordVc.myClass = self.myClass;
        [_conversationVc.navigationController pushViewController:growupRecordVc animated:YES];
        
    }else if ([btn.titleLabel.text isEqualToString:@"作业"]){
        DWDClassSourceHomeWorkViewController *homeworkVc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDClassSourceHomeWorkViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDClassSourceHomeWorkViewController class])];
                ;
        homeworkVc.classId = self.myClass.classId;
        [_conversationVc.navigationController pushViewController:homeworkVc animated:YES];
        
    }else if ([btn.titleLabel.text isEqualToString:@"接送中心"]){
        //fix
        if ([DWDCustInfo shared].isTeacher) {
            DWDTeacherDetailViewController *vc = [DWDTeacherDetailViewController new];
            vc.classId = self.myClass.classId;
            [_conversationVc.navigationController pushViewController:vc animated:YES];
        } else {
            DWDPickUpCenterChildTableViewController *vc = [DWDPickUpCenterChildTableViewController new];
            vc.classId = self.myClass.classId;
            [_conversationVc.navigationController pushViewController:vc animated:YES];
        }
        
    }else if ([btn.titleLabel.text isEqualToString:@"通知"]){
        DWDClassSourceClassNotificationViewController *classNoteVc = [[DWDClassSourceClassNotificationViewController alloc] init];
        classNoteVc.myClass = self.myClass;
        [_conversationVc.navigationController pushViewController:classNoteVc animated:YES];
        
    }else if ([btn.titleLabel.text isEqualToString:@"假条"]){
        DWDClassSourceLeavePaperViewController *leavePaperVc = [[DWDClassSourceLeavePaperViewController alloc] init];
        leavePaperVc.classId = self.myClass.classId;
        [_conversationVc.navigationController pushViewController:leavePaperVc animated:YES];
        
    }
    [self dismiss];
//    else if ([btn.titleLabel.text isEqualToString:@"班费"]){
//        DWDClassSourceClassMoneyViewController *classMoneyVc = [[DWDClassSourceClassMoneyViewController alloc] init];
//        [_conversationVc.navigationController pushViewController:classMoneyVc animated:YES];
//        
//    }else if ([btn.titleLabel.text isEqualToString:@"资料库"]){
//        DWDClassSourceSourceBoxViewController *sourceBoxVc = [[DWDClassSourceSourceBoxViewController alloc] init];
//        [_conversationVc.navigationController pushViewController:sourceBoxVc animated:YES];
//        
//    }else if ([btn.titleLabel.text isEqualToString:@"投票"]){
//        DWDClassSourceClassVoteViewController *voteVc = [[DWDClassSourceClassVoteViewController alloc] init];
//        [_conversationVc.navigationController pushViewController:voteVc animated:YES];
//        
//    }else if ([btn.titleLabel.text isEqualToString:@"活动"]){
//        DWDClassSourceClassActivityViewController *activityVc = [[DWDClassSourceClassActivityViewController alloc] init];
//        [_conversationVc.navigationController pushViewController:activityVc animated:YES];
//        
//    }
}
@end
