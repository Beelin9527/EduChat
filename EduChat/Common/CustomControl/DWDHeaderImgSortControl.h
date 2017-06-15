//
//  DWDHeaderImgSortControl.h
//  EduChat
//
//  Created by Gatlin on 15/12/11.
//  Copyright © 2015年 dwd. All rights reserved.
//  头像排列Control

//*********** 注意 先给数组赋值 再设置frame   *********/

#import <UIKit/UIKit.h>
#import "DWDGroupCustEntity.h"

typedef NS_ENUM(NSUInteger) {
    DWDNeedBothType,                        //两者都要
    DWDNotNeedType,                         //都不需要
    DWDNeedOnlyAddButtonType,               //只需要添加按钮
    DWDNeedOnlyDeleteButtonType           //只需要删除按钮
}DWDNeedLayouType;

@class DWDHeaderImgSortControl;
@protocol DWDHeaderImgSortControlDelegate <NSObject>
@optional
-(void)headerImgSortControl:(DWDHeaderImgSortControl*)headerImgSortControl DidGroupMemberWithCust:(NSNumber*)custId;
-(void)headerImgSortControlDidSelectAddButton:(DWDHeaderImgSortControl*)headerImgSortControl;
-(void)headerImgSortControlDidSelectDeleteButton:(DWDHeaderImgSortControl*)headerImgSortControl;
@end
@interface DWDHeaderImgSortControl : UIView

@property (strong, nonatomic) NSArray *arrItems;
@property (assign, nonatomic) int num;
@property (assign, nonatomic) float hight;
@property (getter=isMain, nonatomic) BOOL main;  //标识是否为群主

@property (assign, nonatomic) DWDNeedLayouType layouType;  //布局类型
@property (nonatomic,weak) id<DWDHeaderImgSortControlDelegate> delegate;

@end
