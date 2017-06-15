//
//  DWDMeViewController.m
//  DWDSj
//
//  Created by apple  on 15/10/29.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDMeViewController.h"
#import "DWDMeDetailViewController.h"
#import "DWDMeAlbumViewController.h"
#import "DWDCollectViewController.h"
#import "DWDSettingViewController.h"
#import "DWDLoginViewController.h"
#import "DWDShareAppToFriendViewController.h"

#import "DWDNavViewController.h"

#import <UIImageView+WebCache.h>
#import "DWDChatMsgReplaceFace.h"
#import "TTTAttributedLabel.h"
#import <YYLabel.h>

//#import "DWDPickUpCenterDataBaseModel.h"
//#import <YYModel.h>
//#import "DWDChatMsgDataClient.h"

#import "DWDLIchaoTextVc.h"
#import "DWDVideoRecordView.h"
#import "DWDZGTestViewController.h"


@interface DWDMeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgHearde;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *educhatAccount;
@end

@implementation DWDMeViewController

#pragma Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.w, 10)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"haha" style:UIBarButtonItemStylePlain target:self action:@selector(haha)];
}

- (void)haha{
    DWDLIchaoTextVc *lichao = [[DWDLIchaoTextVc alloc] init];
    
    [self.navigationController pushViewController:lichao animated:YES];
    
//    DWDZGTestViewController *testVC = [[DWDZGTestViewController alloc] init];
//    testVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:testVC animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self testPUC];
    
    if ([DWDCustInfo shared].isLogin) {
        
        //若为设置头像，加载男女头像有别
      UIImage *defaultImage = [[DWDCustInfo shared].custGender isEqualToString:@"女"] ? DWDDefault_MeGrilImage :DWDDefault_MeBoyImage;
        [self.imgHearde sd_setImageWithURL:[NSURL URLWithString:[DWDCustInfo shared].custThumbPhotoKey] placeholderImage:defaultImage];
        
        self.nickname.text = [DWDCustInfo shared].custNickname;
        
        if ([DWDCustInfo shared].custEduchatAccount) {
            self.educhatAccount.text = [NSString stringWithFormat:@"多维度号:%@",[DWDCustInfo shared].custEduchatAccount];
            self.educhatAccount.textColor = DWDColorContent;
        }else{
            self.educhatAccount.text = [NSString stringWithFormat:@"未设置多维度号"];
            self.educhatAccount.textColor = DWDColorSecondary;
            
        }

    }else{
        
        [self.imgHearde setImage:DWDDefault_MeBoyImage];
        self.nickname.text = nil;
        self.educhatAccount.text = @"未登录";
    }
}


#pragma mark -  Checkout Login
-(void)checkLogin
{
    if (![DWDCustInfo shared].isLogin) {
        
        self.educhatAccount.text = @"未登录";
        [self tapLogin];
    }
}

-(void)tapLogin
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDLoginViewController class]) bundle:nil];
    
    DWDLoginViewController *controller = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDLoginViewController class])];
    controller.hidesBottomBarWhenPushed = YES;
    DWDNavViewController *vc = [[DWDNavViewController alloc] initWithRootViewController:controller];
    vc.navigationBarHidden = YES;
    
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //检测是否登录
    [self checkLogin];
    if (![DWDCustInfo shared].isLogin) {
        return;
    }
    if (indexPath.section == 0) {
        // 跳转个人详情控制器
        [self skipToVcWithClassName:NSStringFromClass([DWDMeDetailViewController class])];
    }
    else if (indexPath.section == 1){
        /*
         if (indexPath.row == 0) {
         // 跳转到个人相册
         DWDMeAlbumViewController *meAlbumVc = [[DWDMeAlbumViewController alloc] initWithStyle:UITableViewStyleGrouped];
         [self.navigationController pushViewController:meAlbumVc animated:YES];
         }
         */
    
        // 跳转到收藏控制器
//        [self skipToVcWithClassName:NSStringFromClass([DWDMyCollectionViewController class])];
        DWDCollectViewController *vc = [[DWDCollectViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.section == 2){
        DWDShareAppToFriendViewController *vc = [[DWDShareAppToFriendViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.section == 3){
        // 跳转到设置控制器
        [self skipToVcWithClassName:NSStringFromClass([DWDSettingViewController class])];
    }
}

#pragma mark - Private Method
- (void)skipToVcWithClassName:(NSString *)Vcname{

    UIStoryboard *sb = [UIStoryboard storyboardWithName:Vcname bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:Vcname];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

//#warning test delete - KKK
//- (void)testPUC {
//    //    {"code":"sysmsgContextual","entity":{"contextual":"Reachschool","date":"2016-09-08","photokey":"","parent":{"photokey":"http://educhat.oss-cn-hangzhou.aliyuncs.com/805D8EF5-67F7-4939-B8BD-D93599910C4B","custId":6010000010106,"name":"","photohead":{"photokey":"http://educhat.oss-cn-hangzhou.aliyuncs.com/805D8EF5-67F7-4939-B8BD-D93599910C4B","size":148584,"width":320,"height":504}},"code":"sysmsgContextual","photo":"http://educhat.oss-cn-hangzhou.aliyuncs.com/d3817925-b20c-42a0-a8c1-1caf0bee10da","index":0,"className":"小E班","type":1,"toUserId":6010000010106,"photohead":{"photokey":"","size":0,"width":0,"height":0},"relation":22,"eventCode":"SendSysMsg","classId":8010000001237,"teacher":{"photokey":"","custId":0,"name":""},"schoolId":2010000009532,"custId":5010000010230,"name":"张思诚","time":"08:12:36","schoolName":"广州市越秀区洋紫荆东风幼儿园","memberId":6010000010106},"uuid":"8aafe44f56ead4ee01570723b5512a47"}
//    
//    int i = 0;
//    NSNumber *classId = @8010000001237;
//    while (i < 20) {
//        
//        
//        for (int j = 0; j < 10; j ++) {
//            
//            DWDPickUpCenterDataBaseModel *model0 = [[DWDPickUpCenterDataBaseModel alloc] init];
//            model0.contextual = @"Reachschool";
//            model0.index = @0;
//            model0.type = @1;
//            model0.custId = classId;
//            model0.time = @"08:12:36";
//            model0.date = @"2016-09-08";
//            model0.name = @"test0";
//            model0.classId = classId;
//            model0.className = @"[[小A班]]";
//            model0.schoolId = @2010000009532;
//            model0.schoolName = @"广州市越秀区洋紫荆东风幼儿园";
//            
//            NSDictionary *postInfo = @{@"code": @"sysmsgContextual",
//                                       @"entity": model0,
//                                       @"uuid" : [NSUUID UUID].UUIDString
//                                       };
//            NSString *json = [postInfo yy_modelToJSONString];
//            NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
//            /**
//             模拟socket通讯 发送消息
//             
//             消息由包头(0x4040) + 协议头(系统消息0x9101) + 长度(2个字节) + 消息体 + 校验码(1个字节) + 包尾(0x2424)
//             */
//            
//            NSMutableData *resultData = [NSMutableData data];
//            Byte head[] = {0x40, 0x40, 0x91, 0x01};
//            [resultData appendBytes:head length:4];
//            //消息长度
//            long len = NSSwapHostLongToLittle(jsonData.length);
//            
//            char *charLen = (char *)&len;
//            
//            Byte b[] = {0,0};
//            memcpy(&b[0], &charLen[1], 1);
//            memcpy(&b[1], &charLen[0], 1);
//            [resultData appendBytes:b length:2];
//            //消息体
//            unsigned char body[jsonData.length];
//            [jsonData getBytes:body range:NSMakeRange(0, jsonData.length)];
//            
//            [resultData appendBytes:body length:jsonData.length];
//            //校验码
//            //        [[DWDChatMsgDataClient sharedChatMsgDataClient] getCheckMark:body len:jsonData.length];
//            Byte checksum = body[1];
//            for (int i = 0; i < jsonData.length; i++) {
//                checksum = checksum ^ body[i];
//            }
//            //    Byte check[] = {checksum};
//            unsigned char check[] = {checksum};
//            [resultData appendBytes:check length:1];
//            //尾
//            Byte end[] = {0x24, 0x24};
//            [resultData appendBytes:end length:2];
//            
//            [[DWDChatMsgDataClient sharedChatMsgDataClient] parseChatMsgFromDataAndPostSomeNotification:resultData];
//        }
//        
//        long long class = [classId longLongValue];
//        class += 1;
//        classId = [NSNumber numberWithLongLong:class];
//        
//        i++;
//    }
//}

@end
