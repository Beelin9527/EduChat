//
//  DWDClassSettingModle.m
//  EduChat
//
//  Created by Bharal on 15/12/31.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassSettingSectiomItemsModle.h"

#import "DWDGroupInfoModel.h"

@interface DWDClassSettingSectiomItemsModle ()
@property (strong, nonatomic) NSMutableArray *arrItems;
@end
@implementation DWDClassSettingSectiomItemsModle
-(NSArray *)arrSectionItem
{
    return self.arrItems;
}


-(NSMutableArray *)arrItems
{
    if (!_arrItems) {
        _arrItems = [NSMutableArray array];
    }
    [self setupSection1];
    [self setupSection2];
    [self setupSection3];
    [self setupSection4];
    [self setupSection5];
   // [self setupSection6];
    
    return _arrItems;
}


-(void)setupSection1
{
    DWDGroupInfoModel *groupName = [[DWDGroupInfoModel alloc]init];
    groupName.title = @"班级名称";
    groupName.detailTitle = self.dictDataSource[@"className"];
    groupName.type = DWDGroupTypeDetailTitle;
    
    
    DWDGroupInfoModel *groupZbar = [[DWDGroupInfoModel alloc]init];
    groupZbar.title = @"班级二维码";
    groupZbar.type = DWDGroupTypeImg;
    
    DWDGroupInfoModel *classHao = [[DWDGroupInfoModel alloc]init];
    classHao.title = @"班级号";
    //classHao.detailTitle = [self.dictDataSource[@"classNum"] stringValue];
    classHao.type = DWDGroupTypeDetailTitle;
    
    DWDGroupInfoModel *groupNum = [[DWDGroupInfoModel alloc]init];
    groupNum.title = @"班级组人数";
    groupNum.detailTitle = [self.dictDataSource[@"classNum"] stringValue];
    groupNum.type = DWDGroupTypeDetailTitle;
    
    DWDGroupInfoModel *groupChatImg = [[DWDGroupInfoModel alloc]init];
    groupChatImg.title = @"聊天图片";
    groupChatImg.type = DWDGroupTypeIndicator;
    
    NSArray *arr = @[groupName,groupZbar,groupNum,groupChatImg];
    [_arrItems addObject:arr];
}
-(void)setupSection2
{
    DWDGroupInfoModel *groupTop = [[DWDGroupInfoModel alloc]init];
    groupTop.title = @"置顶聊天";
    groupTop.isOpen = [self.dictDataSource[@"isTop"] boolValue];
    groupTop.type = DWDGroupTypeSwitch;
    
    DWDGroupInfoModel *groupDon = [[DWDGroupInfoModel alloc]init];
    groupDon.title = @"消息免打扰";
    groupDon.isOpen = [self.dictDataSource[@"isClose"] boolValue];
    groupDon.type = DWDGroupTypeSwitch;
    
    
    NSArray *arr = @[groupTop,groupDon];
    [_arrItems addObject:arr];
}
-(void)setupSection3
{
    DWDGroupInfoModel *groupRow_1 = [[DWDGroupInfoModel alloc]init];
    groupRow_1.title = @"我的班级昵称";
    groupRow_1.detailTitle = self.dictDataSource[@"nickname"];
    groupRow_1.type = DWDGroupTypeDetailTitle;
    
    DWDGroupInfoModel *groupRow_2 = [[DWDGroupInfoModel alloc]init];
    groupRow_2.title = @"显示班级成员昵称";
    groupRow_2.isOpen = [self.dictDataSource[@"isShowNick"] boolValue];
    groupRow_2.type = DWDGroupTypeSwitch;
    
    NSArray *arr = @[groupRow_1,groupRow_2];
    [_arrItems addObject:arr];
    
}
-(void)setupSection4
{
    DWDGroupInfoModel *groupRow_1 = [[DWDGroupInfoModel alloc]init];
    groupRow_1.title = @"查找聊天记录";
    groupRow_1.type = DWDGroupTypeIndicator;
    
    NSArray *arr = @[groupRow_1];
    [_arrItems addObject:arr];
}
-(void)setupSection5
{
    DWDGroupInfoModel *groupRow_1 = [[DWDGroupInfoModel alloc]init];
    groupRow_1.title = @"清空聊天记录";
    groupRow_1.type = DWDGroupTypeNone;
    
    NSArray *arr = @[groupRow_1];
    [_arrItems addObject:arr];
}

-(void)setupSection6
{
    DWDGroupInfoModel *groupRow_1 = [[DWDGroupInfoModel alloc]init];
    groupRow_1.title = @"举报";
    groupRow_1.type = DWDGroupTypeNone;
    
    NSArray *arr = @[groupRow_1];
    [_arrItems addObject:arr];
}

@end