//
//  DWDGroupInfoSectionItemModel.m
//  EduChat
//
//  Created by Gatlin on 15/12/21.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDGroupInfoSectionItemModel.h"
#import "DWDGroupInfoModel.h"
#import "DWDGroupEntity.h"
@interface DWDGroupInfoSectionItemModel ()
@property (strong, nonatomic) NSMutableArray *arrItems;
@end
@implementation DWDGroupInfoSectionItemModel
-(NSArray *)arrSectionItem
{
    return self.arrItems;
}


-(NSMutableArray *)arrItems
{
    if (!_arrItems) {
        _arrItems = [NSMutableArray array];
    }
    [self setupSection0];
    [self setupSection1];
    [self setupSection2];
    [self setupSection3];
    [self setupSection4];
    [self setupSection5];
    [self setupSection6];

    return _arrItems;
}

-(void)setupSection0
{
    DWDGroupInfoModel *groupRow_1 = [[DWDGroupInfoModel alloc]init];
    groupRow_1.title = @"群成员";
    groupRow_1.detailTitle = [self.groupModel.memberCount stringValue];
    groupRow_1.type = DWDGroupTypeDetailTitle;
    
    DWDGroupInfoModel *groupRow_2 = [[DWDGroupInfoModel alloc]init];
    groupRow_2.title = nil;
    groupRow_2.detailTitle = nil;
    groupRow_2.type = DWDGroupTypeNone;
    NSArray *arr = @[groupRow_2];
    [_arrItems addObject:arr];
}
-(void)setupSection1
{
    DWDGroupInfoModel *groupIcon = [[DWDGroupInfoModel alloc]init];
    groupIcon.title = @"群组头像";
    groupIcon.imgName = self.groupModel.photoKey;
    groupIcon.type = DWDGroupTypeImg;
    
    DWDGroupInfoModel *groupName = [[DWDGroupInfoModel alloc]init];
    groupName.title = @"群组名称";
    groupName.detailTitle = self.groupModel.groupName;
    groupName.type = DWDGroupTypeDetailTitle;
   
    
    DWDGroupInfoModel *groupZbar = [[DWDGroupInfoModel alloc]init];
    groupZbar.title = @"群二维码";
    groupZbar.imgName = @"Common_qr-code_normal";
    groupZbar.type = DWDGroupTypeImg;
    
    DWDGroupInfoModel *groupNum = [[DWDGroupInfoModel alloc]init];
    groupNum.title = @"群组人数";
    groupNum.detailTitle = [NSString stringWithFormat:@"%@人",self.groupModel.memberCount];
    groupNum.type = DWDGroupTypeDetailTitle;
   
    /*
    DWDGroupInfoModel *groupChatImg = [[DWDGroupInfoModel alloc]init];
    groupChatImg.title = @"聊天图片";
    groupChatImg.type = DWDGroupTypeIndicator;
     */
    
    NSArray *arr = @[groupIcon, groupName, groupZbar, groupNum];
    [_arrItems addObject:arr];
}
-(void)setupSection2
{
    DWDGroupInfoModel *groupTop = [[DWDGroupInfoModel alloc]init];
    groupTop.title = @"置顶聊天";
    //groupTop.isOpen = [self.dictModle[@"isTop"] boolValue];
    groupTop.type = DWDGroupTypeSwitch;
    
    DWDGroupInfoModel *groupDon = [[DWDGroupInfoModel alloc]init];
    groupDon.title = @"消息免打扰";
    //groupDon.isOpen = [self.dictModle[@"isClose"] boolValue];
    groupDon.type = DWDGroupTypeSwitch;
    
    DWDGroupInfoModel *groupSave = [[DWDGroupInfoModel alloc]init];
    groupSave.title = @"保存至通讯录";
    //groupSave.isOpen = [self.dictModle[@"isSave"] boolValue];
    groupSave.type = DWDGroupTypeSwitch;
    
      /*
    NSArray *arr = @[groupTop,groupDon,groupSave];
    [_arrItems addObject:arr];
     */
}
-(void)setupSection3
{
    DWDGroupInfoModel *groupRow_1 = [[DWDGroupInfoModel alloc]init];
    groupRow_1.title = @"我的群昵称";
    groupRow_1.detailTitle = self.groupModel.nickname;
    groupRow_1.type = DWDGroupTypeDetailTitle;
    
    DWDGroupInfoModel *groupRow_2 = [[DWDGroupInfoModel alloc]init];
    groupRow_2.title = @"显示群成员昵称";
    groupRow_2.isOpen = [self.groupModel.isShowNick boolValue];
    groupRow_2.type = DWDGroupTypeSwitch;
    
    NSArray *arr = @[groupRow_1,groupRow_2];
    [_arrItems addObject:arr];
    
}
-(void)setupSection4
{
    DWDGroupInfoModel *groupRow_1 = [[DWDGroupInfoModel alloc]init];
    groupRow_1.title = @"查找聊天记录";
    groupRow_1.type = DWDGroupTypeIndicator;
    
    /*
    NSArray *arr = @[groupRow_1];
    [_arrItems addObject:arr];
     */
}
-(void)setupSection5
{
    DWDGroupInfoModel *groupRow_1 = [[DWDGroupInfoModel alloc]init];
    groupRow_1.title = @"清空聊天记录";
    groupRow_1.type = DWDGroupTypeNone;
    
    /*
    NSArray *arr = @[groupRow_1];
    [_arrItems addObject:arr];
      */
}

-(void)setupSection6
{
    DWDGroupInfoModel *groupRow_1 = [[DWDGroupInfoModel alloc]init];
    groupRow_1.title = @"举报";
    groupRow_1.type = DWDGroupTypeNone;
    
    /*
    NSArray *arr = @[groupRow_1];
    [_arrItems addObject:arr];
     */
}
@end
