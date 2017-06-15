//
//  DWDHeaderImgSortControl.m
//  EduChat
//
//  Created by Gatlin on 15/12/11.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <SDWebImage/UIButton+WebCache.h>
#import "DWDHeaderImgSortControl.h"
#import "DWDContactModel.h"

#define KBtnTitleH 20
#define KPaddingWithImgTitle 5
#define KBtnViewH 75
#define KPadding 20
#define KNumW (int)(DWDScreenW/kHeaderViewW-2)

#define kHeaderViewW 50
#define kHeaderViewH 75
#define kNum ((int)DWDScreenW/kHeaderViewW-2)            //宽 个数
#define kPadddingW ((DWDScreenW - (kHeaderViewW * kNum)) /(kNum + 1))    //宽间隙
#define kPadddingH 10    //高间隙

#define kHeaderIconWH 50
@implementation DWDHeaderImgSortControl

-(instancetype)init
{
    self = [super init];
    if (self) {
        //设置默认是群主、只为方便其他情况默认有减号
        [self setMain:YES];
    }
    return self;
}

#pragma mark - Setter

-(void)setArrItems:(NSArray *)arrItems
{
    _arrItems = arrItems;
    
    //布局
    [self layouControlType:self.layouType];
}

#pragma mark - Private Method
- (void)layouControlType:(DWDNeedLayouType)layouType
{
    int needAddCount = layouType == DWDNeedBothType ? 2 : 1;
    
    if (layouType == DWDNeedBothType)
        needAddCount = 2;
    else if (layouType == DWDNotNeedType)
        needAddCount = 0;
    else
        needAddCount = 1;
    
    
    int headerViewX,headerViewY,headerViewW,headerViewH = 0;
    headerViewW = kHeaderViewW;
    headerViewH = kHeaderViewH;
    
    for (int i = 0; i < self.arrItems.count + needAddCount; i ++) {
        
        //设置头像与文字View
        UIView *headerView = [[UIView alloc]init];
      
        headerViewX = kPadddingW * ((i % kNum) + 1) + headerViewW * (i % kNum);
        headerViewY = kPadddingH * ((i / kNum) + 1) + headerViewH * (i / kNum);
        
        headerView.frame = CGRectMake(headerViewX, headerViewY, headerViewW, headerViewH);
        [self addSubview:headerView];
        
        //设置头像
        UIButton *btnImg = [UIButton buttonWithType:UIButtonTypeCustom];
        btnImg.frame = CGRectMake(0, 0, kHeaderIconWH, kHeaderIconWH);
        
        if(i<self.arrItems.count)
        {
            //取出模型
            DWDContactModel *entity = self.arrItems[i];
            btnImg.tag = i;
            [btnImg sd_setBackgroundImageWithURL:[NSURL URLWithString:entity.photoKey] forState:UIControlStateNormal placeholderImage:DWDDefault_MeBoyImage];
            [btnImg addTarget:self action:@selector(didGroupCustAction:) forControlEvents:UIControlEventTouchDown];
            
            //设置文字
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, kHeaderIconWH +KPaddingWithImgTitle, kHeaderIconWH, KBtnTitleH)];
            title.textColor = DWDColorContent;
            title.font = DWDFontMin;
            title.textAlignment = NSTextAlignmentCenter;
            //判断是否有备注
            title.text = [[[DWDPersonDataBiz alloc] init] checkoutExistRemarkName:entity.remarkName nickname:entity.nickname];
            [headerView addSubview:title];
        }
        else if (i == self.arrItems.count)
        {
           
            //判断类型
            if (self.layouType == DWDNeedOnlyDeleteButtonType)
            {
                [btnImg setBackgroundImage:[UIImage imageNamed:@"btn_delete_user_normal"] forState:UIControlStateNormal];
                [btnImg setBackgroundImage:[UIImage imageNamed:@"btn_delete_user_press"] forState:UIControlStateHighlighted];
                [btnImg addTarget:self action:@selector(didSelectDelete:) forControlEvents:UIControlEventTouchUpInside];
                
            }
            else
            {
                [btnImg setBackgroundImage:[UIImage imageNamed:@"btn_add_image_group_detail_normal"] forState:UIControlStateNormal];
                [btnImg setBackgroundImage:[UIImage imageNamed:@"btn_add_image_group_detail_press"] forState:UIControlStateHighlighted];
                [btnImg addTarget:self action:@selector(didSelectAdd:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        else if (i == self.arrItems.count + 1)
        {
            [btnImg setBackgroundImage:[UIImage imageNamed:@"btn_delete_user_normal"] forState:UIControlStateNormal];
            [btnImg setBackgroundImage:[UIImage imageNamed:@"btn_delete_user_press"] forState:UIControlStateHighlighted];
            [btnImg addTarget:self action:@selector(didSelectDelete:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [headerView addSubview:btnImg];
    }
    
    if ((self.arrItems.count + needAddCount) % (int)kNum == 0){
        self.hight = (self.arrItems.count + needAddCount) / kNum * (kPadddingH + kHeaderViewH) + kPadddingH;
    }
    else{
       self.hight = ((self.arrItems.count + needAddCount) / kNum + 1) * (kPadddingH + kHeaderViewH) + kPadddingH;
    }
}

/*
-(void)setArrItems:(NSArray *)arrItems
{
    _arrItems = arrItems;
    
    //设置头像
    for(int i = 0 ; i < arrItems.count+2 ; i ++){
        
        
        //设置头像与文字View
        UIView *btnView = [[UIView alloc]init];
       
        
        //设置viewFrame    35 是距离 cell.orgin.y 的
        btnView.frame = CGRectMake(KPadding+ i % KNumW * (KBtnImgW+KPadding),KPadding/2+ i / KNumW*(KBtnViewH+DWDPadding),kHeaderIconWH, KBtnViewH);
         [self addSubview:btnView];
        
        //设置头像
        UIButton *btnImg = [UIButton buttonWithType:UIButtonTypeCustom];
        btnImg.frame = CGRectMake(0, 0, KBtnImgW, KBtnImgW);
        //判断最后两张
        if(i<arrItems.count){
            
            //取出模型
            DWDContactModel *entity = arrItems[i];
            DWDLog(@"entity : %@",entity.nickname);
            btnImg.tag = i;
            [btnImg sd_setBackgroundImageWithURL:[NSURL URLWithString:entity.photoKey] forState:UIControlStateNormal placeholderImage:DWDDefault_MeBoyImage];
            [btnImg addTarget:self action:@selector(didGroupCustAction:) forControlEvents:UIControlEventTouchDown];
            
            //设置文字
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, KBtnImgW +KPaddingWithImgTitle, KBtnImgW, KBtnTitleH)];
            title.textColor = DWDColorContent;
            title.font = DWDFontMin;
            title.textAlignment = NSTextAlignmentCenter;
            //判断是否有备注
           title.text = [[DWDPersonDataBiz new] checkoutExistRemarkName:entity.remarkName nickname:entity.nickname];
            [btnView addSubview:title];
            

        }else if (i==arrItems.count){
            [btnImg setBackgroundImage:[UIImage imageNamed:@"btn_add_image_group_detail_normal"] forState:UIControlStateNormal];
            [btnImg setBackgroundImage:[UIImage imageNamed:@"btn_add_image_group_detail_press"] forState:UIControlStateHighlighted];
            [btnImg addTarget:self action:@selector(didSelectAdd:) forControlEvents:UIControlEventTouchUpInside];
            
        }else if (i==arrItems.count+1){
            [btnImg setBackgroundImage:[UIImage imageNamed:@"btn_delete_user_normal"] forState:UIControlStateNormal];
            [btnImg setBackgroundImage:[UIImage imageNamed:@"btn_delete_user_press"] forState:UIControlStateHighlighted];
            [btnImg addTarget:self action:@selector(didSelectDelete:) forControlEvents:UIControlEventTouchUpInside];
            
        
            //判断isMian是否为0 ，减号按钮隐藏，  为1.有减号按钮
            if (self.isMain) {
                btnImg.hidden = NO;
                //判断arrItems.count是否为0 ，0隐藏
                if (arrItems.count == 0) {
                    btnImg.hidden = YES;
                }else{
                    btnImg.hidden = NO;
                }

            }else{
                 btnImg.hidden = YES;
            }
            

        }
        
        
        [btnView addSubview:btnImg];
        
    }
    
    if ((arrItems.count+2) % KNumW == 0) {
      
        self.num = (int)(arrItems.count+2)/KNumW;
    }else{
        
       self.num =  (int)(arrItems.count+2)/KNumW +1;
    }
    self.hight = (KBtnViewH+DWDPadding) *self.num + DWDPadding;
}
*/
-(void)didGroupCustAction:(UIButton*)sender
{
    //取出模型
    DWDGroupCustEntity *entity = _arrItems[sender.tag];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(headerImgSortControl:DidGroupMemberWithCust:)]) {
        [self.delegate headerImgSortControl:self DidGroupMemberWithCust:entity.custId];
     
    }
}

-(void)didSelectAdd:(UIButton*)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(headerImgSortControlDidSelectAddButton:)]) {
        [self.delegate headerImgSortControlDidSelectAddButton:self];
    }
}
-(void)didSelectDelete:(UIButton*)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(headerImgSortControlDidSelectDeleteButton:)]) {
        [self.delegate headerImgSortControlDidSelectDeleteButton:self];
    }
}
@end
