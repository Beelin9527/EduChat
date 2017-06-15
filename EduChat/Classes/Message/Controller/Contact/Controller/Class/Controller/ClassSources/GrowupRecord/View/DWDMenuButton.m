//
//  DWDMenuButton.m
//  EduChat
//
//  Created by Superman on 15/12/30.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDMenuButton.h"
#import "DWDMenuController.h"
#import "DWDClassGrowUpCell.h"
#import "DWDGrowUpRecordFrame.h"
@implementation DWDMenuButton


- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    return (action == @selector(zanClick:) || action == @selector(commentClick:));
}


- (void)zanClick:(DWDMenuController *)menuVc{
    DWDLogFunc;
    
    NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                             @"albumId" : menuVc.growupModel.record.albumId,
                             @"recordId" : menuVc.growupModel.record.logId};
    [[HttpClient sharedClient] postApi:@"AlbumRestService/addPraise" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DWDLog(@"%@~~~~~~~",responseObject[@"data"]);
        //  把自己的名字传给cell  刷新tableview
//        DWDClassGrowUpCell *cell = menuVc.cell;
//        cell.addNewZanPeopleName = [DWDCustInfo shared].custNickname;
        // 应该修改模型,并且上传服务器
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DWDMenuButtonzanClickNotification" object:nil];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDLog(@"error:%@",error);
    }];
}

- (void)commentClick:(DWDMenuController *)menuVc{
    DWDLogFunc;
    DWDLog(@"%@",menuVc.growupModel);
    // 弹出键盘
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DWDMenuButtoncommentClickNotification" object:nil];
    
}
@end
